import 'package:money_wise/domain/entities/transaction_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel extends TransactionEntity {
  final List<TransactionItem> items;

  TransactionModel({
    required super.id,
    required super.amount,
    required super.type,
    required super.category,
    super.merchant,
    super.receiptUrl,
    required super.date,
    super.note,
    super.isVerified = false,
    required super.createdAt,
    super.updatedAt,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type.toString().split('.').last,
      'category': category,
      'merchant': merchant,
      'receipt_url': receiptUrl,
      'date': Timestamp.fromDate(date),
      'is_verified': isVerified,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
      'note': note,
      // Map the items list to a list of JSON-like maps
      'items': items.map((i) => i.toMap()).toList(),
    };
  }

  factory TransactionModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return TransactionModel(
      id: documentId,
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => TransactionType.expense,
      ),
      category: map['category'] ?? 'Uncategorized',
      merchant: map['merchant'],
      receiptUrl: map['receipt_url'],
      note: map['note'],
      date: (map['date'] as Timestamp).toDate(),
      isVerified: map['is_verified'] ?? false,
      createdAt: (map['created_at'] as Timestamp).toDate(),
      updatedAt: (map['updated_at'] as Timestamp?)?.toDate(),
      // Safely extract and parse the items list
      items:
          (map['items'] as List<dynamic>?)
              ?.map(
                (item) => TransactionItem.fromMap(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  TransactionModel copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? category,
    String? merchant,
    String? receiptUrl,
    DateTime? date,
    String? note,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TransactionItem>? items,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      merchant: merchant ?? this.merchant,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      date: date ?? this.date,
      note: note ?? this.note,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}

class TransactionItem {
  String name;
  int quantity;
  double price;

  TransactionItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'quantity': quantity,
    'price': price,
  };

  factory TransactionItem.fromMap(Map<String, dynamic> map) => TransactionItem(
    name: map['name'] ?? '',
    quantity: (map['quantity'] as num).toInt(),
    price: (map['price'] as num).toDouble(),
  );
}
