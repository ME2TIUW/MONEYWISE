import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUserByUid(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data()!);
  }

  Future<double> getUserBudget(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return (doc.data()?['monthly_budget'] ?? 0.0).toDouble();
    }
    return 0.0;
  }

  Future<void> completeProfile({
    required String uid,
    required String phone,
    required double monthlyBudget,
    required DateTime budgetStartDate,
    DateTime? updatedAt,
    String? financialGoal,
  }) async {
    final currentMonthStr =
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}";

    await _db.collection('users').doc(uid).update({
      'phone': phone,
      'monthly_budget': monthlyBudget,
      'remaining_budget': monthlyBudget,
      'budget_start_date': Timestamp.fromDate(budgetStartDate),
      'financial_goal': financialGoal,
      'last_budget_month': currentMonthStr,
      'is_profile_completed': true,
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt) : null,
    });
  }

  Future<void> createUserIfNotExist(UserModel user) async {
    final docRef = _db.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set(user.toMap());
    }
  }

  Future<void> migrateRemainingBudget() async {
    print("🚀 [MIGRATION] Starting deep budget migration...");
    try {
      final usersSnapshot = await _db.collection('users').get();
      print("📋 [MIGRATION] Found ${usersSnapshot.docs.length} users.");

      final batch = _db.batch();
      int migratedCount = 0;

      for (var userDoc in usersSnapshot.docs) {
        final String uid = userDoc.id;
        final userData = userDoc.data();

        print("👤 [MIGRATION] Processing user: ${userData['name'] ?? uid}");

        final double monthlyBudget =
            (userData['monthly_budget'] as num?)?.toDouble() ?? 0.0;

        final transactionsSnapshot = await _db
            .collection('users')
            .doc(uid)
            .collection('transactions')
            .get();

        print(
          "  🔢 Found ${transactionsSnapshot.docs.length} transactions for this user.",
        );

        double totalDelta = 0.0;

        for (var txDoc in transactionsSnapshot.docs) {
          final txData = txDoc.data();
          double amount = (txData['amount'] as num?)?.toDouble() ?? 0.0;

          String typeStr = txData['type'].toString().toLowerCase();

          if (typeStr.contains('income')) {
            totalDelta += amount;
          } else {
            totalDelta -= amount;
          }
        }

        double trueRemainingBudget = monthlyBudget + totalDelta;
        print("  💰 New Remaining Budget calculated: $trueRemainingBudget");

        batch.update(userDoc.reference, {
          'remaining_budget': trueRemainingBudget,
        });
        migratedCount++;
      }

      if (migratedCount > 0) {
        await batch.commit();
        print(
          "✅ [MIGRATION] Successfully committed $migratedCount updates to Firestore.",
        );
      } else {
        print("⚠️ [MIGRATION] No users were updated.");
      }
    } catch (e, stacktrace) {
      print("❌ [MIGRATION] CRITICAL ERROR: $e");
      print(stacktrace);
    }
  }
}
