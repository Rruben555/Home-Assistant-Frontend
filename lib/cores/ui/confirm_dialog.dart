import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import 'primary_button.dart';

class _AppDialog extends StatelessWidget {
  const _AppDialog({required this.title, required this.message, this.detail, required this.actions});
  final String title;
  final String message;
  final String? detail;
  final Widget actions;

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgR),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.h2),
              const SizedBox(height: AppSpacing.md),
              Text(message, style: AppText.muted),
              if (detail != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(detail!, style: AppText.h3),
              ],
              const SizedBox(height: AppSpacing.lg),
              actions,
            ],
          ),
        ),
      );
}

/// Dialog konfirmasi (aksi destruktif memakai tombol merah). Mengembalikan true bila dikonfirmasi.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? detail,
  String confirmLabel = 'Ya',
  String cancelLabel = 'Batal',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => _AppDialog(
      title: title,
      message: message,
      detail: detail,
      actions: Row(children: [
        Expanded(
            child: PrimaryButton(
                label: cancelLabel, secondary: true, onPressed: () => Navigator.pop(ctx, false))),
        const SizedBox(width: AppSpacing.md),
        Expanded(
            child: PrimaryButton(
                label: confirmLabel, destructive: destructive, onPressed: () => Navigator.pop(ctx, true))),
      ]),
    ),
  );
  return result ?? false;
}

/// Dialog pesan sukses untuk aksi selesai.
Future<void> showSuccessDialog(
  BuildContext context, {
  required String title,
  required String message,
  String buttonLabel = 'Selesai',
}) =>
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _AppDialog(
        title: title,
        message: message,
        actions: PrimaryButton(label: buttonLabel, onPressed: () => Navigator.pop(ctx)),
      ),
    );

/// Konfirmasi "Apakah yakin?" sebelum menyimpan / mengirim / mengubah data.
Future<bool> showSubmitConfirm(
  BuildContext context, {
  String title = 'Apakah kamu yakin?',
  required String message,
  String? detail,
  String confirmLabel = 'Ya, simpan',
}) =>
    showConfirmDialog(context, title: title, message: message, detail: detail, confirmLabel: confirmLabel);

/// Peringatan saat keluar dari form yang sudah terisi.
Future<bool> showDiscardConfirm(BuildContext context) => showConfirmDialog(
      context,
      title: 'Keluar tanpa menyimpan?',
      message: 'Data yang kamu tulis tidak akan tersimpan.',
      confirmLabel: 'Keluar',
      cancelLabel: 'Lanjut mengisi',
      destructive: true,
    );
