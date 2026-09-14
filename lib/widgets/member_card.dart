import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/family_member.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';
import 'member_avatar.dart';


class MemberCard extends StatelessWidget {
  final FamilyMember member;
  final int activeTaskCount;
  final VoidCallback onTap;

  const MemberCard({
    super.key,
    required this.member,
    required this.activeTaskCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          MemberAvatar(member: member),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(member.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14.5)),
                    ),
                    if (!member.active) ...[
                      const SizedBox(width: 6),
                      const Pill(
                        text: 'Nonaktif',
                        background: AppColors.divider,
                        foreground: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(member.role.label,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(member.favoriteCategory.icon,
                            size: 13, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text('Suka ${member.favoriteCategory.label}',
                            style: const TextStyle(
                                fontSize: 11.5, color: AppColors.primary)),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.checklist_rtl_outlined,
                            size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text('$activeTaskCount aktivitas aktif',
                            style: const TextStyle(
                                fontSize: 11.5, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
