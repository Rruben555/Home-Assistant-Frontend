import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../cores/ui/confirm_dialog.dart';
import '../controllers/auth_controller.dart';

/// Konfirmasi lalu keluar dari akun. Dipakai di Profil dan layar Pilih keluarga.
Future<void> confirmAndLogout(BuildContext context, AuthController auth) async {
  final user = auth.currentUser;
  final ok = await showConfirmDialog(
    context,
    title: 'Keluar dari akun?',
    message: 'Kamu perlu masuk lagi untuk mengakses rumah tanggamu.',
    detail: user == null ? null : '${user.name} · ${user.email}',
    confirmLabel: 'Keluar',
    destructive: true,
  );
  if (!ok || !context.mounted) return;
  auth.logout();
  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.signIn, (_) => false);
}
