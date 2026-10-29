import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';

/// Baris "Belum punya akun? Daftar" / "Sudah punya akun? Masuk".
class AuthSwitchLink extends StatelessWidget {
  const AuthSwitchLink({super.key, required this.prompt, required this.actionLabel, required this.onTap});
  final String prompt;
  final String actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text(prompt, style: AppText.muted),
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(actionLabel,
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        ),
      ]);
}
