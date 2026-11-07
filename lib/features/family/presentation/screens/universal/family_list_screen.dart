import 'package:flutter/material.dart';
import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/theme/app_theme.dart';
import '../../../../../cores/ui/app_card.dart';
import '../../../../../cores/ui/app_scaffold.dart';
import '../../../../../cores/ui/async_builder.dart';
import '../../../../../cores/ui/badges.dart';
import '../../../../../cores/ui/empty_state.dart';
import '../../../../../cores/ui/primary_button.dart';
import '../../../../auth/auth.dart';
import '../../../domain/family.dart';
import '../../controllers/family_controller.dart';

/// Layar pertama setelah masuk: daftar keluarga. Bila belum ada, tawarkan membuat keluarga.
class FamilyListScreen extends StatelessWidget {
  const FamilyListScreen({super.key, required this.auth, required this.family});
  final AuthController auth;
  final FamilyController family;

  void _open(BuildContext context, Family f) {
    family.select(f.id);
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (_) => false);
  }

  void _create(BuildContext context) => Navigator.pushNamed(context, AppRoutes.familyChoice);

  Widget _build(BuildContext context, List<Family> families) {
    final user = auth.currentUser;
    if (families.isEmpty) {
      return Column(children: [
        Expanded(
          child: EmptyState(
            icon: Icons.home_work_outlined,
            title: 'Belum ada keluarga',
            message: 'Buat keluarga baru atau gabung dengan kode undangan.',
            actionLabel: 'Buat atau gabung keluarga',
            onAction: () => _create(context),
          ),
        ),
        AppTextButton(label: 'Keluar', onPressed: () => confirmAndLogout(context, auth)),
      ]);
    }
    return Column(children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const SizedBox(height: AppSpacing.md),
            const Text('Keluarga', style: AppText.h1),
            const SizedBox(height: AppSpacing.sm),
            Text('Halo, ${user?.name ?? ''}! Pilih keluarga yang ingin kamu kelola.', style: AppText.muted),
            const SizedBox(height: AppSpacing.lg),
            for (final f in families)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppCard(
                  onTap: () => _open(context, f),
                  child: Row(children: [
                    const IconBadge(icon: Icons.home_outlined),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(f.name, style: AppText.h3, maxLines: 2, overflow: TextOverflow.ellipsis),
                        Text('${family.memberCount(f.id)} anggota', style: AppText.muted),
                      ]),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textMuted),
                  ]),
                ),
              ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 0),
        child: PrimaryButton(label: '+ Tambah keluarga', onPressed: () => _create(context)),
      ),
      AppTextButton(label: 'Keluar', onPressed: () => confirmAndLogout(context, auth)),
    ]);
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
        showAppBar: false,
        body: AsyncBuilder<List<Family>>(
          loader: family.loadFamilies,
          refreshOn: family,
          builder: (context, families) => _build(context, families),
        ),
      );
}
