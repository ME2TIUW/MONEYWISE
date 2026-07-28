import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:money_wise/components/pie_chart.dart';
import 'package:money_wise/data/services/toast_service.dart';
import 'package:money_wise/viewmodels/finance/finance_viewmodel.dart';
import 'package:money_wise/viewmodels/profile/profile_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    final financeVM = context.read<FinanceViewModel>();
    final profileVM = context.read<ProfileViewModel>();
    Future.microtask(() async {
      financeVM.fetchTransactions();
      financeVM.fetchUserBudget();

      if (profileVM.user == null) {
        await profileVM.fetchProfile();
      }

      if (!context.mounted) return;

      _checkAndPromptNewMonth();
    });
  }

  double _getBudgetUsage(FinanceViewModel vm) {
    if (vm.monthlyBudget <= 0) return 0.0;

    double spentThisMonth = vm.currentMonthExpenses;

    if (spentThisMonth < 0) return 0.0;

    return (spentThisMonth / vm.monthlyBudget).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FinanceViewModel>();
    final profileViewModel = context.watch<ProfileViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final String rawFirstName =
        profileViewModel.user?.name.trim().split(' ').first ?? 'User';

    final String firstName = rawFirstName.isNotEmpty
        ? '${rawFirstName[0].toUpperCase()}${rawFirstName.substring(1).toLowerCase()}'
        : 'User';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        toolbarHeight: 70.h,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $firstName 👋',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Here is your financial summary',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        automaticallyImplyLeading: false,
      ),
      body: viewModel.isLoading
          ? _buildSkeletonLoader(isDark)
          : RefreshIndicator(
              color: colorScheme.primary,
              onRefresh: () async => await viewModel.fetchTransactions(),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),

                    _buildDynamicBudgetCard(
                      viewModel,
                      profileViewModel,
                      isDark,
                      colorScheme,
                    ),

                    SizedBox(height: 28.h),

                    _buildSummaryRow(viewModel, formatter, isDark),

                    SizedBox(height: 28.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Text(
                        'Spending Analysis',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade900
                            : const Color(0xFFF8F9FB),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade400,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDark ? 0.25 : 0.1,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildDateRangePicker(
                            context,
                            viewModel,
                            isDark,
                            colorScheme,
                          ),
                          SizedBox(height: 16.h),
                          SizedBox(
                            height: 250.h,
                            child: viewModel.allTransactions.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.receipt_long_outlined,
                                          size: 64.r,
                                          color: colorScheme.outline,
                                        ),
                                        SizedBox(height: 16.h),
                                        Text(
                                          'No transactions yet',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const PieChartSample2(),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    _buildMiniBudgetHealth(
                      viewModel,
                      formatter,
                      isDark,
                      colorScheme,
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
    );
  }

  void _showEditBudgetSheet(
    BuildContext context,
    ProfileViewModel profileVm,
    FinanceViewModel financeVm,
  ) {
    final budgetController = TextEditingController(
      text: profileVm.user?.monthlyBudget?.toStringAsFixed(0) ?? '',
    );
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          top: 24.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Monthly Budget',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                hintText: 'Enter new budget',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () async {
                  final newBudget = double.tryParse(budgetController.text) ?? 0;
                  if (profileVm.user != null) {
                    await profileVm.updateProfile(
                      name: profileVm.user!.name,
                      phone: profileVm.user!.phone ?? '',
                      newMonthlyBudget: newBudget,
                    );
                    await financeVm.fetchUserBudget();
                    if (context.mounted) Navigator.pop(context);
                    ToastService.showSuccess('Budget updated successfully!');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                ),
                child: Text(
                  'Save Budget',
                  style: TextStyle(color: colorScheme.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkAndPromptNewMonth() {
    final profileVM = context.read<ProfileViewModel>();
    final user = profileVM.user;

    if (user == null) return;

    final currentMonthStr =
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}";

    if (user.lastBudgetMonth != currentMonthStr) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNewMonthPrompt(context, profileVM);
      });
    }
  }

  void _showNewMonthPrompt(BuildContext context, ProfileViewModel profileVm) {
    final budgetController = TextEditingController(
      text: profileVm.user?.monthlyBudget?.toStringAsFixed(0) ?? '',
    );
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          top: 24.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to a New Month! 🎉',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Set your budget for this month. You can always change this later in your Profile.',
              style: TextStyle(
                fontSize: 14.sp,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 20.h),
            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                labelText: 'Target Budget',
                labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () async {
                  final newBudget = double.tryParse(budgetController.text) ?? 0;
                  await profileVm.handleNewMonthPrompt(newBudget: newBudget);

                  if (context.mounted) {
                    Navigator.pop(context, true);
                    ToastService.showSuccess('Budget Set for the Month!');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                ),
                child: Text(
                  'Start Month',
                  style: TextStyle(color: colorScheme.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((wasSaved) {
      if (wasSaved == null) {
        profileVm.handleNewMonthPrompt(newBudget: null);
        ToastService.showSuccess(
          'Using previous budget. You can edit this in Profile.',
        );
      }
    });
  }

  Widget _buildSummaryRow(
    FinanceViewModel vm,
    NumberFormat formatter,
    bool isDark,
  ) {
    double income = vm.currentMonthIncome;
    double expense = vm.currentMonthExpenses;

    return Row(
      children: [
        _buildStatCard(
          "Income",
          income,
          Colors.green,
          vm.incomeChangePercent,
          isDark,
        ),
        SizedBox(width: 12.w),
        _buildStatCard(
          "Expense",
          expense,
          Colors.red,
          vm.expenseChangePercent,
          isDark,
        ),
      ],
    );
  }

  Widget _buildDynamicBudgetCard(
    FinanceViewModel vm,
    ProfileViewModel profileVm,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final usage = _getBudgetUsage(vm);
    final remaining = vm.remainingBudget;

    Color themeColor = remaining < 0
        ? Colors.red
        : usage >= 0.8
        ? Colors.orangeAccent
        : colorScheme.primary;

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: themeColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(isDark ? 0.1 : 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                remaining < 0 ? 'Overspent By' : 'Remaining Budget',
                style: TextStyle(
                  color: isDark ? Colors.white : colorScheme.onPrimary,
                  fontSize: 12.sp,
                ),
              ),
              GestureDetector(
                onTap: () => _showEditBudgetSheet(context, profileVm, vm),
                child: Icon(
                  Icons.edit,
                  color: isDark ? Colors.white : colorScheme.onPrimary,
                  size: 16.sp,
                ),
              ),
            ],
          ),
          Text(
            formatter.format(remaining.abs()),
            style: TextStyle(
              color: isDark ? Colors.white : colorScheme.onPrimary,
              fontSize: 30.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          LinearProgressIndicator(
            value: usage,
            backgroundColor: isDark
                ? Colors.white.withOpacity(0.2)
                : colorScheme.onPrimary.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    double amount,
    Color color,
    double percentChange,
    bool isDark,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final isZero = percentChange == 0;
    final isPositive = percentChange > 0;

    final trendColor = isZero
        ? Colors.grey
        : isPositive
        ? Colors.green
        : Colors.red;

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.15 : 0.05),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withValues(alpha: 0.8)),
          boxShadow: [],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              formatter.format(amount),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? color.withOpacity(0.9) : color,
              ),
            ),
            if (isZero)
              Text(
                "No change",
                style: TextStyle(fontSize: 10.sp, color: Colors.grey),
              ),
            if (!isZero) SizedBox(height: 2.h),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14.sp,
                  color: trendColor,
                ),
                Text(
                  "${percentChange.abs().toStringAsFixed(1)}%",
                  style: TextStyle(color: trendColor, fontSize: 10.sp),
                ),
              ],
            ),
            if (!isZero) SizedBox(height: 2.h),
            Text(
              "vs last month",
              style: TextStyle(
                fontSize: 10.sp,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBudgetHealth(
    FinanceViewModel vm,
    NumberFormat formatter,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final usage = _getBudgetUsage(vm);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Monthly Budget Health",
                  style: TextStyle(
                    color: isDark
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onPrimary,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  vm.remainingBudget < 0
                      ? "Overspent"
                      : "${(usage * 100).toInt()}% Used",
                  style: TextStyle(
                    color: isDark
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 60.r,
            height: 60.r,
            child: CircularProgressIndicator(
              value: usage,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : colorScheme.onPrimary.withValues(alpha: 0.2),
              color: vm.remainingBudget < 0
                  ? Colors.red
                  : usage >= 0.8
                  ? Colors.orangeAccent
                  : Colors.white,
              strokeWidth: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangePicker(
    BuildContext context,
    FinanceViewModel viewModel,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final start = DateFormat('MMM d').format(viewModel.dateRange.start);
    final end = DateFormat('MMM d').format(viewModel.dateRange.end);

    return InkWell(
      onTap: () async {
        DateTimeRange? picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2024),
          lastDate: DateTime.now(),
          initialDateRange: viewModel.dateRange,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: isDark
                    ? ColorScheme.dark(
                        primary: colorScheme.primary,
                        onPrimary: colorScheme.onPrimary,
                        onSurface: colorScheme.onSurface,
                      )
                    : ColorScheme.light(
                        primary: colorScheme.primary,
                        onPrimary: colorScheme.onPrimary,
                        onSurface: colorScheme.onSurface,
                      ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          viewModel.updateDateRange(picked);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? colorScheme.outline : Colors.grey.shade400,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.date_range, size: 18.sp, color: colorScheme.primary),
                SizedBox(width: 10.w),
                Text(
                  "$start - $end",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 20.sp,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.h),

            Container(
              height: 150.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
              ),
            ),

            SizedBox(height: 20.h),

            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 90.h,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    height: 90.h,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            Container(
              height: 24.h,
              width: 160.w,
              color: isDark ? Colors.grey.shade900 : Colors.white,
            ),

            SizedBox(height: 12.h),

            Container(
              height: 320.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
              ),
            ),

            SizedBox(height: 24.h),

            Container(
              height: 100.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
