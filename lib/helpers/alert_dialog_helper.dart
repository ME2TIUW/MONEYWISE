import 'package:flutter/material.dart';

Future<void> showAppDialog(
  BuildContext context, {
  required String title,
  required String message,
  VoidCallback? onConfirm,
}) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm?.call();
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
