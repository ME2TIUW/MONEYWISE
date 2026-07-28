enum TransactionType { income, expense }

abstract class TransactionEntity {
  final String id;
  final double amount;
  final TransactionType type;
  final String category;
  final String? merchant;
  final String? receiptUrl;
  final String? note;
  final DateTime date;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TransactionEntity({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    this.merchant,
    this.receiptUrl,
    this.note,
    required this.date,
    this.isVerified = false,
    required this.createdAt,
    this.updatedAt,
  });
}
