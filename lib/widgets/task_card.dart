import 'package:flutter/material.dart';
import '../models/family_member.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

enum TaskMenuAction { edit, delete }

class TaskCard extends StatefulWidget {
  final HouseholdTask task;
  final FamilyMember? assignee;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  /// Opsional: bila null, tombol titik tiga (Ubah/Hapus) tidak ditampilkan.
  final ValueChanged<TaskMenuAction>? onMenu;

  const TaskCard({
    super.key,
    required this.task,
    this.assignee,
    required this.onTap,
    required this.onToggle,
    this.onMenu,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isDoneLocal = false;
  bool _isVisible = true;

  Future<void> _handleToggle() async {
    // 1. Tampilkan indikator centang hijau secara lokal
    setState(() {
      _isDoneLocal = true;
    });

    // 2. Beri waktu pengguna melihat respon visual (400ms)
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    // 3. Mulai animasi memudar dan mengecil
    setState(() {
      _isVisible = false;
    });

    // 4. Tunggu animasi pudar selesai (250ms)
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    // 5. Panggil callback utama untuk memperbarui state di Repository
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final overdue = !task.isDone && task.scheduledAt.isBefore(DateTime.now());

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: _isVisible ? 1.0 : 0.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: widget.onTap,
              child: Padding(
                padding: EdgeInsets.fromLTRB(14, 12, widget.onMenu == null ? 14 : 6, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tombol Toggle Centang
                        GestureDetector(
                          onTap: _isDoneLocal ? null : _handleToggle,
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 22,
                            height: 22,
                            margin: const EdgeInsets.only(top: 2, right: 10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isDoneLocal ? Colors.green : Colors.transparent,
                              border: Border.all(
                                color: _isDoneLocal ? Colors.green : AppColors.textMuted,
                                width: 1.4,
                              ),
                            ),
                            child: _isDoneLocal
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _isDoneLocal ? AppColors.textMuted : AppColors.textDark,
                                decoration: _isDoneLocal ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Pill(
                          text: task.priority.label,
                          background: task.priority.bg,
                          foreground: task.priority.fg,
                        ),
                        if (widget.onMenu != null)
                          PopupMenuButton<TaskMenuAction>(
                          padding: EdgeInsets.zero,
                          iconSize: 20,
                          icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
                          onSelected: widget.onMenu,
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: TaskMenuAction.edit,
                              child: Text('Ubah'),
                            ),
                            PopupMenuItem(
                              value: TaskMenuAction.delete,
                              child: Text('Hapus'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 32, right: 8),
                        child: Text(
                          task.description,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 32, right: 8),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _meta(
                            Icons.access_time,
                            '${relativeDate(task.date)} • ${formatTimeWib(task.time)}',
                            color: overdue ? AppColors.priorityHigh : AppColors.textMuted,
                          ),
                          if (task.repeatType != RepeatType.none)
                            _meta(Icons.repeat, task.repeatType.label),
                          _meta(
                            task.category.icon,
                            task.category.label,
                            color: AppColors.primary,
                            bold: true,
                          ),
                          if (widget.assignee != null)
                            _meta(Icons.person_outline, widget.assignee!.name),
                          if (overdue)
                            const Pill(
                              text: 'Terlambat',
                              background: AppColors.priorityHighBg,
                              foreground: AppColors.priorityHigh,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _meta(
    IconData icon,
    String text, {
    Color color = AppColors.textMuted,
    bool bold = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}