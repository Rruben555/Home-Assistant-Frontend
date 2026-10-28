import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

/// Banner gradasi + avatar bulat. [leading] di pojok kiri atas, [trailing] di pojok kanan atas.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.initial, this.leading, this.trailing});
  final String initial;
  final Widget? leading;
  final Widget? trailing;

  static const _bannerHeight = 150.0;
  static const _avatarSize = 112.0;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: _bannerHeight + _avatarSize / 2,
        child: Stack(children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _bannerHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, Color(0xFF5BB5AB)],
                ),
              ),
            ),
          ),
          if (leading != null) Positioned(top: 8, left: 8, child: leading!),
          if (trailing != null) Positioned(top: 8, right: 8, child: trailing!),
          Positioned(
            top: _bannerHeight - _avatarSize / 2,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: _avatarSize,
                height: _avatarSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 3))],
                ),
                child: Text(initial,
                    style: const TextStyle(fontSize: 46, fontWeight: FontWeight.w800, color: AppColors.primary)),
              ),
            ),
          ),
        ]),
      );
}

/// Nama (huruf besar) + peran. Bila [onEdit] diisi, ikon edit muncul di samping nama.
class ProfileIdentity extends StatelessWidget {
  const ProfileIdentity({super.key, required this.name, required this.role, this.onEdit});
  final String name;
  final String role;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) => Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (onEdit != null) const SizedBox(width: 40), // penyeimbang agar nama tetap di tengah
          Flexible(
            child: Text(name.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: AppColors.textDark)),
          ),
          if (onEdit != null)
            IconButton(
              tooltip: 'Edit profil',
              onPressed: onEdit,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.edit_square, size: 20, color: AppColors.primary),
            ),
        ]),
        if (role.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(role.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 3, color: AppColors.textMuted)),
          ),
      ]);
}

/// Satu baris data profil: label kecil, nilai tebal, [trailing] opsional di kanan.
class ProfileField extends StatelessWidget {
  const ProfileField({super.key, required this.label, required this.value, this.trailing});
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.lg, 14, trailing == null ? AppSpacing.lg : AppSpacing.md, 14),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                const SizedBox(height: 4),
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              ]),
            ),
            if (trailing != null) trailing!,
          ]),
        ),
        const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg, color: AppColors.border),
      ]);
}
