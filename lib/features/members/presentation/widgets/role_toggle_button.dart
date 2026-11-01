import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';

/// Tombol perisai di kartu anggota. Hijau = anggota, ungu = admin. Ditekan untuk beralih peran.
class RoleToggleButton extends StatelessWidget {
  const RoleToggleButton({super.key, required this.isAdmin, required this.onPressed, required this.tooltip});
  final bool isAdmin;
  final VoidCallback? onPressed;
  final String tooltip;

  static const _adminSoft = Color(0xFFEDE7FB);
  static const _adminColor = Color(0xFF7C5CD6);

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: Material(
          color: isAdmin ? _adminSoft : AppColors.primarySoft,
          borderRadius: AppRadius.smR,
          child: InkWell(
            borderRadius: AppRadius.smR,
            onTap: onPressed,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                isAdmin ? Icons.admin_panel_settings : Icons.admin_panel_settings_outlined,
                size: 22,
                color: isAdmin ? _adminColor : AppColors.primary,
              ),
            ),
          ),
        ),
      );
}
