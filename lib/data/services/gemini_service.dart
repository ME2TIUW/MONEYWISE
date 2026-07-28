import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_performance/firebase_performance.dart';

class GeminiService {
  Future<String> sendPrompt(String prompt, String financialContext) async {
    HttpMetric? metric;
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];

      final baseUrl =
          "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent";
      final url = Uri.parse("$baseUrl?key=$apiKey");

      final requestBody = jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text":
                    """ 
                You are Moni, a highly empathetic and professional financial assistant in the MoneyWise app.

                CONTEXTUAL KNOWLEDGE:
                $financialContext

               YOUR ROLE:
                - Help users manage money and provide budgeting advice.
                - Explain financial concepts simply and focus only on personal finance topics.

                RULES:
                - Only answer financial questions. If the question is unrelated, politely say you only help with finance.
                - Do NOT introduce yourself unless the user specifically asks who you are.
                - If the financial context below is empty or restricted, explain that you cannot see their data yet and provide only general financial advice.
                - Never make up specific numbers (hallucinate) if they aren't provided in the context.
                - Keep responses concise, supportive, and scannable using bullet points.

                User question: $prompt""",
              },
            ],
          },
        ],
      });

      metric = FirebasePerformance.instance.newHttpMetric(
        baseUrl,
        HttpMethod.Post,
      );

      metric.requestPayloadSize = utf8.encode(requestBody).length;

      await metric.start();

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      );

      metric.httpResponseCode = response.statusCode;
      metric.responsePayloadSize = response.bodyBytes.length;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        }
        return "Moni couldn't generate a response.";
      } else {
        try {
          final errorData = jsonDecode(response.body);
          final String errorMessage =
              errorData['error']['message'] ?? response.reasonPhrase;
          return "Moni API error: $errorMessage";
        } catch (_) {
          return "Moni API error: ${response.reasonPhrase}";
        }
      }
    } catch (e, stackTrace) {
      print("GeminiService Error: $e");
      print("StackTrace: $stackTrace");

      return "Sorry, Moni is currently unavailable. Please try again later.";
    } finally {
      if (metric != null) {
        await metric.stop();
      }
    }
  }
}
