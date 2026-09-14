import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import 'app_button.dart';
import 'icon_tile.dart';

/// Skenario gagal memuat, lengkap dengan tombol "Coba Lagi" yang
/// memanggil ulang fungsi pemuatan.
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String title;

  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.title = 'Gagal memuat data',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const IconTile(Icons.cloud_off_rounded,
              size: 64,
              iconSize: 32,
              background: AppColors.priorityHighBg,
              foreground: AppColors.priorityHigh),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: MaxWidthBox(
              maxWidth: 320,
              child: AppButton(label: 'Coba Lagi', icon: Icons.refresh, onPressed: onRetry),
            ),
          ),
        ],
      ),
    );
  }
}
