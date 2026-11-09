import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../cores/utils/date_utils.dart';
import '../../../members/members.dart';

/// Filter Beranda: anggota dan tanggal. Chip aktif punya tombol hapus (x).
class ChoreFilterBar extends StatelessWidget {
  const ChoreFilterBar({
    super.key,
    required this.members,
    required this.memberId,
    required this.date,
    required this.onMemberChanged,
    required this.onDateChanged,
  });

  final List<Member> members;
  final String? memberId;
  final DateTime? date;
  final ValueChanged<String?> onMemberChanged;
  final ValueChanged<DateTime?> onDateChanged;

  Future<void> _pickMember(BuildContext context) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
              child: Text('Filter anggota', style: AppText.h2),
            ),
            ListTile(
              leading: const Icon(Icons.groups_outlined, color: AppColors.primary),
              title: const Text('Semua anggota'),
              selected: memberId == null,
              selectedColor: AppColors.primary,
              onTap: () => Navigator.pop(ctx, ''),
            ),
            for (final m in members)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primarySoft,
                  child: Text(m.initial, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                ),
                title: Text(m.name),
                selected: memberId == m.id,
                selectedColor: AppColors.primary,
                onTap: () => Navigator.pop(ctx, m.id),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return; // ditutup tanpa memilih
    onMemberChanged(picked.isEmpty ? null : picked);
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2, 12, 31),
    );
    if (picked != null) onDateChanged(AppDateUtils.dateOnly(picked));
  }

  @override
  Widget build(BuildContext context) {
    final memberName = memberId == null
        ? null
        : members.where((m) => m.id == memberId).map((m) => m.name).firstOrNull;
    return Row(children: [
      Expanded(
        child: _FilterChipButton(
          icon: Icons.person_outline,
          label: memberName ?? 'Semua anggota',
          active: memberName != null,
          onTap: () => _pickMember(context),
          onClear: () => onMemberChanged(null),
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: _FilterChipButton(
          icon: Icons.calendar_today_outlined,
          label: date == null ? 'Semua tanggal' : AppDateUtils.formatDate(date!),
          active: date != null,
          onTap: () => _pickDate(context),
          onClear: () => onDateChanged(null),
        ),
      ),
    ]);
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    required this.onClear,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final fg = active ? Colors.white : AppColors.textDark;
    return Material(
      color: active ? AppColors.primary : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdR,
        side: BorderSide(color: active ? AppColors.primary : AppColors.border),
      ),
      child: InkWell(
        borderRadius: AppRadius.mdR,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 4),
          child: SizedBox(
            height: 48,
            child: Row(children: [
              Icon(icon, size: 18, color: active ? Colors.white : AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 14)),
              ),
              active
                  ? IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Hapus filter',
                      icon: const Icon(Icons.close, size: 18, color: Colors.white),
                      onPressed: onClear,
                    )
                  : const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
                    ),
            ]),
          ),
        ),
      ),
    );
  }
}
