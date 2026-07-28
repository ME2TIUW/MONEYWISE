import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_wise/data/models/user_model.dart';
import 'package:money_wise/data/services/auth_service.dart';
import 'package:money_wise/data/services/user_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  String? emailError;
  String? passwordError;

  void clearEmailError() {
    emailError = null;
    notifyListeners();
  }

  void clearPasswordError() {
    passwordError = null;
    notifyListeners();
  }

  void reset() {
    emailController.clear();
    passwordController.clear();
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool validateLoginForm({required String email, required String password}) {
    emailError = null;
    passwordError = null;
    bool isValid = true;

    if (email.isEmpty) {
      emailError = 'Email is required';
      isValid = false;
    }
    if (password.isEmpty) {
      passwordError = 'Password is required';
      isValid = false;
    }

    notifyListeners();
    return isValid;
  }

  Future<LoginResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    emailError = null;
    passwordError = null;
    notifyListeners();

    try {
      await _authService.signInWithEmail(email: email, password: password);

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated.');
      }

      final userData = await _userService.getUserByUid(user.uid);

      if (userData == null || !userData.isProfileCompleted) {
        return LoginResult.successGoInitialSetup;
      }

      return LoginResult.successGoHome;
    } catch (e) {
      String error = e.toString().replaceAll('Exception: ', '').trim();

      if (error == 'The email address is not valid.' ||
          error == 'No account found with this email.') {
        emailError = error;
      } else if (error == 'Incorrect password. Please try again.') {
        passwordError = error;
      } else if (error ==
          'Invalid email or password. Please check your credentials.') {
        emailError = error;
        passwordError = error;
      } else {
        errorMessage = error;
      }

      errorMessage ??= error;
      return LoginResult.failed;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<LoginResult> loginWithGoogle() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final userCredential = await _authService.signInWithGoogle();
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Google sign-in failed');
      }

      final userData = await _userService.getUserByUid(user.uid);

      if (userData == null) {
        await _userService.createUser(
          UserModel(
            uid: user.uid,
            name: user.displayName ?? '',
            email: user.email ?? '',
            isProfileCompleted: false,
            phone: null,
            budgetStartDate: null,
            financialGoal: null,
            monthlyBudget: null,
            allowFinancialAccess: null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        return LoginResult.successGoInitialSetup;
      }

      if (!userData.isProfileCompleted) {
        return LoginResult.successGoInitialSetup;
      }

      return LoginResult.successGoHome;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      return LoginResult.failed;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Email not registered');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email format');
      } else {
        throw Exception(e.message ?? 'Failed to send reset email');
      }
    }
  }
}

enum LoginResult { successGoHome, successGoInitialSetup, failed }
