import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF008075);
  static const primarySoft = Color(0xFFDCF2EE);
  static const background = Color(0xFFF2F6F5);
  static const textDark = Color(0xFF1A3A36);
  static const textMuted = Color(0xFF637A77);
  static const border = Color(0xFFD5E5E1);
  static const error = Color(0xFFC0392B);
}

class AppSpacing {
  static const double xs = 4, sm = 8, md = 16, lg = 24, xl = 32;
}

class AppRadius {
  static const double sm = 12, md = 16, lg = 24;
  static const smR = BorderRadius.all(Radius.circular(sm));
  static const mdR = BorderRadius.all(Radius.circular(md));
  static const lgR = BorderRadius.all(Radius.circular(lg));
}

class AppText {
  static const h1 = TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textDark);
  static const h2 = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark);
  static const h3 = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark);
  static const body = TextStyle(fontSize: 16, color: AppColors.textDark);
  static const muted = TextStyle(fontSize: 15, color: AppColors.textMuted);
  static const label = TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textMuted);
}

class AppTheme {
  static OutlineInputBorder _border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: AppRadius.mdR,
        borderSide: BorderSide(color: c, width: w),
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary)
            .copyWith(primary: AppColors.primary, error: AppColors.error, surface: Colors.white),
        scaffoldBackgroundColor: AppColors.background,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: const TextStyle(color: AppColors.textMuted),
          errorMaxLines: 3,
          border: _border(AppColors.border),
          enabledBorder: _border(AppColors.border),
          focusedBorder: _border(AppColors.primary, 1.6),
          errorBorder: _border(AppColors.error),
          focusedErrorBorder: _border(AppColors.error, 1.6),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF80BFB9),
            disabledForegroundColor: Colors.white,
            minimumSize: const Size(0, 52),
            elevation: 0,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdR),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.primarySoft,
          elevation: 0,
          height: 72,
        ),
        snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      );
}
