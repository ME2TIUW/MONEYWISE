import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:money_wise/data/models/receipt_model.dart';
import 'package:money_wise/data/models/receipt_item_model.dart';
import 'package:firebase_performance/firebase_performance.dart';

class OpenRouterService {
  final String apiKey;
  final String model;
  OpenRouterService(
    this.apiKey, {
    this.model = 'nvidia/nemotron-3-nano-30b-a3b:free',
  });

  Future<Receipt?> parseReceiptFromText(String ocrText) async {
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    final HttpMetric metric = FirebasePerformance.instance.newHttpMetric(
      url.toString(),
      HttpMethod.Post,
    );

    try {
      await metric.start();
      final resp = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
              'HTTP-Referer': 'https://yourapp.com',
              'X-Title': 'MoneyWise',
            },
            body: jsonEncode({
              'model': model,
              "reasoning": {"effort": "none"},
              'messages': [
                {
                  'role': 'system',
                  'content': '''
                You are a specialized Receipt Parser OCR. Your goal is to extract structured data from messy OCR text.

                STRICT RULES:
                1. **Merchant**: Extract the business name accurately.
                2. **Date**: Convert to ISO 8601 format (YYYY-MM-DD). If year is missing, use 2026.
                3. **Identify Grand Total**: Look for keywords like "TOTAL", "GRAND TOTAL", "NETTO", or "JUMLAH".
                4. **Items**: 
                  - "name": Clean item descriptions (remove noise/symbols).
                  - "qty": Must be an integer. Default to 1 if not found.
                  - "price": Price per single unit.
                5. **Output**: Return ONLY valid JSON. No markdown, no "```json" tags, no explanations. 
                6. **Missing Data**: If a field is not found, use null for strings/numbers and [] for arrays.

                JSON SCHEMA:
                {
                  "merchant": string,
                  "date": string,
                  "total": number,
                  "items": [
                    { "name": string, "qty": number, "price": number }
                  ]
                }

                EXAMPLE:
                Input: "12/05/24 STARBUCKS COFFEE CAFFE LATTE 2x 55000 TOTAL 110000"
                Output: {"merchant": "STARBUCKS COFFEE", "date": "2024-05-12", "total": 110000, "items": [{"name": "CAFFE LATTE", "qty": 2, "price": 55000}]}
                ''',
                },
                {'role': 'user', 'content': ocrText},
              ],
              'temperature': 0.0,
              'max_tokens': 900,
              'provider': {
                'only': ['nvidia/bf16'],
              },
            }),
          )
          .timeout(const Duration(seconds: 20));

      metric.httpResponseCode = resp.statusCode;
      metric.responsePayloadSize = resp.bodyBytes.length;
      await metric.stop();
      if (resp.statusCode != 200) return null;
      final data = jsonDecode(resp.body);
      final content = data['choices']?[0]?['message']?['content'];

      String text;
      if (content is String) {
        text = content;
      } else if (content is List) {
        text = content.map((e) => e['text'] ?? '').join();
      } else {
        return null;
      }

      try {
        final json = jsonDecode(text);
        final items = <ReceiptItem>[];
        if (json['items'] is List) {
          for (final it in json['items']) {
            final qty = (it['qty'] is int)
                ? it['qty']
                : int.tryParse('${it['qty']}') ?? 1;
            final price = (it['price'] is int)
                ? it['price']
                : int.tryParse('${it['price']}') ?? 0;
            items.add(
              ReceiptItem(
                name: it['name'] ?? '',
                qty: qty,
                price: price,
                quantity: qty,
              ),
            );
          }
        }
        return Receipt(
          merchant: json['merchant'] ?? 'Unknown Merchant',
          date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
          total: (json['total'] is int)
              ? json['total']
              : int.tryParse('${json['total']}') ?? 0,
          items: items,
        );
      } catch (_) {
        return null;
      }
    } catch (_) {
      try {
        metric.httpResponseCode = 408; // Set Request Timeout HTTP code
        await metric.stop();
      } catch (_) {}
      return null;
    }
  }
}
