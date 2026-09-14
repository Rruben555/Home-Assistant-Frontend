import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Bungkus kartu putih bersudut membulat yang dipakai berulang di semua
/// layar (daftar, detail, form) agar konsisten.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: onTap,
                child: Padding(padding: padding, child: child),
              ),
            ),
    );
    return card;
  }
}
