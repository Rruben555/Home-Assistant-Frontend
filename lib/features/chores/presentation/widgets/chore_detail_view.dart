import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../cores/ui/app_card.dart';
import '../../../../cores/ui/app_scaffold.dart';
import '../../../../cores/ui/app_snackbar.dart';
import '../../../../cores/ui/async_builder.dart';
import '../../../../cores/ui/badges.dart';
import '../../../../cores/ui/confirm_dialog.dart';
import '../../../../cores/ui/date_time_info.dart';
import '../../../../cores/ui/primary_button.dart';
import '../../../../cores/ui/run_action.dart';
import '../../../../cores/utils/date_utils.dart';
import '../../../members/members.dart';
import '../../domain/chore.dart';
import '../controllers/chores_controller.dart';

/// Detail chore. Admin: edit, hapus, tandai selesai. Anggota: tandai selesai hanya
/// untuk chore yang ditugaskan ke akun emailnya.
class ChoreDetailView extends StatefulWidget {
  const ChoreDetailView({
    super.key,
    required this.choreId,
    required this.isAdmin,
    required this.chores,
    required this.members,
  });
  final String choreId;
  final bool isAdmin;
  final ChoresController chores;
  final MembersController members;
  @override
  State<ChoreDetailView> createState() => _ChoreDetailViewState();
}

class _ChoreDetailViewState extends State<ChoreDetailView> {
  ChoresController get _repo => widget.chores;
  bool _busy = false;

  void _setBusy(bool v) => setState(() => _busy = v);

  Future<void> _complete(Chore c) async {
    if (_busy) return;
    final ok = await showConfirmDialog(
      context,
      title: 'Selesaikan chore ini?',
      message: 'Tandai tugas ini sebagai selesai.',
      detail: c.name,
      confirmLabel: 'Selesaikan',
    );
    if (!ok || !mounted) return;
    await runAction<void>(
      context,
      action: () => _repo.complete(c.id),
      onBusy: _setBusy,
      catchUnexpected: false,
      onRetry: () => _complete(c),
      onSuccess: (_) {
        showAppSnack(context, 'Chore "${c.name}" ditandai selesai');
        Navigator.pop(context);
      },
    );
  }

  Future<void> _delete(Chore c) async {
    if (_busy) return;
    final ok = await showConfirmDialog(
      context,
      title: 'Hapus chore?',
      message: 'Chore ini akan dihapus permanen dan tidak dapat dikembalikan.',
      detail: c.name,
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (!ok || !mounted) return;
    await runAction<void>(
      context,
      action: () => _repo.delete(c.id),
      onBusy: _setBusy,
      catchUnexpected: false,
      onSuccess: (_) {
        showAppSnack(context, 'Chore "${c.name}" dihapus');
        Navigator.pop(context);
      },
    );
  }

  Widget _section(String title, Widget child) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppText.label),
          const SizedBox(height: AppSpacing.sm),
          child,
        ]),
      );

  Widget _build(Chore c) {
    final member = widget.members.byId(c.assigneeId);
    final who = member?.name ?? Member.removedName;
    final at = c.scheduledAt;

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.lg),
      children: [
        Row(children: [
          const Expanded(child: Text('Detail chore', style: AppText.h1)),
          if (widget.isAdmin && !c.isCompleted)
            Material(
              color: Colors.white,
              borderRadius: AppRadius.mdR,
              child: InkWell(
                borderRadius: AppRadius.mdR,
                onTap: _busy ? null : () => Navigator.pushNamed(context, AppRoutes.choreForm, arguments: c.id),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Text('Edit Tugas',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),
            ),
        ]),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          color: AppColors.primarySoft,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(children: [
            const Icon(Icons.task_alt, color: AppColors.primary, size: 40),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.name, style: AppText.h2.copyWith(fontSize: 26)),
                const SizedBox(height: AppSpacing.xs),
                Text(AppDateUtils.relativeDay(at), style: AppText.muted),
              ]),
            ),
          ]),
        ),
        _section(
          'Ditugaskan ke',
          AppCard(
            child: Row(children: [
              MemberAvatar(initial: member?.initial ?? '?', size: 52),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(who, style: AppText.h3, maxLines: 2, overflow: TextOverflow.ellipsis)),
            ]),
          ),
        ),
        if (c.instructions.trim().isNotEmpty)
          _section('Instruksi', AppCard(child: SizedBox(width: double.infinity, child: Text(c.instructions, style: AppText.body)))),
        _section('Tenggat waktu', AppCard(child: DateTimeInfo(dateTime: at))),
        if (c.isCompleted)
          _section('Waktu selesai', AppCard(child: DateTimeInfo(dateTime: c.completedAt ?? at))),
        const SizedBox(height: AppSpacing.lg),
        if (!c.isCompleted && _repo.canComplete(c))
          PrimaryButton(label: 'Tandai selesai', loading: _busy, onPressed: () => _complete(c))
        else if (!c.isCompleted)
          const Text('Hanya anggota yang ditugaskan yang dapat menandai chore ini selesai.',
              style: AppText.muted, textAlign: TextAlign.center),
        if (widget.isAdmin) ...[
          const SizedBox(height: AppSpacing.sm),
          AppTextButton(label: 'Hapus chore', color: AppColors.error, onPressed: _busy ? null : () => _delete(c)),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
        body: AsyncBuilder<Chore>(
          loader: () => _repo.loadChore(widget.choreId),
          refreshOn: Listenable.merge([widget.chores, widget.members]),
          builder: (context, chore) => _build(chore),
        ),
      );
}
