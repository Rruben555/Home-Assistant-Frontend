import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import 'app_button.dart';
import 'icon_tile.dart';

/// Skenario daftar kosong dengan petunjuk tindakan (mis. "Tambah Aktivitas").
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          IconTile(icon, size: 60, iconSize: 30),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 4),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: MaxWidthBox(
                maxWidth: 320,
                child: AppButton(
                  label: actionLabel!,
                  icon: Icons.add,
                  onPressed: onAction,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
