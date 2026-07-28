import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:money_wise/components/labeled_field.dart';
import 'package:money_wise/data/services/toast_service.dart';
import 'package:money_wise/helpers/alert_dialog_helper.dart';
import 'package:money_wise/core/constants/app_assets.dart';
import 'package:money_wise/viewmodels/auth/login_viewmodel.dart';
import 'package:money_wise/viewmodels/auth/register_viewmodel.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterState();
}

class _RegisterState extends State<RegisterScreen> with WidgetsBindingObserver {
  late RegisterViewModel _viewModel;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel = context.read<RegisterViewModel>();
  }

  @override
  void dispose() {
    _viewModel.password.clear();
    _viewModel.confirmPassword.clear();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      final vm = context.read<RegisterViewModel>();
      vm.password.clear();
      vm.confirmPassword.clear();
    }
  }

  void _showTermsDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            'Terms & Privacy Policy',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'By using Money Wise, you agree to manage your personal finances responsibly. Our AI-powered insights are tools for assistance, not professional financial advice.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Your data security is our priority. We use Firebase encryption to protect your transaction history. We do not sell your personal financial data to third parties. Data collected is used solely to improve your AI insights and budget tracking experience.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Last Updated: March 2026',
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RegisterViewModel>();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Text(
                'Create a new account',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),

              LabeledField(
                label: 'Full Name',
                child: TextField(
                  controller: viewModel.name,
                  onChanged: (value) {
                    if (viewModel.nameErrorMessage != null) {
                      viewModel.clearNameError();
                    }
                  },
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    errorText: viewModel.nameErrorMessage,
                    errorMaxLines: 2,
                    hintText: 'e.g. Budi Santoso',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                      fontSize: 16.sp,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: isDark
                            ? colorScheme.outline
                            : Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              LabeledField(
                label: 'Email Address',
                child: TextField(
                  controller: viewModel.email,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    if (viewModel.emailErrorMessage != null) {
                      viewModel.clearEmailError();
                    }
                  },
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    errorText: viewModel.emailErrorMessage,
                    errorMaxLines: 2,
                    hintText: 'e.g. budi@gmail.com',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                      fontSize: 16.sp,
                    ),
                    suffixIcon: Icon(
                      Icons.email_outlined,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: isDark
                            ? colorScheme.outline
                            : Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              LabeledField(
                label: 'Password',
                child: TextField(
                  controller: viewModel.password,
                  obscureText: _obscurePassword,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: colorScheme.onSurface,
                  ),
                  onChanged: (value) {
                    viewModel.validatePassword(
                      password: value,
                      confirmPassword: viewModel.confirmPassword.text,
                    );
                  },
                  decoration: InputDecoration(
                    errorText: viewModel.passwordErrorMessage,
                    errorMaxLines: 2,
                    hintText: 'At least 8 characters',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                      fontSize: 16.sp,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20.r,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: isDark
                            ? colorScheme.outline
                            : Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              LabeledField(
                label: 'Confirm Password',
                child: TextField(
                  controller: viewModel.confirmPassword,
                  obscureText: _obscureConfirmPassword,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: colorScheme.onSurface,
                  ),
                  onChanged: (value) {
                    viewModel.validateConfirmPassword(
                      password: viewModel.password.text,
                      confirmPassword: value,
                    );
                  },
                  decoration: InputDecoration(
                    errorText: viewModel.confirmPasswordErrorMessage,
                    errorMaxLines: 2,
                    hintText: 'Re-type your password',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                      fontSize: 16.sp,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20.r,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: isDark
                            ? colorScheme.outline
                            : Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              RichText(
                text: TextSpan(
                  text: 'By creating an account, you agree to our ',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                  children: [
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _showTermsDialog(context),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _showTermsDialog(context),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          if (viewModel.validateRegisterForm() == false) {
                            await showAppDialog(
                              context,
                              title: 'Registration Failed',
                              message:
                                  'Please resolve all required input validation fields.',
                            );
                            return;
                          }

                          final success = await viewModel.register(
                            name: viewModel.name.text,
                            email: viewModel.email.text,
                            password: viewModel.password.text,
                            confirmPassword: viewModel.confirmPassword.text,
                          );

                          if (!success && viewModel.errorMessage != null) {
                            await showAppDialog(
                              context,
                              title: 'Registration Failed',
                              message: viewModel.errorMessage!,
                            );
                          } else if (success) {
                            ToastService.showSuccess(
                              'Account created successfully! Please log in.',
                            );
                            viewModel.reset();
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: viewModel.isLoading
                      ? SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            color: colorScheme.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: isDark
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onPrimary,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: isDark
                          ? colorScheme.outline
                          : Colors.grey.shade300,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text(
                      'or continue with',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: isDark
                          ? colorScheme.outline
                          : Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              SizedBox(
                width: double.infinity,
                height: 60.h,
                child: IconButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          final result = await viewModel.registerWithGoogle();
                          if (result == LoginResult.failed &&
                              viewModel.errorMessage != null) {
                            await showAppDialog(
                              context,
                              title: 'Google Sign-Up Failed',
                              message: viewModel.errorMessage!,
                            );
                          } else if (result ==
                              LoginResult.successGoInitialSetup) {
                            Navigator.pushReplacementNamed(
                              context,
                              '/initial-setup',
                            );
                          } else if (result == LoginResult.successGoHome) {
                            Navigator.pushReplacementNamed(
                              context,
                              '/main-wrapper',
                            );
                          }
                        },
                  icon: SvgPicture.asset(
                    AppAssets.googleLogo,
                    width: 50.w,
                    height: 50.h,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }
}
