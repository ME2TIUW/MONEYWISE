import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_wise/data/services/user_service.dart';

class InitialSetupViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;

  final Map<String, String?> fieldErrors = {};
  Map<String, String?> get getFieldErrors => fieldErrors;

  Future<bool> completeProfile({
    required String phone,
    required String monthlyBudget,
    required DateTime budgetStartDate,
    String? goal,
  }) async {
    fieldErrors.clear();

    if (phone.isEmpty) fieldErrors['phone'] = 'This field is required.';

    final parsedBudget = double.tryParse(monthlyBudget);
    if (monthlyBudget.isEmpty) {
      fieldErrors['monthlyBudget'] = 'This field is required.';
    } else if (parsedBudget == null || parsedBudget <= 0) {
      fieldErrors['monthlyBudget'] = 'Monthly budget must be a valid number.';
      notifyListeners();
      return false;
    }

    if (fieldErrors.isNotEmpty) {
      notifyListeners();
      return false;
    }

    final user = _auth.currentUser;
    if (user == null) {
      fieldErrors['general'] = 'User not authenticated.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      await _userService.completeProfile(
        uid: user.uid,
        phone: phone,
        monthlyBudget: parsedBudget!,
        budgetStartDate: budgetStartDate,
        financialGoal: goal,
        updatedAt: DateTime.now(),
      );

      return true;
    } catch (e) {
      fieldErrors['general'] = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
