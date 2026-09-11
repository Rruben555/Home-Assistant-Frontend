import 'package:flutter/material.dart';

/// Central color & style palette, mirroring the green "Home Assistant"
/// look from the design mock (dark green primary, soft mint accents).
class AppColors {
  static const Color primaryDark = Color(0xFF0D5C46);
  static const Color primary = Color(0xFF0F7A5C);
  static const Color primaryLight = Color(0xFFDFF3EA);
  static const Color mint = Color(0xFFA8E6C7);
  static const Color background = Color(0xFFF4F7F6);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF16241F);
  static const Color textMuted = Color(0xFF6B7C76);
  static const Color divider = Color(0xFFE7EEEB);
  // Rona hijau lembut di bagian atas latar halaman utama.
  static const Color backgroundTint = Color(0xFFDDF1E7);

  static const Color priorityHigh = Color(0xFFE05A4E);
  static const Color priorityHighBg = Color(0xFFFCE7E5);
  static const Color priorityMedium = Color(0xFFE2932F);
  static const Color priorityMediumBg = Color(0xFFFCEFDC);
  static const Color priorityLow = Color(0xFF2F9E6E);
  static const Color priorityLowBg = Color(0xFFE1F4EA);
}

/// Latar gradasi halaman utama: rona mint di atas, memudar ke warna latar.
const LinearGradient kPageGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [AppColors.backgroundTint, AppColors.background],
  stops: [0.0, 0.45],
);

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.background,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        // Transparan agar gradasi latar di MainShell terlihat; layar lain
        // punya latar solid sendiri sehingga tampilannya tidak berubah.
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        bodyMedium: TextStyle(color: AppColors.textDark),
      ),
    );
  }
}

/// Small helper for rounded "pill" badges (priority, category, status).
class Pill extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final double fontSize;

  const Pill({
    super.key,
    required this.text,
    required this.background,
    required this.foreground,
    this.icon,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: foreground,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
