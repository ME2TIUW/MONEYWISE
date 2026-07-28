import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_wise/data/models/transaction_model.dart';
import 'package:money_wise/domain/entities/transaction_entity.dart';
import 'package:money_wise/viewmodels/finance/finance_viewmodel.dart';
import 'package:money_wise/data/services/toast_service.dart';
import 'package:money_wise/viewmodels/profile/profile_viewmodel.dart';
import 'package:money_wise/components/edit_transaction_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final vm = context.read<FinanceViewModel>();
      vm.fetchTransactions();
      vm.fetchUserBudget();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FinanceViewModel>();
    final profileVm = context.watch<ProfileViewModel>();

    final displayTransactions = viewModel.filteredTransactions;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Financial History',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: viewModel.isLoading || profileVm.isLoading
            ? Center(child: _buildSkeletonLoader())
            : RefreshIndicator(
                onRefresh: () async {
                  await viewModel.fetchTransactions();
                  await viewModel.fetchUserBudget();
                  await profileVm.fetchProfile();
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Transactions',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            InkWell(
                              onTap: () =>
                                  _showFilterBottomSheet(context, viewModel),
                              borderRadius: BorderRadius.circular(8.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: viewModel.hasActiveFilters
                                      ? colorScheme.primary.withOpacity(0.12)
                                      : isDark
                                      ? colorScheme.surfaceContainerHighest
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.filter_list,
                                      size: 18.sp,
                                      color: viewModel.hasActiveFilters
                                          ? Theme.of(context).primaryColor
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'Filter',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: viewModel.hasActiveFilters
                                            ? colorScheme.primary
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    displayTransactions.isEmpty
                        ? _buildEmptyState(viewModel.hasActiveFilters)
                        : SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final transaction = displayTransactions[index];
                              return _buildTransactionTile(
                                context,
                                transaction,
                                viewModel,
                              );
                            }, childCount: displayTransactions.length),
                          ),
                  ],
                ),
              ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, FinanceViewModel vm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    DateTime? tempMonth = vm.selectedFilterMonth;
    TransactionType? tempType = vm.selectedFilterType;
    String? tempCategory = vm.selectedFilterCategory;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 20.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Transactions',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            tempMonth = null;
                            tempType = null;
                            tempCategory = null;
                          });
                        },
                        child: Text(
                          'Reset',
                          style: TextStyle(color: Colors.red, fontSize: 14.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  Text(
                    'Month',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark
                            ? colorScheme.outlineVariant
                            : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<DateTime?>(
                        dropdownColor: colorScheme.surface,
                        style: TextStyle(color: colorScheme.onSurface),
                        isExpanded: true,
                        hint: Text('All Time', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        value: tempMonth,
                        items: [
                          const DropdownMenuItem<DateTime?>(
                            value: null,
                            child: Text('All Time'),
                          ),
                          ...vm.availableFilterMonths.map((date) {
                            return DropdownMenuItem<DateTime?>(
                              value: date,
                              child: Text(DateFormat('MMMM yyyy').format(date)),
                            );
                          }),
                        ],
                        onChanged: (val) => setState(() => tempMonth = val),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  Text(
                    'Type',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      _buildFilterChip(
                        'All',
                        tempType == null,
                        () => setState(() => tempType = null),
                      ),
                      SizedBox(width: 8.w),
                      _buildFilterChip(
                        'Income',
                        tempType == TransactionType.income,
                        () => setState(() => tempType = TransactionType.income),
                      ),
                      SizedBox(width: 8.w),
                      _buildFilterChip(
                        'Expense',
                        tempType == TransactionType.expense,
                        () =>
                            setState(() => tempType = TransactionType.expense),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  Text(
                    'Category',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _buildFilterChip(
                        'All',
                        tempCategory == null,
                        () => setState(() => tempCategory = null),
                      ),
                      ...vm.categories.map(
                        (cat) => _buildFilterChip(
                          cat,
                          tempCategory == cat,
                          () => setState(() => tempCategory = cat),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),

                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () {
                        vm.setFilterMonth(tempMonth);
                        vm.setFilterType(tempType);
                        vm.setFilterCategory(tempCategory);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : isDark
                ? Colors.white.withOpacity(0.12)
                : Colors.grey.shade300,
                width: isSelected ? 1.5 : 1
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTile(
    BuildContext context,
    TransactionModel transaction,
    FinanceViewModel viewModel,
  ) {
    final isExpense = transaction.type == TransactionType.expense;
    final hasItems = transaction.items.isNotEmpty;
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final icon = _getCategoryIcon(transaction.category);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: isDark ? colorScheme.outlineVariant : Colors.grey.shade100, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.primary.withOpacity(0.18)
                  : colorScheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.white : Theme.of(context).primaryColor,
              size: 22.sp,
            ),
          ),

          SizedBox(width: 14.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        (transaction.merchant?.trim().isEmpty ?? true)
                            ? transaction.category
                            : transaction.merchant!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    SizedBox(width: 8.w),

                    Text(
                      '${isExpense ? "-" : "+"} ${formatter.format(transaction.amount)}',
                      style: TextStyle(
                        color: isExpense
                            ? const Color(0xFFE53E3E)
                            : const Color(0xFF38A169),
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),

                    SizedBox(width: 6.w),

                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      color: isDark ? const Color(0xFF161616) : colorScheme.surface,
                      surfaceTintColor: colorScheme.surface,

                      child: Icon(
                        Icons.more_vert,
                        color: colorScheme.onSurfaceVariant,
                        size: 20.sp,
                      ),
                      elevation:
                          4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(
                          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade100,
                          width: 1,
                        ),
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          viewModel.loadTransactionForEdit(transaction);
                          EditTransactionDialog.show(
                            context,
                            transaction,
                            viewModel,
                          );
                        } else if (value == 'delete') {
                          _showDeleteDialog(context, transaction.id, viewModel);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                color: colorScheme.primary,
                                size: 18.sp,
                              ),
                              SizedBox(width: 12.w),
                              Text('Edit', style: TextStyle(fontSize: 14.sp, color: colorScheme.onSurface)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: const Color(0xFFE53E3E),
                                size: 18.sp,
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFFE53E3E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 4.h),

                Text(
                  hasItems
                      ? "${transaction.items.length} items • ${DateFormat('HH:mm').format(transaction.date)}"
                      : DateFormat(
                          'HH:mm • d MMM yyyy',
                        ).format(transaction.date),
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String id, FinanceViewModel vm) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surface,
        title: Text('Delete?', style: TextStyle(color: colorScheme.onSurface)),
        content: Text('Remove this transaction?', style: TextStyle(color: colorScheme.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await vm.deleteTransaction(id);
              if (context.mounted) Navigator.pop(context);
              ToastService.showSuccess('Deleted');
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool hasFilters) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters
                  ? Icons.filter_alt_off_outlined
                  : Icons.receipt_long_outlined,
              size: 64.r,
              color: colorScheme.outlineVariant,
            ),
            SizedBox(height: 16.h),
            Text(
              hasFilters
                  ? 'No transactions match filters'
                  : 'No transactions yet',
              style: TextStyle(fontSize: 16.sp, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food & Drinks':
        return Icons.restaurant_outlined;
      case 'Transport':
        return Icons.directions_car_outlined;
      case 'Shopping':
        return Icons.shopping_bag_outlined;
      case 'Entertainment':
        return Icons.movie_outlined;
      case 'Bills & Utilities':
        return Icons.receipt_long_outlined;
      case 'Health':
        return Icons.health_and_safety_outlined;
      case 'Income/Salary':
        return Icons.attach_money_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Widget _buildSkeletonLoader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Container(
                height: 20.h,
                width: 150.w,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 140.w,
                            height: 14.h,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade900 : Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            width: 90.w,
                            height: 12.h,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade900 : Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }, childCount: 8),
          ),
        ],
      ),
    );
  }
}
