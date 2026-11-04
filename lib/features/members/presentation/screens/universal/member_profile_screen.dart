import 'package:flutter/material.dart';
import '../../../../../app/theme/app_theme.dart';
import '../../../../../cores/ui/app_scaffold.dart';
import '../../../../../cores/ui/async_builder.dart';
import '../../../../../cores/ui/profile_parts.dart';
import '../../../domain/member.dart';
import '../../controllers/members_controller.dart';

/// Profil anggota lain (hanya lihat): nama, email, dan keluarga.
class MemberProfileScreen extends StatelessWidget {
  const MemberProfileScreen({super.key, required this.memberId, required this.members, required this.familyName});
  final String memberId;
  final MembersController members;

  /// Nama keluarga yang sedang dipilih (diisi oleh router, agar members tidak mengimpor family).
  final String familyName;

  @override
  Widget build(BuildContext context) => AppScaffold(
        backgroundColor: Colors.white,
        showAppBar: false,
        body: AsyncBuilder<Member>(
          loader: () => members.loadMember(memberId),
          refreshOn: members,
          builder: (context, m) => ListView(
            padding: EdgeInsets.zero,
            children: [
              ProfileHeader(
                initial: m.initial,
                leading: IconButton(
                  tooltip: 'Kembali',
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ProfileIdentity(name: m.name, role: m.role.label),
              const SizedBox(height: AppSpacing.lg),
              const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg, color: AppColors.border),
              ProfileField(label: 'Nama', value: m.name),
              ProfileField(label: 'Email', value: m.email),
              ProfileField(label: 'Keluarga', value: familyName),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      );
}
