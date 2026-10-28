import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

/// Tombol utama. Saat [loading] aktif tombol dinonaktifkan (cegah submit ganda).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.secondary = false,
    this.destructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool secondary;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    ButtonStyle? style;
    if (secondary) {
      style = ElevatedButton.styleFrom(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textMuted,
        disabledBackgroundColor: AppColors.background,
        disabledForegroundColor: AppColors.border,
      );
    } else if (destructive) {
      style = ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFE5A39C),
        disabledForegroundColor: Colors.white,
      );
    }
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: style,
        onPressed: loading ? null : onPressed,
        child: loading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: secondary ? AppColors.primary : Colors.white),
              )
            : Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

/// Tombol teks sekunder (Batal, Keluar, Kembali, ...).
class AppTextButton extends StatelessWidget {
  const AppTextButton({super.key, required this.label, required this.onPressed, this.color});
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 48,
        child: TextButton(
          onPressed: onPressed,
          child: Text(label,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: color ?? AppColors.textMuted)),
        ),
      );
}
