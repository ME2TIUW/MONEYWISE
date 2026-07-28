import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_wise/data/models/user_model.dart';
import 'package:money_wise/viewmodels/auth/login_viewmodel.dart';
import 'package:money_wise/viewmodels/auth/register_viewmodel.dart';
import 'package:money_wise/viewmodels/finance/finance_viewmodel.dart';
import 'package:money_wise/viewmodels/moni/moni_viewmodel.dart';

class ProfileViewModel extends ChangeNotifier {
  UserModel? user;
  bool isLoading = false;
  String? errorMessage;

  RegisterViewModel? _registerVM;
  LoginViewModel? _loginVM;
  FinanceViewModel? _financeVM;
  MoniViewModel? _moniVM;

  void updateDependencies(
    RegisterViewModel register,
    LoginViewModel login,
    FinanceViewModel finance,
    MoniViewModel moni,
  ) {
    _registerVM = register;
    _loginVM = login;
    _financeVM = finance;
    _moniVM = moni;
  }

  void reset() {
    user = null;
    isLoading = false;
    errorMessage = null;
    _registerVM?.reset();
    _loginVM?.reset();
    _financeVM?.reset();
    _moniVM?.reset();
    notifyListeners();
  }

  Future<void> fetchProfile({bool isRefresh = false}) async {
    try {
      if (!isRefresh) {
        isLoading = true;
        notifyListeners();
      }

      final uid = FirebaseAuth.instance.currentUser!.uid;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        user = UserModel.fromMap(doc.data()!);
      } else {
        throw Exception("User document does not exist");
      }
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("Fetch Profile Error: $e");
    } finally {
      if (!isRefresh) {
        isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> handleNewMonthPrompt({double? newBudget}) async {
    try {
      if (user == null) return;
      final uid = user!.uid;
      final currentMonthStr =
          "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}";

      Map<String, dynamic> updates = {
        'last_budget_month':
            currentMonthStr, 
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (newBudget != null) {
        updates['monthly_budget'] = newBudget;
        updates['remaining_budget'] = FieldValue.increment(newBudget);
      } else {
        updates['remaining_budget'] = FieldValue.increment(
          user!.monthlyBudget ?? 0.0,
        );
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update(updates);

      await fetchProfile();
      _financeVM?.fetchUserBudget();
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("New Month Update Error: $e");
    }
  }

  Future<void> uploadProfileImage(File imageFile) async {
    try {
      isLoading = true;
      notifyListeners();

      final uid = FirebaseAuth.instance.currentUser!.uid;

      final bytes = await imageFile.readAsBytes();

      final base64String = base64Encode(bytes);
      final dataUri = 'data:image/jpeg;base64,$base64String';

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profile_image_url': dataUri,
        'updated_at': FieldValue.serverTimestamp(),
      });

      await fetchProfile();
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("Base64 Upload Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProfileImage() async {
    try {
      isLoading = true;
      notifyListeners();

      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profile_image_url': FieldValue.delete(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      await fetchProfile();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required double newMonthlyBudget,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final uid = user!.uid;

      final oldMonthlyBudget = user!.monthlyBudget ?? 0.0;
      final delta = newMonthlyBudget - oldMonthlyBudget;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': name,
        'phone': phone,
        'monthly_budget': newMonthlyBudget,
        'remaining_budget': FieldValue.increment(delta),
        'updated_at': FieldValue.serverTimestamp(),
      });

      await fetchProfile();
      _financeVM?.fetchUserBudget();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateFinancialAccess(bool allow) async {
    try {
      final uid = user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'allow_financial_access': allow,
        'updated_at': FieldValue.serverTimestamp(),
      });

      await fetchProfile();

      _financeVM?.fetchUserBudget();

      // user = UserModel(
      //   uid: user!.uid,
      //   name: user!.name,
      //   email: user!.email,
      //   phone: user!.phone,
      //   monthlyBudget: user!.monthlyBudget,
      //   createdAt: user!.createdAt,
      //   updatedAt: DateTime.now(),
      //   isProfileCompleted: user!.isProfileCompleted,
      //   budgetStartDate: user!.budgetStartDate,
      //   financialGoal: user!.financialGoal,
      //   allowFinancialAccess: allow,
      // );

      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null || user.email == null) {
        throw Exception('User not logged in');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        errorMessage = 'The current password you entered is incorrect.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The new password is too weak.';
      } else {
        errorMessage = e.message ?? 'An error occurred during password change.';
      }
      rethrow;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      reset();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint("Logout Error: $e");
    }
  }
}
