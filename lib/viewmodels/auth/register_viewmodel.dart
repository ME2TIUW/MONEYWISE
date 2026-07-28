import 'package:flutter/material.dart';
import 'package:money_wise/data/models/user_model.dart';
import 'package:money_wise/data/services/auth_service.dart';
import 'package:money_wise/data/services/user_service.dart';
import 'package:money_wise/viewmodels/auth/login_viewmodel.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  String? _nameErrorMessage;
  String? _emailErrorMessage;
  String? _passwordErrorMessage;
  String? _confirmPasswordErrorMessage;
  String? errorMessage;

  String? get nameErrorMessage => _nameErrorMessage;
  String? get emailErrorMessage => _emailErrorMessage;
  String? get passwordErrorMessage => _passwordErrorMessage;
  String? get confirmPasswordErrorMessage => _confirmPasswordErrorMessage;

  TextEditingController get name => _nameController;
  TextEditingController get email => _emailController;
  TextEditingController get password => _passwordController;
  TextEditingController get confirmPassword => _confirmPasswordController;

  void clearNameError() {
    _nameErrorMessage = null;
    notifyListeners();
  }

  void clearEmailError() {
    _emailErrorMessage = null;
    notifyListeners();
  }

  void clearPasswordError() {
    _passwordErrorMessage = null;
    notifyListeners();
  }

  void clearConfirmPasswordError() {
    _confirmPasswordErrorMessage = null;
    notifyListeners();
  }

  void reset() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();

    _nameErrorMessage = null;
    _emailErrorMessage = null;
    _passwordErrorMessage = null;
    _confirmPasswordErrorMessage = null;
    errorMessage = null;
    isLoading = false;

    notifyListeners();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool validateRegisterForm() {
    _nameErrorMessage = null;
    _emailErrorMessage = null;
    _passwordErrorMessage = null;
    _confirmPasswordErrorMessage = null;
    bool isValid = true;

    if (_nameController.text.trim().isEmpty) {
      _nameErrorMessage = 'Full name is required.';
      isValid = false;
    }

    if (_emailController.text.trim().isEmpty) {
      _emailErrorMessage = 'Email address is required.';
      isValid = false;
    }

    if (_passwordController.text.isEmpty) {
      _passwordErrorMessage = 'Password is required.';
      isValid = false;
    } else if (_passwordController.text.length < 8) {
      _passwordErrorMessage = 'Password must be at least 8 characters long.';
      isValid = false;
    }

    if (_confirmPasswordController.text.isEmpty) {
      _confirmPasswordErrorMessage = 'Confirm password is required.';
      isValid = false;
    } else if (_passwordController.text != _confirmPasswordController.text) {
      _confirmPasswordErrorMessage = 'Passwords do not match.';
      isValid = false;
    }

    notifyListeners();
    return isValid;
  }

  void validatePassword({
    required String password,
    required String confirmPassword,
  }) {
    if (password.isEmpty) {
      _passwordErrorMessage = 'Password is required.';
    } else if (password.length < 8) {
      _passwordErrorMessage = 'Password must be at least 8 characters long.';
    } else {
      _passwordErrorMessage = null;
    }

    if (confirmPassword.isNotEmpty) {
      validateConfirmPassword(
        password: password,
        confirmPassword: confirmPassword,
      );
    }
    notifyListeners();
  }

  void validateConfirmPassword({
    required String password,
    required String confirmPassword,
  }) {
    if (confirmPassword.isEmpty) {
      _confirmPasswordErrorMessage = 'Confirm password is required.';
    } else if (password != confirmPassword) {
      _confirmPasswordErrorMessage = 'Passwords do not match.';
    } else {
      _confirmPasswordErrorMessage = null;
    }
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    isLoading = true;
    errorMessage = null;
    _nameErrorMessage = null;
    _emailErrorMessage = null;
    _passwordErrorMessage = null;
    _confirmPasswordErrorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.registerWithEmail(
        email: email,
        password: password,
        name: name,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('User creation failed.');
      }

      final userModel = UserModel(
        uid: user.uid,
        name: name,
        email: user.email!,
        isProfileCompleted: false,
        allowFinancialAccess: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _userService.createUser(userModel);
      return true;
    } catch (e) {
      String error = e.toString().replaceAll('Exception: ', '').trim();

      if (error == 'The email address is not valid.' ||
          error == 'The email address is already used by another account.') {
        _emailErrorMessage = error;
      } else {
        errorMessage = error;
      }
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<LoginResult> registerWithGoogle() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final credential = await _authService.signInWithGoogle();
      final user = credential.user;

      if (user == null) {
        throw Exception('Google sign-in failed');
      }

      final userExist = await _userService.getUserByUid(user.uid);

      if (userExist == null) {
        final userModel = UserModel(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          budgetStartDate: null,
          financialGoal: null,
          monthlyBudget: null,
          phone: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isProfileCompleted: false,
          allowFinancialAccess: null,
        );

        await _userService.createUser(userModel);
        return LoginResult.successGoInitialSetup;
      }

      if (!userExist.isProfileCompleted) {
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
}
