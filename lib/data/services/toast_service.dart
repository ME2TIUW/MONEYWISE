import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:money_wise/data/services/global_navigation_service.dart';

class ToastService {
  static final FToast _fToast = FToast();

  static void init() {
    if (navigatorKey.currentContext != null) {
      _fToast.init(navigatorKey.currentContext!);
    }
  }

  static void showSuccess(String message) {
    _show(
      message,
      const Color.fromARGB(255, 105, 240, 175),
      Icons.check_circle_outline,
    );
  }

  static void showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  static void _show(String message, Color bgColor, IconData icon) {
    final globalContext = navigatorKey.currentContext;

    if (globalContext != null) {
      _fToast.init(globalContext);
    }

    _fToast.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: bgColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12.0),
            Flexible(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      gravity: ToastGravity.BOTTOM,
      isDismissible: true,
      toastDuration: const Duration(seconds: 3),
    );
  }
}
