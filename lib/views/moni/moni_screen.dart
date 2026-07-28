import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:money_wise/components/chat_bubble.dart';
import 'package:money_wise/viewmodels/finance/finance_viewmodel.dart';
import 'package:money_wise/viewmodels/moni/moni_viewmodel.dart';
import 'package:money_wise/viewmodels/profile/profile_viewmodel.dart';
import 'package:provider/provider.dart';

class MoniScreen extends StatefulWidget {
  final bool isActive;
  const MoniScreen({super.key, this.isActive = false});

  @override
  State<MoniScreen> createState() => _MoniScreenState();
}

class _MoniScreenState extends State<MoniScreen> {
  final _scrollController = ScrollController();
  bool _hasShown = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _checkAndShowDialog();
    }
  }

  @override
  void didUpdateWidget(MoniScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && oldWidget.isActive && !_hasShown) {
      _checkAndShowDialog();
    }
  }

  void _checkAndShowDialog() {
    Future.microtask(() {
      if (!mounted) return;

      final profileVM = context.read<ProfileViewModel>();

      if (profileVM.user?.allowFinancialAccess == null) {
        _hasShown = true;
        _showConsentDialog();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showConsentDialog() {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            "AI Financial Access",
            style: TextStyle(color: colorScheme.onSurface),
          ),
          content: Text(
            "Allow Moni to access your financial data to provide better advice?",
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<ProfileViewModel>().updateFinancialAccess(false);
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Deny',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<ProfileViewModel>().updateFinancialAccess(true);
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
              ),
              child: Text(
                "Allow",
                style: TextStyle(color: colorScheme.onPrimary),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MoniViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    if (vm.messages.isNotEmpty) _scrollToBottom();

    final double hardwareInsets = View.of(context).viewInsets.bottom;
    final bool isKeyboardOpen = hardwareInsets > 0;

    return Container(
      color: colorScheme.surface,
      child: SafeArea(
        bottom: !isKeyboardOpen,
        child: Column(
          children: [
            Container(
              height: 56.h,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: colorScheme.surface),
              child: Text(
                'Moni Assistant',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : colorScheme.primary,
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(16.w),
                itemCount: vm.messages.length,
                itemBuilder: (context, idx) {
                  final msg = vm.messages[idx];
                  return ChatBubble(message: msg);
                },
              ),
            ),

            if (vm.isTyping)
              Padding(
                padding: EdgeInsets.only(left: 16.w, bottom: 8.h),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Moni's typing...",
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),

            _buildInput(vm, isDark, colorScheme),

            if (!isKeyboardOpen) SizedBox(height: 34.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(MoniViewModel vm, bool isDark, ColorScheme colorScheme) {
    final profileVm = context.read<ProfileViewModel>();
    final financeVm = context.read<FinanceViewModel>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: vm.chatController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: "Ask Moni anything...",
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                filled: true,
                fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 14.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          FloatingActionButton(
            mini: true,
            elevation: 0,
            backgroundColor: colorScheme.primary,
            onPressed: () {
              final text = vm.chatController.text;
              if (text.isNotEmpty) {
                vm.sendMessage(
                  text,
                  user: profileVm.user,
                  transactions: financeVm.allTransactions,
                );
                vm.chatController.clear();
              }
            },
            child: Icon(
              Icons.send_rounded,
              color: isDark ? Colors.white : colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
