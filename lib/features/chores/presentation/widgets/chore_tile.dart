import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../cores/ui/app_card.dart';
import '../../../../cores/ui/badges.dart';
import '../../../../cores/utils/date_utils.dart';
import '../../../members/members.dart';
import '../../domain/chore.dart';

class ChoreTile extends StatelessWidget {
  const ChoreTile({super.key, required this.chore, required this.assignee, required this.onTap, this.onEdit});
  final Chore chore;

  /// Anggota yang ditugaskan (null bila sudah dihapus).
  final Member? assignee;
  final VoidCallback onTap;

  /// Bila diisi (dan chore belum selesai) tombol "Edit Tugas" ditampilkan.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final member = assignee;
    final who = member?.name ?? Member.removedName;
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            MemberAvatar(initial: member?.initial ?? '?'),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(chore.name, style: AppText.h3, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('Ditugaskan ke $who', style: AppText.muted, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${AppDateUtils.relativeDay(chore.scheduledAt)} • ${AppDateUtils.formatTime(chore.scheduledAt)}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
              ]),
            ),
          ]),
          const SizedBox(height: AppSpacing.md),
          if (chore.isCompleted) ...[
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text('Selesai',
                  style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 15)),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(color: AppColors.primarySoft, borderRadius: AppRadius.smR),
              child: const Text('Selesai. Terima kasih sudah membantu!',
                  style: TextStyle(color: AppColors.primary, fontSize: 15)),
            ),
          ] else if (onEdit != null)
            Material(
              color: AppColors.primarySoft,
              borderRadius: AppRadius.smR,
              child: InkWell(
                borderRadius: AppRadius.smR,
                onTap: onEdit,
                child: const SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Edit Tugas',
                        style: TextStyle(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
