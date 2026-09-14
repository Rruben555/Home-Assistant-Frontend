import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Kotak ikon membulat (ikon hijau di atas latar mint) — dipakai berulang
/// di kartu menu, detail, dan form agar gaya seragam dengan halaman Profil.
class IconTile extends StatelessWidget {
  final IconData icon;
  final double size;
  final double? iconSize;
  final Color background;
  final Color foreground;

  const IconTile(
    this.icon, {
    super.key,
    this.size = 44,
    this.iconSize,
    this.background = AppColors.primaryLight,
    this.foreground = AppColors.primaryDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(icon, color: foreground, size: iconSize ?? size * 0.5),
    );
  }
}
