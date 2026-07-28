import '../models/receipt_model.dart';
import '../models/receipt_item_model.dart';

class ReceiptParser {
  Receipt parse(String rawText) {
    final lines = rawText
        .split('\n')
        .map(_normalize)
        .where((e) => e.isNotEmpty)
        .toList();

    final items = <ReceiptItem>[];

    for (final line in lines) {
      if (_looksLikeItem(line)) {
        final price = _extractPrice(line);
        if (price == 0) continue;

        items.add(
          ReceiptItem(
            name: _extractName(line),
            qty: _extractQty(line),
            price: price,
            quantity: _extractQty(line),
          ),
        );
      }
    }

    return Receipt(
      merchant: _extractMerchant(lines),
      date: _extractDate(lines),
      total: _extractTotal(lines, items),
      items: items,
    );
  }


  String _normalize(String s) =>
      s.toUpperCase()
      .replaceAll(RegExp(r'[^A-Z0-9 .,-]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  bool _looksLikeItem(String line) {
    final hasPrice = RegExp(r'\d{3,}').hasMatch(line);
    final hasLetters = RegExp(r'[A-Z]').hasMatch(line);
    final isMeta = RegExp(
      r'TOTAL|SUBTOTAL|CASH|CHANGE|DATE|TIME|PPN|TAX'
    ).hasMatch(line);

    return hasPrice && hasLetters && !isMeta;
  }

  int _extractPrice(String line) {
    final matches = RegExp(r'\d{3,}').allMatches(line).toList();
    if (matches.isEmpty) return 0;

    return int.parse(
      matches.last.group(0)!.replaceAll(RegExp(r'[.,]'), '')
    );
  }

  String _extractName(String line) {
    return line
        .replaceAll(RegExp(r'\d'), '')
        .replaceAll(RegExp(r'[.,]'), '')
        .trim();
  }

  int _extractQty(String line) {
    final match = RegExp(r'(\d+)\s*[Xx]').firstMatch(line);
    return match != null ? int.parse(match.group(1)!) : 1;
  }


  String _extractMerchant(List<String> lines) {
    for (final line in lines.take(5)) {
      if (RegExp(r'[A-Z]').hasMatch(line) &&
          !RegExp(r'\d').hasMatch(line) &&
          line.length >= 4) {
        return line;
      }
    }
    return 'Unknown Merchant';
  }

  DateTime? _extractDate(List<String> lines) {
    for (final line in lines) {
      final match = RegExp(
        r'(\d{2}[./-]\d{2}[./-]\d{4})|(\d{4}[./-]\d{2}[./-]\d{2})'
      ).firstMatch(line);
      if (match != null) {
        final dateStr = match.group(0)!.replaceAll(RegExp(r'[./-]'), '-');
        try {
          return DateTime.parse(dateStr);
        } catch (_) {}
      }
    }
    return null;
  }



  int _extractTotal(List<String> lines, List<ReceiptItem> items) {
    for (final line in lines.reversed) {
      if (RegExp(r'TOTAL').hasMatch(line)) {
        final price = _extractPrice(line);
        if (price > 0) return price;
      }
    }

    return items.fold(0, (sum, item) => sum + item.price * item.qty);
  }
}