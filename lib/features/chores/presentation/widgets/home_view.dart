import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../cores/ui/app_search_field.dart';
import '../../../../cores/ui/async_builder.dart';
import '../../../../cores/ui/empty_state.dart';
import '../../../../cores/ui/primary_button.dart';
import '../../../../cores/ui/stat_card.dart';
import '../../../../cores/utils/date_utils.dart';
import '../../../family/family.dart';
import '../../../members/members.dart';
import '../../domain/chore.dart';
import '../controllers/chores_controller.dart';
import 'chore_filter_bar.dart';
import 'chore_tile.dart';

/// Isi Beranda. [isAdmin] menentukan apakah tombol buat / edit chore ditampilkan.
class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
    required this.isAdmin,
    required this.chores,
    required this.members,
    required this.family,
  });
  final bool isAdmin;
  final ChoresController chores;
  final MembersController members;
  final FamilyController family;
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  ChoresController get _choreRepo => widget.chores;
  MembersController get _memberRepo => widget.members;
  late final Listenable _refresh = Listenable.merge([widget.chores, widget.members]);
  final _search = TextEditingController();
  String _query = '';
  String? _memberId;
  DateTime? _date;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(Chore c) {
    if (_memberId != null && c.assigneeId != _memberId) return false;
    if (_date != null && !AppDateUtils.isSameDay(c.scheduledAt, _date!)) return false;
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return c.name.toLowerCase().contains(q) || _memberRepo.nameOf(c.assigneeId).toLowerCase().contains(q);
  }

  void _resetFilter() {
    _search.clear();
    setState(() {
      _query = '';
      _memberId = null;
      _date = null;
    });
  }

  void _openDetail(Chore c) => Navigator.pushNamed(context, AppRoutes.choreDetail, arguments: c.id);
  void _openEdit(Chore c) => Navigator.pushNamed(context, AppRoutes.choreForm, arguments: c.id);
  void _openCreate() => Navigator.pushNamed(context, AppRoutes.choreForm);

  List<Widget> _tiles(List<Chore> chores) => [
        for (final c in chores)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: ChoreTile(
              chore: c,
              assignee: _memberRepo.byId(c.assigneeId),
              onTap: () => _openDetail(c),
              onEdit: widget.isAdmin ? () => _openEdit(c) : null,
            ),
          ),
      ];

  Widget _buildContent(List<Chore> all) {
    final now = DateTime.now();
    final today = AppDateUtils.dateOnly(now);
    final filtered = all.where(_matches).toList()..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final todays = filtered.where((c) => AppDateUtils.isSameDay(c.scheduledAt, now)).toList();
    final upcoming = filtered
        .where((c) => !c.isCompleted && AppDateUtils.dateOnly(c.scheduledAt).isAfter(today))
        .toList();

    final body = <Widget>[];
    if (all.isEmpty) {
      body.add(Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: EmptyState(
          icon: Icons.checklist_rtl,
          title: 'Belum ada chore',
          message: widget.isAdmin
              ? 'Buat chore pertama untuk rumah tanggamu.'
              : 'Admin belum membuat chore untuk keluarga ini.',
          actionLabel: widget.isAdmin ? 'Buat chore' : null,
          onAction: widget.isAdmin ? _openCreate : null,
        ),
      ));
    } else if (filtered.isEmpty) {
      body.add(Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: EmptyState(
          icon: Icons.search_off,
          title: 'Tidak ada hasil',
          message: 'Tidak ada chore yang cocok dengan pencarian atau filter kamu.',
          actionLabel: 'Reset filter',
          onAction: _resetFilter,
        ),
      ));
    } else {
      if (_date != null) {
        // Filter tanggal aktif: tampilkan semua chore pada tanggal itu.
        body.add(Text('Chore ${AppDateUtils.formatLongDate(_date!)}', style: AppText.h2));
        body.add(const SizedBox(height: AppSpacing.md));
        body.addAll(_tiles(filtered));
      } else {
        body.add(const Text('Chore hari ini', style: AppText.h2));
        body.add(const SizedBox(height: AppSpacing.md));
        if (todays.isEmpty) {
          body.add(const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: Text('Tidak ada chore untuk hari ini.', style: AppText.muted),
          ));
        } else {
          body.addAll(_tiles(todays));
        }
        if (upcoming.isNotEmpty) {
          body.add(const SizedBox(height: AppSpacing.sm));
          body.add(const Text('Akan datang', style: AppText.h2));
          body.add(const SizedBox(height: AppSpacing.md));
          body.addAll(_tiles(upcoming));
        }
      }
    }

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md),
      children: [
        const Text('Beranda', style: AppText.label),
        Text(widget.family.current?.name ?? 'Beranda',
            style: AppText.h1, maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: AppSpacing.md),
        AppSearchField(controller: _search, hint: 'Cari aktivitas...', onChanged: (v) => setState(() => _query = v)),
        const SizedBox(height: AppSpacing.md),
        Row(children: [
          Expanded(child: StatCard(value: '${_memberRepo.members.length}', label: 'Anggota')),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: StatCard(value: '${all.where((c) => !c.isCompleted).length}', label: 'Chore aktif')),
        ]),
        const SizedBox(height: AppSpacing.md),
        ChoreFilterBar(
          members: _memberRepo.members,
          memberId: _memberId,
          date: _date,
          onMemberChanged: (id) => setState(() => _memberId = id),
          onDateChanged: (d) => setState(() => _date = d),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...body,
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        Expanded(
          child: AsyncBuilder<List<Chore>>(
            loader: _choreRepo.loadChores,
            refreshOn: _refresh,
            builder: (context, all) => _buildContent(all),
          ),
        ),
        if (widget.isAdmin)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: PrimaryButton(label: '+ Buat chore', onPressed: _openCreate),
          ),
      ]);
}
