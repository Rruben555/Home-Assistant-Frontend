import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import 'app_button.dart';
import 'icon_tile.dart';
import 'gradient_scaffold.dart';

/// Layar "tidak ditemukan" untuk alamat yang tidak dikenal atau ID yang
/// salah, lengkap dengan tombol kembali ke Beranda (tidak buntu).
class NotFoundPage extends StatelessWidget {
  final String title;
  final String message;

  const NotFoundPage({super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const IconTile(Icons.search_off_rounded,
                  size: 64,
                  iconSize: 32,
                  background: AppColors.priorityHighBg,
                  foreground: AppColors.priorityHigh),
              const SizedBox(height: 12),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13.5, color: AppColors.textMuted)),
              const SizedBox(height: 16),
              MaxWidthBox(
                maxWidth: 320,
                child: AppButton(
                  label: 'Ke Beranda',
                  icon: Icons.home_outlined,
                  onPressed: () => context.go('/'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}