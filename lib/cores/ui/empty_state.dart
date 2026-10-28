import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import 'primary_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: iconColor),
              const SizedBox(height: AppSpacing.md),
              Text(title, style: AppText.h2, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(message, style: AppText.muted, textAlign: TextAlign.center),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.lg),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: PrimaryButton(label: actionLabel!, onPressed: onAction),
                ),
              ],
            ],
          ),
        ),
      );
}

/// Skenario gagal: pesan + tombol "Coba lagi".
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => EmptyState(
        icon: Icons.error_outline,
        iconColor: AppColors.error,
        title: 'Gagal memuat data',
        message: message,
        actionLabel: 'Coba lagi',
        onAction: onRetry,
      );
}
