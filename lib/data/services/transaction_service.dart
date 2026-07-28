import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_wise/data/models/transaction_model.dart';
import 'package:firebase_performance/firebase_performance.dart';

class TransactionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebasePerformance _performance = FirebasePerformance.instance;

  CollectionReference<Map<String, dynamic>> _getCollection(String uid) {
    return _db.collection('users').doc(uid).collection('transactions');
  }

  Future<void> addTransaction(String uid, TransactionModel transaction) async {
    final Trace trace = _performance.newTrace('firestore_add_transaction');
    await trace.start();

    try {
      final batch = _db.batch();
      final userDoc = _db.collection('users').doc(uid);
      final transactionDoc = _getCollection(uid).doc();

      final transactionWithId = transaction.copyWith(id: transactionDoc.id);
      batch.set(transactionDoc, transactionWithId.toMap());

      double adjustment = transaction.type.name == 'income'
          ? transaction.amount
          : -transaction.amount;

      batch.update(userDoc, {
        'remaining_budget': FieldValue.increment(adjustment),
      });

      await batch.commit();
    } finally {
      await trace.stop();
    }
  }

  Future<void> deleteTransaction(
    String uid,
    TransactionModel transaction,
  ) async {
    final Trace trace = _performance.newTrace('firestore_delete_transaction');
    await trace.start();

    try {
      final batch = _db.batch();
      final userDoc = _db.collection('users').doc(uid);
      final transactionDoc = _getCollection(uid).doc(transaction.id);

      batch.delete(transactionDoc);

      double reverseAdjustment = transaction.type.name == 'income'
          ? -transaction.amount
          : transaction.amount;

      batch.update(userDoc, {
        'remaining_budget': FieldValue.increment(reverseAdjustment),
      });

      await batch.commit();
    } finally {
      await trace.stop();
    }
  }

  Future<void> updateTransaction(
    String uid,
    TransactionModel oldTransaction,
    TransactionModel newTransaction,
  ) async {
    final Trace trace = _performance.newTrace('firestore_update_transaction');
    await trace.start();

    try {
      final batch = _db.batch();
      final userDoc = _db.collection('users').doc(uid);
      final transactionDoc = _getCollection(uid).doc(newTransaction.id);

      batch.update(transactionDoc, newTransaction.toMap());

      double oldImpact = oldTransaction.type.name == 'income'
          ? oldTransaction.amount
          : -oldTransaction.amount;
      double newImpact = newTransaction.type.name == 'income'
          ? newTransaction.amount
          : -newTransaction.amount;
      double netChange = newImpact - oldImpact;

      batch.update(userDoc, {
        'remaining_budget': FieldValue.increment(netChange),
      });

      await batch.commit();
    } finally {
      await trace.stop();
    }
  }

  Stream<List<TransactionModel>> getTransactions(String uid) {
    final Trace trace = _performance.newTrace(
      'firestore_get_transactions_initial',
    );
    bool isFirstLoad = true;

    trace.start();

    return _getCollection(
      uid,
    ).orderBy('date', descending: true).snapshots().map((snapshot) {
      try {
        return snapshot.docs
            .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
            .toList();
      } finally {
        if (isFirstLoad) {
          trace.stop();
          isFirstLoad = false;
        }
      }
    });
  }
}
