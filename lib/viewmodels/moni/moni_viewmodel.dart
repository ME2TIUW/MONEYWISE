import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_wise/domain/entities/transaction_entity.dart';
import 'package:money_wise/data/models/moni_model.dart';
import 'package:money_wise/data/models/transaction_model.dart';
import 'package:money_wise/data/models/user_model.dart';
import 'package:money_wise/data/services/gemini_service.dart';

class MoniViewModel extends ChangeNotifier {
  final List<MoniModel> _messages = [];
  bool _isTyping = false;
  final GeminiService _geminiService = GeminiService();
  UserModel? currentUser;
  List<TransactionModel> userTransaction = [];

  final TextEditingController chatController = TextEditingController();

  List<MoniModel> get messages => _messages;
  bool get isTyping => _isTyping;

  void reset() {
    _messages.clear();
    chatController.clear();
    _isTyping = false;
    notifyListeners();
  }

  @override
  void dispose() {
    chatController.dispose();
    super.dispose();
  }

  String buildMultiTierContext({
    required UserModel user,
    required List<TransactionModel> transactions,
  }) {
    final now = DateTime.now();
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    String context = "---BUDGET & GOALS ---\n";
    context += "Monthly Budget: ${formatter.format(user.monthlyBudget ?? 0)}\n";
    context += "Financial Goal: ${user.financialGoal ?? 'Not set'}\n\n";

    double monthlySpent = 0;
    Map<String, double> categoryTotals = {};

    for (var t in transactions) {
      if (t.type == TransactionType.expense && t.date.month == now.month) {
        monthlySpent += t.amount;
        categoryTotals[t.category] =
            (categoryTotals[t.category] ?? 0) + t.amount;
      }
    }

    context += "--- MONTHLY TOTALS ---\n";
    context +=
        "Total Spent in ${DateFormat('MMMM').format(now)}: ${formatter.format(monthlySpent)}\n";
    context += "Remaining Budget: ${formatter.format(user.remainingBudget)}\n";
    context += "Spending by Category:\n";
    categoryTotals.forEach(
      (cat, val) => context += "- $cat: ${formatter.format(val)}\n",
    );

    context += "\n--- RECENT TRANSACTIONS ---\n";
    final recent = transactions.take(10);
    for (var t in recent) {
      context +=
          "- ${DateFormat('dd MMM').format(t.date)}: ${formatter.format(t.amount)} at ${t.merchant ?? t.category}\n";
    }

    return context;
  }

  Future<String> buildUserFinancialContext(
    UserModel user,
    List<TransactionModel> transaction,
  ) async {
    double totalExpense = 0;
    double totalIncome = 0;

    for (var t in transaction) {
      if (t.type.name == 'expense') {
        totalExpense += t.amount;
      } else {
        totalIncome += t.amount;
      }
    }

    return """
            User Financial Data:
            Name: ${user.name}
            Monthly Budget: Rp ${user.monthlyBudget ?? 0}

            Total Income This Month: Rp $totalIncome
            Total Expense This Month: Rp $totalExpense

            Number of Transaction: ${transaction.length}

            Provide financial advice based on this data.
        """;
  }

  // Future<void> updateFinancialAccess(bool allow) async {
  //   final uid = currentUser!.uid;

  //   await FirebaseFirestore.instance.collection('users').doc(uid).update({
  //     "allow_financial_access": allow,
  //     'update_at': FieldValue.serverTimestamp()
  //   });

  //   currentUser = UserModel(
  //     uid: currentUser!.uid,
  //     name: currentUser!.name,
  //     email: currentUser!.email,
  //     phone: currentUser!.phone,
  //     monthlyBudget: currentUser!.monthlyBudget,
  //     createdAt: currentUser!.createdAt,
  //     updatedAt: DateTime.now(),
  //     isProfileCompleted: currentUser!.isProfileCompleted,
  //     budgetStartDate: currentUser!.budgetStartDate,
  //     financialGoal: currentUser!.financialGoal,
  //     allowFinancialAccess: allow,
  //   );

  //   notifyListeners();
  // }

  Future<void> sendMessage(
    String text, {
    UserModel? user,
    List<TransactionModel>? transactions,
  }) async {
    if (text.trim().isEmpty) return;

    _messages.add(
      MoniModel(text: text, sender: ChatSender.user, time: DateTime.now()),
    );
    _isTyping = true;
    notifyListeners();

    try {
      String financialContext = '';

      if (user?.allowFinancialAccess == true) {
        financialContext = buildMultiTierContext(
          user: user!,
          transactions: transactions ?? [],
        );
      } else {
        financialContext = "User has not granted financial access permission.";
      }

      final botReply = await _geminiService.sendPrompt(text, financialContext);

      _messages.add(
        MoniModel(text: botReply, sender: ChatSender.bot, time: DateTime.now()),
      );
    } catch (e) {
      _messages.add(
        MoniModel(
          text: 'Moni encountered an error',
          sender: ChatSender.bot,
          time: DateTime.now(),
        ),
      );
    }

    _isTyping = false;
    notifyListeners();
  }
}
