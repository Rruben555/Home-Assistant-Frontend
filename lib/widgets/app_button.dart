import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Tombol utama (primary) yang dipakai di seluruh layar agar bentuk,
/// warna, dan state "sedang memproses" konsisten. Otomatis menonaktifkan
/// dirinya sendiri saat [loading] true — mencegah ketukan ganda pada aksi
/// async (submit form, hapus, dll).
class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;
  final Color? color;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.loading = false,
    this.outlined = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = loading || onPressed == null;
    final child = loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation(
                outlined ? (color ?? AppColors.primaryDark) : Colors.white,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 18,
                    color: outlined ? (color ?? AppColors.primaryDark) : Colors.white),
                const SizedBox(width: 8),
              ],
              Text(label,
                  style: TextStyle(
                    color: outlined ? (color ?? AppColors.primaryDark) : Colors.white,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          );

    if (outlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: disabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: color ?? AppColors.divider),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: color ?? AppColors.primaryDark,
          disabledBackgroundColor: (color ?? AppColors.primaryDark).withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
        child: child,
      ),
    );
  }
}
