import 'package:flutter/material.dart';
import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/theme/app_theme.dart';
import '../../../../../cores/ui/app_card.dart';
import '../../../../../cores/ui/app_search_field.dart';
import '../../../../../cores/ui/async_builder.dart';
import '../../../../../cores/ui/date_time_info.dart';
import '../../../../../cores/ui/empty_state.dart';
import '../../../../../cores/utils/date_utils.dart';
import '../../../../members/members.dart';
import '../../../domain/chore.dart';
import '../../controllers/chores_controller.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.chores, required this.members});
  final ChoresController chores;
  final MembersController members;
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  ChoresController get _repo => widget.chores;
  MembersController get _members => widget.members;
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reset() {
    _search.clear();
    setState(() {
      _query = '';
    });
  }

  bool _matches(Chore c) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return c.name.toLowerCase().contains(q) || _members.nameOf(c.assigneeId).toLowerCase().contains(q);
  }

  Widget _build(List<Chore> all) {
    final allDone = all.where((c) => c.isCompleted).toList();
    if (allDone.isEmpty) {
      return EmptyState(
        icon: Icons.history,
        title: 'Belum ada chore selesai',
        message: 'Selesaikan sebuah chore untuk melihatnya di sini.',
      );
    }
    final done = allDone.where(_matches).toList()
      ..sort((a, b) => (b.completedAt ?? b.scheduledAt).compareTo(a.completedAt ?? a.scheduledAt));

    final children = <Widget>[
      AppSearchField(controller: _search, hint: 'Cari aktivitas...', onChanged: (v) => setState(() => _query = v)),
      const SizedBox(height: AppSpacing.md),
    ];

    if (done.isEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: EmptyState(
          icon: Icons.search_off,
          title: 'Tidak ada hasil',
          message: 'Tidak ada riwayat yang cocok dengan pencarian kamu.',
          actionLabel: 'Reset pencarian',
          onAction: _reset,
        ),
      ));
    }

    DateTime? last;
    for (final c in done) {
      final at = c.completedAt ?? c.scheduledAt;
      final d = AppDateUtils.dateOnly(at);
      if (last == null || d != last) {
        children.add(Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.sm),
          child: Text(AppDateUtils.formatLongDate(d), style: AppText.label),
        ));
        last = d;
      }
      children.add(Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: AppCard(
          onTap: () => Navigator.pushNamed(context, AppRoutes.choreDetail, arguments: c.id),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.name, style: AppText.h3, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppSpacing.sm),
            Text('Diselesaikan oleh ${_members.nameOf(c.assigneeId)}',
                style: AppText.muted, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppSpacing.md),
            const Text('Waktu selesai', style: AppText.label),
            const SizedBox(height: AppSpacing.sm),
            DateTimeInfo(dateTime: at),
          ]),
        ),
      ));
    }

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(AppSpacing.md),
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) => AsyncBuilder<List<Chore>>(
        loader: _repo.loadChores,
        refreshOn: Listenable.merge([widget.chores, widget.members]),
        builder: (context, all) => _build(all),
      );
}
