import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? badge;
  final String? trailingText;
  final VoidCallback? onTrailingTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.badge,
    this.trailingText,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 8),
                Pill(
                  text: badge!,
                  background: AppColors.primaryLight,
                  foreground: AppColors.primaryDark,
                ),
              ],
            ],
          ),
          if (trailingText != null)
            GestureDetector(
              onTap: onTrailingTap,
              child: Text(
                trailingText!,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
