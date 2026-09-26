import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/task.dart';
import '../repository/member_repository.dart';
import '../repository/task_repository.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/navigation.dart';
import '../utils/responsive.dart';
import '../utils/task_actions.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/member_avatar.dart';
import '../widgets/not_found_page.dart';
import 'task_form_screen.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/icon_tile.dart';

Future<void> openTaskDetail(BuildContext context, HouseholdTask task) {
  return context.push('/task/${task.id}');
}

/// Detail aktivitas: lihat, ubah, hapus, dan tandai selesai.
class TaskDetailScreen extends StatelessWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final task = TaskScope.of(context).findById(taskId);

    // ID tidak ada (URL salah atau aktivitas sudah dihapus).
    if (task == null) {
      return NotFoundPage(
        title: 'Detail Aktivitas',
        message: 'Aktivitas dengan ID "$taskId" tidak ditemukan.',
      );
    }

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Detail Aktivitas',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
      ),
      body: _content(context, task),
    );
  }

  Widget _content(BuildContext context, HouseholdTask task) {
    final overdue = !task.isDone && task.scheduledAt.isBefore(DateTime.now());
    final assignee = MemberScope.of(context).findById(task.assignedMemberId);
    return ResponsiveListView(
      maxWidth: 640,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  Pill(
                    text: task.category.label,
                    icon: task.category.icon,
                    background: AppColors.primaryLight,
                    foreground: AppColors.primaryDark,
                  ),
                  Pill(
                    text: 'Prioritas ${task.priority.label}',
                    background: task.priority.bg,
                    foreground: task.priority.fg,
                  ),
                  if (overdue)
                    const Pill(
                      text: 'Terlambat',
                      background: AppColors.priorityHighBg,
                      foreground: AppColors.priorityHigh,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(task.title,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark)),
              const SizedBox(height: 8),
              Text(
                task.description.isEmpty
                    ? 'Tidak ada deskripsi.'
                    : task.description,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.4,
                  color: task.description.isEmpty
                      ? AppColors.textMuted
                      : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const IconTile(Icons.person_outline, size: 36),
              const SizedBox(width: 12),
              const Text('Ditugaskan Kepada',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
              const Spacer(),
              if (assignee == null)
                const Text('Belum ditugaskan',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700))
              else
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(assignee.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      MemberAvatar(member: assignee, radius: 13),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _row(Icons.calendar_today_outlined, 'Tanggal',
                  formatDateLong(task.date)),
              const Divider(height: 1, color: AppColors.divider),
              _row(Icons.access_time, 'Waktu', formatTimeWib(task.time)),
              const Divider(height: 1, color: AppColors.divider),
              _row(Icons.repeat, 'Pengulangan', task.repeatType.label),
              const Divider(height: 1, color: AppColors.divider),
              _row(
                Icons.notifications_active_outlined,
                'Pengingat',
                'Notifikasi pukul ${formatTime(task.time)}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        if (!task.isDone)
          AppButton(
            label: 'Tandai Selesai',
            icon: Icons.check_circle_outline,
            onPressed: () {
              completeTask(context, task);
              goBackOrHome(context);
            },
          )
        else
          const Pill(
            text: 'Aktivitas ini sudah selesai',
            background: AppColors.primaryLight,
            foreground: AppColors.primaryDark,
          ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Ubah',
                icon: Icons.edit_outlined,
                outlined: true,
                onPressed: () => openTaskForm(context, task: task),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppButton(
                label: 'Hapus',
                icon: Icons.delete_outline,
                outlined: true,
                color: AppColors.priorityHigh,
                onPressed: () async {
                  final deleted = await deleteTask(context, task);
                  if (deleted && context.mounted) goBackOrHome(context);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          IconTile(icon, size: 36),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}