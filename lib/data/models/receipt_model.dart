import 'receipt_item_model.dart';

class Receipt {
  final String merchant;
  final DateTime? date;
  final int total;
  final List<ReceiptItem> items;

  Receipt({
    required this.merchant,
    required this.date,
    required this.total,
    required this.items,
  });

  String get dateFormatted {
    return '${date?.day.toString().padLeft(2, '0')}/'
    '${date?.month.toString().padLeft(2, '0')}/'
    '${date?.year}';
  }
}