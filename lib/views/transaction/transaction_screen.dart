import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_wise/components/labeled_field.dart';
import 'package:money_wise/core/utils/formatters/currency_formatter.dart';
import 'package:money_wise/data/services/toast_service.dart';
import 'package:money_wise/helpers/alert_dialog_helper.dart';
import 'package:money_wise/viewmodels/finance/finance_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:money_wise/domain/entities/transaction_entity.dart';
import 'package:money_wise/data/models/transaction_model.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  TransactionType _selectedType = TransactionType.expense;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FinanceViewModel>();

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Transaction Input',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 16.h),

              _buildTypeSelector(),

              SizedBox(height: 20.h),

              _buildAmountField(viewModel),

              SizedBox(height: 20.h),

              _buildCategoryField(viewModel),

              SizedBox(height: 20.h),

              _buildMerchantField(viewModel),

              SizedBox(height: 24.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PRODUCT ITEMS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => viewModel.addLineItem(),
                    icon: Icon(
                      Icons.add_circle_outline,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    label: Text(
                      'Add Item',
                      style: TextStyle(color: colorScheme.primary),
                    ),
                  ),
                ],
              ),
              ...viewModel.lineItems.asMap().entries.map(
                (entry) => _buildItemCard(viewModel, entry.value, entry.key),
              ),

              SizedBox(height: 24.h),

              _buildDateAndNoteFields(viewModel),

              SizedBox(height: 40.h),

              _buildSaveButton(context, viewModel),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LabeledField(
      label: 'Type',
      isRequired: true,
      showAsterisk: false,
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<TransactionType>(
          segments: [
            ButtonSegment(
              value: TransactionType.expense,
              label: Text('Expense'),
            ),
            ButtonSegment(value: TransactionType.income, label: Text('Income')),
          ],
          selected: {_selectedType},
          onSelectionChanged: (val) =>
              setState(() => _selectedType = val.first),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.selected)) {
                return colorScheme.primary;
              }
              return colorScheme.surface;
            }),

            foregroundColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return colorScheme.onSurfaceVariant;
            }),

            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            side: WidgetStateProperty.all(
              BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.12)
                    : Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField(FinanceViewModel vm) {
    return LabeledField(
      label: 'Amount',
      isRequired: true,
      child: Column(
        children: [
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Rp',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(width: 2.w),
                IntrinsicWidth(
                  child: TextField(
                    controller: vm.amountController,
                    inputFormatters: [RupiahInputFormatter()],
                    keyboardType: TextInputType.number,
                    onChanged: (val) =>
                        vm.validateAmount(val.replaceAll('.', '')),
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (vm.amountErrorMessage != null)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Center(
                child: Text(
                  vm.amountErrorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 12.sp),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryField(FinanceViewModel vm) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LabeledField(
      label: 'Category',
      isRequired: true,
      child: DropdownButtonFormField<String>(
        value: vm.selectedCategory,
        hint: Text(
          'Select category',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        onChanged: (val) => vm.setCategory(val),
        dropdownColor: colorScheme.surface,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.category_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
          errorText: vm.categoryErrorMessage,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          filled: true,
          fillColor: colorScheme.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.12)
                  : Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
        ),
        items: vm.categories
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
      ),
    );
  }

  Widget _buildMerchantField(FinanceViewModel vm) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LabeledField(
      label: 'Merchant',
      isRequired: false,
      showAsterisk: false,
      child: TextField(
        controller: vm.merchantController,
        decoration: InputDecoration(
          hintText: 'Enter merchant name',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(
            Icons.store_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          filled: true,
          fillColor: colorScheme.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.12)
                  : Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(FinanceViewModel vm, TransactionItem item, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.12) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Product Name',
                    border: InputBorder.none,
                    isDense: true,
                    hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  onChanged: (val) => vm.updateLineItem(index, name: val),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
                onPressed: () => vm.removeLineItem(index),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 60.w,
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Qty',
                    isDense: true,
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  onChanged: (val) =>
                      vm.updateLineItem(index, qty: int.tryParse(val) ?? 1),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [RupiahInputFormatter()],
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    prefixText: 'Rp ',
                    prefixStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12.sp,
                    ),
                    isDense: true,
                  ),
                  onChanged: (val) => vm.updateLineItem(
                    index,
                    price: double.tryParse(val.replaceAll('.', '')) ?? 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateAndNoteFields(FinanceViewModel vm) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LabeledField(
            label: 'Date',
            isRequired: true,
            child: InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: vm.selectedDate,
                  firstDate: DateTime(2024),
                  lastDate: DateTime.now(),
                );
                if (picked != null) vm.setSelectedDate(picked);
              },
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.12)
                        : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      vm.selectedDate.day == DateTime.now().day &&
                              vm.selectedDate.month == DateTime.now().month
                          ? 'Today'
                          : "${vm.selectedDate.day}/${vm.selectedDate.month}/${vm.selectedDate.year}",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: LabeledField(
            label: 'Note',
            isRequired: false,
            showAsterisk: false,
            child: TextField(
              controller: vm.noteController,
              decoration: InputDecoration(
                hintText: 'Beli bakso...',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                suffixIcon: Icon(
                  Icons.edit_note,
                  color: colorScheme.onSurfaceVariant,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: colorScheme.surface,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.12)
                        : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, FinanceViewModel vm) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        onPressed: vm.isLoading
            ? null
            : () async {
                String cleanAmountText = vm.amountController.text.replaceAll(
                  RegExp(r'[^0-9]'),
                  '',
                );
                double inputAmount = double.tryParse(cleanAmountText) ?? 0;

                if (_selectedType == TransactionType.expense) {
                  if (vm.willExceedBudget(inputAmount)) {
                    final bool? proceed = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        final colorScheme = Theme.of(context).colorScheme;
                        return AlertDialog(
                          backgroundColor: colorScheme.surface,
                          surfaceTintColor: colorScheme.surface,
                          title: Text(
                            'Budget Warning',
                            style: TextStyle(color: colorScheme.onSurface),
                          ),
                          content: Text(
                            'This transaction will exceed your monthly budget. Do you still want to save it?',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                'Proceed',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                    if (proceed != true) return;
                  }
                }

                final success = await vm.addTransaction(_selectedType);
                if (success && mounted) {
                  ToastService.showSuccess('Transaction added successfully!');
                  Navigator.pushNamed(context, '/main-wrapper');
                } else if (vm.errorMessage != null) {
                  await showAppDialog(
                    context,
                    title: 'Transaction Failed',
                    message: vm.errorMessage!,
                  );
                }
              },
        child: vm.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'Save Transaction',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
      ),
    );
  }
}
