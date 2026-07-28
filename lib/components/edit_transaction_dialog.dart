import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_wise/data/models/transaction_model.dart';
import 'package:money_wise/viewmodels/finance/finance_viewmodel.dart';
import 'package:money_wise/core/utils/formatters/currency_formatter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EditTransactionDialog extends StatefulWidget {
  final TransactionModel transaction;
  final FinanceViewModel viewModel;

  const EditTransactionDialog({
    super.key,
    required this.transaction,
    required this.viewModel,
  });

  static Future<void> show(
    BuildContext context,
    TransactionModel transaction,
    FinanceViewModel viewModel,
  ) {
    return showDialog(
      context: context,
      builder: (context) =>
          EditTransactionDialog(transaction: transaction, viewModel: viewModel),
    );
  }

  @override
  State<EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<EditTransactionDialog> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FinanceViewModel>();

    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surface,
      title: Text(
        'Edit Transaction',
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: vm.amountController,
                inputFormatters: [RupiahInputFormatter()],
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  context,
                  'Total Amount',
                ).copyWith(prefixText: 'Rp '),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 16.h),

              TextField(
                controller: vm.merchantController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: _inputDecoration(context, 'Merchant'),
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                value: vm.selectedCategory,
                items: vm.categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => vm.setCategory(val),
                decoration: _inputDecoration(context, 'Category'),
                dropdownColor: colorScheme.surface,
                style: TextStyle(color: colorScheme.onSurface),
              ),

              const Divider(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LINE ITEMS',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => vm.addLineItem(),
                    icon: Icon(Icons.add, size: 16, color: colorScheme.primary),
                    label: Text(
                      'Add Item',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),

              ...vm.lineItems.asMap().entries.map(
                (entry) => _buildItemEditCard(vm, entry.key, entry.value),
              ),

              SizedBox(height: 16.h),
              TextField(
                controller: vm.noteController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: _inputDecoration(context, 'Note (Optional)'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: colorScheme.primary)),
        ),
        ElevatedButton(
          onPressed: () => _handleUpdate(context, vm),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            padding: EdgeInsets.symmetric(horizontal: 24.w),
          ),
          child: const Text('Update', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildItemEditCard(
    FinanceViewModel vm,
    int index,
    TransactionItem item,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Product Name',
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  controller: TextEditingController(text: item.name)
                    ..selection = TextSelection.collapsed(
                      offset: item.name.length,
                    ),
                  onChanged: (val) => vm.updateLineItem(index, name: val),
                ),
              ),

              SizedBox(width: 8.w),

              GestureDetector(
                onTap: () => vm.removeLineItem(index),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Icon(
                    Icons.close,
                    size: 18.sp,
                    color: Colors.red.shade400,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 60.w,
                child: TextField(
                  controller:
                      TextEditingController(text: item.quantity.toString())
                        ..selection = TextSelection.collapsed(
                          offset: item.quantity.toString().length,
                        ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Qty',
                    isDense: true,
                    contentPadding: EdgeInsets.only(bottom: 8.h),
                  ),
                  onChanged: (val) =>
                      vm.updateLineItem(index, qty: int.tryParse(val) ?? 1),
                ),
              ),

              SizedBox(width: 16.w),

              Expanded(
                child: TextField(
                  controller:
                      TextEditingController(
                          text: NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: '',
                            decimalDigits: 0,
                          ).format(item.price),
                        )
                        ..selection = TextSelection.collapsed(
                          offset: NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: '',
                            decimalDigits: 0,
                          ).format(item.price).length,
                        ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [RupiahInputFormatter()],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Price',
                    prefixText: 'Rp ',
                    prefixStyle: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.only(bottom: 8.h),
                  ),
                  onChanged: (val) => vm.updateLineItem(
                    index,
                    price: double.tryParse(val.replaceAll('.', '')) ?? 0,
                  ),
                ),
              ),

              SizedBox(width: 16.w),

              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [RupiahInputFormatter()],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Price',
                    prefixText: 'Rp ',
                    prefixStyle: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.only(bottom: 8.h),
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

  Future<void> _handleUpdate(BuildContext context, FinanceViewModel vm) async {
    final updatedTx = widget.transaction.copyWith(
      amount:
          double.tryParse(vm.amountController.text.replaceAll('.', '')) ?? 0,
      merchant: vm.merchantController.text,
      category: vm.selectedCategory ?? 'Others',
      note: vm.noteController.text,
      items: vm.lineItems,
    );

    final success = await vm.editTransaction(widget.transaction.id, updatedTx);
    if (success && mounted) Navigator.pop(context);
  }
}

InputDecoration _inputDecoration(BuildContext context, String label) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final colorScheme = Theme.of(context).colorScheme;

  return InputDecoration(
    labelText: label,

    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),

    filled: true,

    fillColor: isDark ? Colors.white.withOpacity(0.03) : Colors.grey.shade50,

    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade300,
      ),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade300,
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
    ),
  );
}
