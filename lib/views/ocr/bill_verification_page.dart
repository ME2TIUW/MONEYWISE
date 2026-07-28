import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:money_wise/data/services/toast_service.dart';
import 'package:money_wise/data/models/receipt_model.dart';
import 'package:money_wise/data/models/receipt_item_model.dart';
import 'package:money_wise/data/models/transaction_model.dart';
import 'package:money_wise/viewmodels/finance/finance_viewmodel.dart';
import 'package:intl/intl.dart';

class BillVerificationPage extends StatefulWidget {
  final Receipt receipt;

  const BillVerificationPage({super.key, required this.receipt});

  @override
  State<BillVerificationPage> createState() => _BillVerificationPageState();
}

class _ReceiptItemDraft {
  final int id;
  String name;
  String qtyText;
  String priceText;

  _ReceiptItemDraft({
    required this.id,
    required this.name,
    required this.qtyText,
    required this.priceText,
  });
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _fmt = NumberFormat.decimalPattern('id');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    final int value = int.parse(digits);
    final formatted = _fmt.format(value);

    final newOffset =
        formatted.length - (oldValue.text.length - oldValue.selection.end);
    final caret = newOffset.clamp(0, formatted.length);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: caret),
    );
  }
}

class _BillVerificationPageState extends State<BillVerificationPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _merchantCtrl;
  late TextEditingController _dateCtrl;
  late TextEditingController _totalCtrl;

  final List<_ReceiptItemDraft> _itemDrafts = [];
  int _nextDraftId = 0;

  Future<void> _unfocusBeforePop() async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  void initState() {
    super.initState();
    _merchantCtrl = TextEditingController(text: widget.receipt.merchant);
    _dateCtrl = TextEditingController(text: widget.receipt.dateFormatted);
    _totalCtrl = TextEditingController(text: widget.receipt.total.toString());

    for (final it in widget.receipt.items) {
      _itemDrafts.add(
        _ReceiptItemDraft(
          id: _nextDraftId++,
          name: it.name,
          qtyText: it.qty.toString(),
          priceText: it.price.toString(),
        ),
      );
    }
    if (_itemDrafts.isEmpty) _addEmptyItem();
  }

  void _addEmptyItem() {
    setState(() {
      _itemDrafts.add(
        _ReceiptItemDraft(
          id: _nextDraftId++,
          name: '',
          qtyText: '1',
          priceText: '0',
        ),
      );
    });
  }

  void _removeItem(int index) {
    setState(() {
      _itemDrafts.removeAt(index);
    });
  }

  Future<void> _editItem(int index) async {
    final item = _itemDrafts[index];
    var draftName = item.name;
    var draftQty = item.qtyText;
    var draftPrice = item.priceText;
    final colorScheme = Theme.of(context).colorScheme;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Edit Item',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await _unfocusBeforePop();
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx, false);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _label('Nama Item'),
              TextFormField(
                initialValue: draftName,
                onChanged: (value) => draftName = value,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(hintText: 'Nama item'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Qty'),
                        TextFormField(
                          initialValue: draftQty,
                          onChanged: (value) => draftQty = value,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration(hintText: '1'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Harga'),
                        TextFormField(
                          initialValue: draftPrice,
                          onChanged: (value) => draftPrice = value,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          decoration: _inputDecoration(
                            hintText: '0',
                            prefixText: 'Rp ',
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            ThousandsSeparatorInputFormatter(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    await _unfocusBeforePop();
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx, true);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.primary,
                    ),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  child: const Text('Simpan Perubahan'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (saved == true && mounted) {
      setState(() {
        item.name = draftName;
        item.qtyText = draftQty;
        item.priceText = draftPrice;
      });
    }
  }

  String? _validateItems() {
    if (_itemDrafts.isEmpty) return 'Item tidak boleh kosong';

    for (var i = 0; i < _itemDrafts.length; i++) {
      final d = _itemDrafts[i];
      if (d.name.trim().isEmpty) return 'Nama item #${i + 1} harus diisi';

      final qty = int.tryParse(d.qtyText.trim());
      if (qty == null || qty < 1) return 'Qty item #${i + 1} minimal 1';

      final price = int.tryParse(d.priceText.replaceAll(RegExp(r'\D'), ''));
      if (price == null || price < 0) return 'Harga item #${i + 1} tidak valid';
    }

    return null;
  }

  @override
  void dispose() {
    _merchantCtrl.dispose();
    _dateCtrl.dispose();
    _totalCtrl.dispose();
    super.dispose();
  }

  bool _validateDateFormat(String s) {
    final reg = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!reg.hasMatch(s)) return false;
    final parts = s.split('/');
    final d = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final y = int.tryParse(parts[2]);
    if (d == null || m == null || y == null) return false;
    if (m < 1 || m > 12) return false;
    if (d < 1 || d > 31) return false;
    return true;
  }

  DateTime? _parseDate(String s) {
    if (!_validateDateFormat(s)) return null;
    final parts = s.split('/');
    final d = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final y = int.parse(parts[2]);
    return DateTime(y, m, d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final colorScheme = Theme.of(context).colorScheme;
    final itemsError = _validateItems();
    if (itemsError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(itemsError)));
      return;
    }

    final date = _parseDate(_dateCtrl.text);
    final total =
        int.tryParse(_totalCtrl.text.replaceAll(RegExp(r'\D'), '')) ?? 0;

    final items = <ReceiptItem>[];
    for (final draft in _itemDrafts) {
      final name = draft.name.trim();
      final qty = int.tryParse(draft.qtyText.trim()) ?? 1;
      final priceParsed =
          int.tryParse(draft.priceText.replaceAll(RegExp(r'\D'), '')) ?? 0;
      items.add(
        ReceiptItem(name: name, qty: qty, price: priceParsed, quantity: qty),
      );
    }

    final updated = Receipt(
      merchant: _merchantCtrl.text.trim(),
      date: date,
      total: total,
      items: items,
    );

    // final uploadConfirmed = await showDialog<bool>(
    //   context: context,
    //   builder: (c) => AlertDialog(
    //     title: const Text('Upload Transaction'),
    //     backgroundColor: Theme.of(context).colorScheme.surface,
    //     content: const Text(
    //       'Are you sure you want to upload this transaction?',
    //     ),
    //     actions: [
    //       TextButton(
    //         onPressed: () async {
    //           await _unfocusBeforePop();
    //           if (!c.mounted) return;
    //           Navigator.pop(c, false);
    //         },
    //         child: const Text('Discard'),
    //       ),
    //       ElevatedButton(
    //         onPressed: () async {
    //           await _unfocusBeforePop();
    //           if (!c.mounted) return;
    //           Navigator.pop(c, true);
    //         },
    //         style: ButtonStyle(
    //           backgroundColor: WidgetStateProperty.all(colorScheme.primary),
    //         ),
    //         child: const Text('Upload', style: TextStyle(color: Colors.white)),
    //       ),
    //     ],
    //   ),
    // );

    final uploadConfirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Upload Transaction'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: const Text(
          'Are you sure you want to upload this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _unfocusBeforePop();
              if (!c.mounted) return;
              Navigator.pop(c, false);
            },
            child: const Text('Discard'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _unfocusBeforePop();
              if (!c.mounted) return;
              Navigator.pop(c, true);
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(colorScheme.primary),
            ),
            child: const Text('Upload', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (uploadConfirmed == true) {
      final vm = context.read<FinanceViewModel>();

      final txItems = items
          .map(
            (it) => TransactionItem(
              name: it.name,
              quantity: it.qty,
              price: (it.price).toDouble(),
            ),
          )
          .toList();

      final success = await vm.addTransactionFromReceipt(
        merchant: _merchantCtrl.text.trim().isEmpty
            ? null
            : _merchantCtrl.text.trim(),
        date: date,
        amount: total.toDouble(),
        items: txItems,
        category: 'Others',
      );

      if (success) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Success upload transaction')),
        // );

        ToastService.showSuccess('Transaction added successfully!');

        if (!mounted) return;
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamedAndRemoveUntil('/main-wrapper', (route) => false);

        return;
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(vm.errorMessage ?? 'Failed to upload transaction'),
        //   ),
        // );

        ToastService.showError(
          (vm.errorMessage != null && vm.errorMessage!.trim().isNotEmpty)
              ? vm.errorMessage!
              : 'Failed to upload transaction',
        );
      }
    }

    await _unfocusBeforePop();
    if (!mounted) return;
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Text(
          'Verifikasi Transaksi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : colorScheme.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _receiptImage(),
                    const SizedBox(height: 20),
                    _label('Merchant'),
                    TextFormField(
                      controller: _merchantCtrl,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Merchant harus diisi'
                          : null,
                      decoration: _inputDecoration(hintText: 'Nama merchant'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Tanggal (dd/MM/yyyy)'),
                              TextFormField(
                                controller: _dateCtrl,
                                validator: (v) =>
                                    (v == null ||
                                        !_validateDateFormat(v.trim()))
                                    ? 'Tanggal tidak valid (dd/MM/yyyy)'
                                    : null,
                                decoration: _inputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Total Nominal'),
                              TextFormField(
                                controller: _totalCtrl,
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Total harus diisi';
                                  }
                                  final n = int.tryParse(
                                    v.replaceAll(RegExp(r'\D'), ''),
                                  );
                                  if (n == null || n <= 0) {
                                    return 'Total harus angka positif';
                                  }
                                  return null;
                                },
                                decoration: _inputDecoration(hintText: '0'),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  ThousandsSeparatorInputFormatter(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ITEM TERDETEKSI (${_itemDrafts.length})',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        TextButton.icon(
                          onPressed: _addEmptyItem,
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _itemTile(i),
                  childCount: _itemDrafts.length,
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Simpan Transaksi'),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            Theme.of(context).colorScheme.primary,
                          ),
                          foregroundColor: WidgetStateProperty.all(
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await _unfocusBeforePop();
                          if (!mounted) return;
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Scan Ulang'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _receiptImage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark
                ? colorScheme.surfaceContainerHighest
                : Colors.grey.shade200,
            border: Border.all(
              color: isDark
                  ? colorScheme.outline.withValues(alpha: 0.2)
                  : Colors.transparent,
            ),
          ),
          child: const Center(
            child: Icon(Icons.receipt_long, size: 64, color: Colors.grey),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'AI SCANNED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _itemTile(int index) {
    final item = _itemDrafts[index];
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: ValueKey(item.id),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: isDark
            ? colorScheme.outline.withValues(alpha: 0.3)
            : Colors.grey.shade300,
      ),
      child: InkWell(
        onTap: () => _editItem(index),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name.trim().isEmpty ? 'Nama item' : item.name.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Qty: ${item.qtyText.trim().isEmpty ? '-' : item.qtyText.trim()}  •  Rp ${item.priceText.trim().isEmpty ? '-' : item.priceText.trim()}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit',
              onPressed: () => _editItem(index),
              icon: Icon(
                Icons.edit_outlined,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
            IconButton(
              tooltip: 'Hapus',
              onPressed: () => _removeItem(index),
              icon: Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.red.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hintText,
    Widget? prefixIcon,
    String? prefixText,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      prefixText: prefixText,
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
    );
  }
}
