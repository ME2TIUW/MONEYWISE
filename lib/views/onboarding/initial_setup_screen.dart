import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_wise/components/labeled_field.dart';
import 'package:money_wise/helpers/alert_dialog_helper.dart';
import 'package:money_wise/data/services/toast_service.dart';
import 'package:money_wise/viewmodels/onboarding/initial_setup_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InitialSetup extends StatefulWidget {
  const InitialSetup({super.key});

  @override
  State<InitialSetup> createState() => _InitialSetupState();
}

class _InitialSetupState extends State<InitialSetup> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  DateTime _startDate = DateTime.now();
  String? _goal;

  final List<String> goals = [
    'Save money',
    'Control spending',
    'Track expenses',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider(
      create: (_) => InitialSetupViewModel(),
      child: Consumer<InitialSetupViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: AppBar(
              title: Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Text(
                  'Initial Setup',
                  style: TextStyle(
                    color: isDark ? Colors.white : colorScheme.primary,
                  ),
                ),
              ),
              backgroundColor: colorScheme.surface,
              foregroundColor: isDark ? Colors.white : Colors.black,
              elevation: 0,
              automaticallyImplyLeading: false,
            ),
            body: Padding(
              padding: EdgeInsets.all(24.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Let's set up your finances",
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),

                    SizedBox(height: 32.h),

                    LabeledField(
                      label: 'Phone Number',
                      child: TextField(
                        style: TextStyle(color: colorScheme.onSurface),
                        onChanged: (value) =>
                            viewModel.fieldErrors['phone'] = null,
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          errorText: viewModel.fieldErrors['phone'],
                          hintText: 'e.g. 081234567890',
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
                      label: 'Monthly Budget',
                      child: TextField(
                        style: TextStyle(color: colorScheme.onSurface),
                        onChanged: (value) =>
                            viewModel.fieldErrors['monthlyBudget'] = null,
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          errorText: viewModel.fieldErrors['monthlyBudget'],
                          hintText: 'e.g. 3000000',
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
                      label: 'Budget Start Date',
                      isRequired: false,
                      showAsterisk: false,
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );

                          if (picked != null) {
                            setState(() => _startDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
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
                          child: Text(
                            DateFormat('dd MMM yyyy').format(_startDate),
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10.h),

                    LabeledField(
                      label: 'Main Goal',
                      isRequired: false,
                      showAsterisk: false,
                      child: DropdownButtonFormField<String>(
                        dropdownColor: colorScheme.surface,
                        style: TextStyle(color: colorScheme.onSurface),
                        value: _goal,
                        hint: Text(
                          'Select your main goal',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.7,
                            ),

                            fontSize: 16.sp,
                          ),
                        ),
                        items: goals
                            .map(
                              (g) => DropdownMenuItem(value: g, child: Text(g)),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _goal = value);
                        },
                        decoration: InputDecoration(
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

                    SizedBox(height: 24.h),

                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                final success = await viewModel.completeProfile(
                                  phone: _phoneController.text,
                                  monthlyBudget: _budgetController.text,
                                  budgetStartDate: _startDate,
                                  goal: _goal,
                                );

                                if (!success &&
                                    viewModel.fieldErrors['general'] != null) {
                                  await showAppDialog(
                                    context,
                                    title: 'Setup Failed',
                                    message: viewModel.fieldErrors['general']!,
                                  );
                                }

                                if (success && mounted) {
                                  ToastService.showSuccess(
                                    'Initial Setup complete!',
                                  );
                                  Navigator.pushNamed(context, '/main-wrapper');
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
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: isDark
                                      ? colorScheme.onSurfaceVariant
                                      : colorScheme.onPrimary,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
