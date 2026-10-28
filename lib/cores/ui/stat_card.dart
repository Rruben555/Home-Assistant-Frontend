import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import 'app_card.dart';

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: AppColors.primary)),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: AppText.muted, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      );
}
