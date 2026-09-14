import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Dialog konfirmasi untuk aksi destruktif. Mengembalikan true bila dikonfirmasi.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Hapus',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel,
              style: const TextStyle(color: AppColors.priorityHigh)),
        ),
      ],
    ),
  );
  return result ?? false;
}
