import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

class MemberAvatar extends StatelessWidget {
  const MemberAvatar({super.key, required this.initial, this.size = 56});
  final String initial;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(size * 0.28)),
        child: Text(initial,
            style: TextStyle(fontSize: size * 0.42, fontWeight: FontWeight.w800, color: AppColors.primary)),
      );
}

class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, this.size = 56});
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(size * 0.28)),
        child: Icon(icon, color: AppColors.primary, size: size * 0.5),
      );
}
