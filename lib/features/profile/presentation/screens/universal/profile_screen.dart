import 'package:flutter/material.dart';
import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/theme/app_theme.dart';
import '../../../../../cores/ui/app_snackbar.dart';
import '../../../../../cores/ui/primary_button.dart';
import '../../../../../cores/ui/profile_parts.dart';
import '../../../../auth/auth.dart';
import '../../../../family/family.dart';
import '../../../../members/members.dart';

/// Profil sendiri: keluar (kiri atas), ganti foto (kanan atas), edit profil (di samping nama),
/// serta Nama, Email, Password, dan Keluarga + kode keluarga.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.auth, required this.members, required this.family});
  final AuthController auth;
  final MembersController members;
  final FamilyController family;

  void _changePhoto(BuildContext context) {
    // TODO: sambungkan dengan image_picker. Setelah foto dipilih, tampilkan
    // showSubmitConfirm(...) ("Apakah kamu yakin ingin mengganti foto?") sebelum mengunggah.
    showAppSnack(context, 'Pilih foto belum tersedia di versi ini.');
  }

  Widget _build(BuildContext context) {
    final user = auth.currentUser;
    final name = user?.name ?? '-';
    final role = members.myRole?.label ?? '';
    final current = family.current;

    return ColoredBox(
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ProfileHeader(
            initial: name.isEmpty ? '?' : name.trim()[0].toUpperCase(),
            leading: IconButton(
              tooltip: 'Keluar',
              onPressed: () => confirmAndLogout(context, auth),
              // Ikon pintu + panah keluar menghadap kiri (versi cermin dari Icons.logout).
              icon: Transform.flip(flipX: true, child: const Icon(Icons.logout, color: Colors.white)),
            ),
            trailing: IconButton(
              tooltip: 'Ganti foto profil',
              onPressed: () => _changePhoto(context),
              icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ProfileIdentity(
            name: name,
            role: role,
            onEdit: () => Navigator.pushNamed(context, AppRoutes.editProfile),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg, color: AppColors.border),
          ProfileField(label: 'Nama', value: name),
          ProfileField(label: 'Email', value: user?.email ?? '-'),
          const ProfileField(label: 'Password', value: '********'),
          ProfileField(
            label: 'Keluarga',
            value: current?.name ?? '-',
            trailing: current == null ? null : FamilyCodeBox(code: current.code),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: AppTextButton(
              label: 'Ganti keluarga',
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.family, (_) => false),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: Listenable.merge([auth, members, family]),
        builder: (context, _) => _build(context),
      );
}
