import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Indikator pemuatan bersama untuk mensimulasikan jeda pengambilan data.
class LoadingState extends StatelessWidget {
  final String message;

  const LoadingState({super.key, this.message = 'Memuat data...'});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Mengetengahkan secara vertikal
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primaryDark),
          ),
          const SizedBox(height: 14),
          Text(message, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        ],
      ),
    );
  }
}
