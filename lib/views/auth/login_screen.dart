import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_wise/components/labeled_field.dart';
import 'package:money_wise/core/constants/app_assets.dart';
import 'package:money_wise/data/services/toast_service.dart';
import 'package:money_wise/helpers/alert_dialog_helper.dart';
import 'package:money_wise/viewmodels/auth/login_viewmodel.dart';
import 'package:money_wise/views/auth/forgot_password_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> with WidgetsBindingObserver {
  late LoginViewModel _viewModel;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel = context.read<LoginViewModel>();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.passwordController.clear();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _viewModel.passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 25.h),

                      Container(
                        width: 80.w,
                        height: 80.h,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Transform.scale(
                          scale: 1,
                          child: SvgPicture.asset(
                            'assets/images/moneywise_logo_2.svg',
                            width: 80.w,
                            height: 80.h,
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),
                      Text.rich(
                        TextSpan(
                          text: 'Welcome to ',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          children: [
                            TextSpan(
                              text: 'M',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    colorScheme.primary, 
                                    const Color(
                                      0xFF00D2B4,
                                    ), 
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ).createShader(bounds),
                                child: Text(
                                  'oneyW',
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            TextSpan(
                              text: 'ise',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 6.h),

                      Text(
                        'Smart budgeting, simplified.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14.sp,
                          height: 1.4,
                        ),
                      ),

                      SizedBox(height: 22.h),

                      LabeledField(
                        label: 'Email',
                        isRequired: true,
                        showAsterisk: false,
                        child: TextField(
                          controller: _viewModel.emailController,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onChanged: (value) {
                            if (viewModel.emailError != null) {
                              viewModel.clearEmailError();
                            }
                          },
                          decoration: InputDecoration(
                            errorText: viewModel.emailError,
                            errorMaxLines: 2,
                            hintText: 'Enter your email',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: 16.sp,
                            ),
                            prefixIcon: Icon(
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

                      SizedBox(height: 16.h),

                      LabeledField(
                        label: 'Password',
                        isRequired: true,
                        showAsterisk: false,
                        child: TextField(
                          controller: _viewModel.passwordController,
                          obscureText: _obscurePassword,
                          onChanged: (value) {
                            if (viewModel.passwordError != null) {
                              viewModel.clearPasswordError();
                            }
                          },
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            errorText: viewModel.passwordError,
                            errorMaxLines: 2,
                            hintText: 'Enter your password',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: 16.sp,
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              size: 20.r,
                              color: colorScheme.onSurfaceVariant,
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

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider.value(
                                  value: context.read<LoginViewModel>(),
                                  child: const ForgotPasswordScreen(),
                                ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: viewModel.isLoading
                              ? null
                              : () async {
                                  if (viewModel.validateLoginForm(
                                        email: viewModel.emailController.text,
                                        password:
                                            viewModel.passwordController.text,
                                      ) ==
                                      false) {
                                    await showAppDialog(
                                      context,
                                      title: 'Sign-In Failed',
                                      message:
                                          'Please enter both email and password.',
                                    );
                                    return;
                                  }

                                  final result = await viewModel.loginWithEmail(
                                    email: viewModel.emailController.text,
                                    password: viewModel.passwordController.text,
                                  );

                                  if (result != LoginResult.failed) {
                                    viewModel.emailController.clear();
                                    viewModel.passwordController.clear();
                                    ToastService.showSuccess(
                                      'Sign In Success! ',
                                    );
                                  }

                                  if (result == LoginResult.failed &&
                                      viewModel.errorMessage != null) {
                                    await showAppDialog(
                                      context,
                                      title: 'Sign-In Failed',
                                      message: viewModel.errorMessage!,
                                    );
                                  } else if (result ==
                                      LoginResult.successGoInitialSetup) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/initial-setup',
                                    );
                                  } else if (result ==
                                      LoginResult.successGoHome) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/main-wrapper',
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: viewModel.isLoading
                              ? CircularProgressIndicator(
                                  color: colorScheme.onPrimary,
                                )
                              : Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: isDark
                                        ? colorScheme.onSurfaceVariant
                                        : colorScheme.onPrimary,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: 28.h),

                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: isDark
                                  ? colorScheme.outlineVariant
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
                                  ? colorScheme.outlineVariant
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
                                  final result = await viewModel
                                      .loginWithGoogle();

                                  if (result == LoginResult.failed &&
                                      viewModel.errorMessage != null) {
                                    await showAppDialog(
                                      context,
                                      title: 'Sign-In Failed',
                                      message: viewModel.errorMessage!,
                                    );
                                  } else if (result ==
                                      LoginResult.successGoInitialSetup) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/initial-setup',
                                    );
                                  } else if (result ==
                                      LoginResult.successGoHome) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/home',
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

                      const Spacer(),
                      SizedBox(height: 12.h),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
