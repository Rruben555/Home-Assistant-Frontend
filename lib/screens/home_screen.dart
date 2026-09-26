import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../common/async_state.dart';
import '../models/task.dart';
import '../repository/auth_repository.dart';
import '../repository/member_repository.dart';
import '../repository/task_repository.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/responsive.dart';
import '../utils/search.dart';
import '../utils/task_actions.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/filter_dropdown.dart';
import '../widgets/loading_state.dart';
import '../widgets/section_header.dart';
import '../widgets/task_card.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';

/// Layar Beranda — daftar aktivitas rumah tangga (FR-01..08). Memuat data
/// lewat simulasi async (loading/data/error) pada kunjungan pertama, lalu
/// bereaksi langsung ke perubahan repository (tambah/ubah/hapus/selesai)
/// tanpa perlu memuat ulang.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AsyncListState<HouseholdTask> _state = const AsyncListState.loading();
  TaskCategory? _filter; // null = semua kategori
  String? _memberFilter; // null = semua anggota, _unassigned = belum ditugaskan
  static const _unassigned = '__unassigned__';
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _state = const AsyncListState.loading());
    try {
      final tasks = await TaskScope.of(context).loadTasks();
      if (!mounted) return;
      setState(() => _state = AsyncListState.data(tasks));
    } catch (e) {
      if (!mounted) return;
      setState(() => _state = AsyncListState.error(
          e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        backgroundColor: AppColors.primaryDark,
        onPressed: () => openTaskForm(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tugas Baru', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        bottom: false,
        child: switch (_state.status) {
          LoadStatus.loading => const LoadingState(message: 'Memuat aktivitas...'),
          LoadStatus.error => ResponsiveListView(
              maxWidth: 720,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                ErrorState(message: _state.errorMessage ?? 'Terjadi kesalahan.', onRetry: _load),
              ],
            ),
          LoadStatus.data => AnimatedBuilder(
              animation: Listenable.merge(
                  [TaskScope.of(context), MemberScope.of(context)]),
              builder: (context, _) => _buildContent(context),
            ),
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final repo = TaskScope.of(context);
    final memberRepo = MemberScope.of(context);
    final allTasks = List.of(repo.tasks)..sort(compareTasks);
    final pending = allTasks.where((t) => !t.isDone).toList();

    final today = pending.where((t) => isSameDay(t.date, DateTime.now())).toList();
    final upcoming = pending.where((t) => !isSameDay(t.date, DateTime.now())).toList();

    // Jika anggota yang sedang difilter sudah dihapus, filter dianggap "semua".
    final memberFilter = (_memberFilter == null ||
            _memberFilter == _unassigned ||
            memberRepo.findById(_memberFilter) != null)
        ? _memberFilter
        : null;
    final hasFilter = _filter != null || memberFilter != null;
    final searching = _query.trim().isNotEmpty;

    // Filter gabungan: kategori, anggota, DAN kata kunci harus cocok.
    bool matches(HouseholdTask t) {
      if (_filter != null && t.category != _filter) return false;
      if (searching &&
          !matchesSearch(_query, [
            t.title,
            t.description,
            t.category.label,
            t.priority.label,
            t.repeatType.label,
            memberRepo.findById(t.assignedMemberId)?.name,
          ])) {
        return false;
      }
      if (memberFilter == null) return true;
      return memberFilter == _unassigned
          ? t.assignedMemberId == null
          : t.assignedMemberId == memberFilter;
    }

    final visibleToday = today.where(matches).toList();
    final visibleUpcoming = upcoming.where(matches).toList();

    return LayoutBuilder(builder: (context, constraints) {
      const maxContent = 1100.0;
      final contentWidth = math.min(constraints.maxWidth - 32, maxContent);
      // >= 800: daftar tugas 2 kolom.
      final twoColumns = contentWidth >= 800;

      Widget taskCard(HouseholdTask t) => TaskCard(
            key: ValueKey(t.id), // <-- Penting agar animasi state tidak tertukar
            task: t,
            assignee: memberRepo.findById(t.assignedMemberId),
            onTap: () => openTaskDetail(context, t),
            onToggle: () => completeTask(context, t),
          );

      final todaySection = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: 'Hari Ini', badge: '${visibleToday.length} Tugas'),
          if (visibleToday.isEmpty)
            EmptyState(
              icon: (hasFilter || searching)
                  ? Icons.search_off_rounded
                  : Icons.check_circle_outline,
              title: (hasFilter || searching)
                  ? 'Tidak ada aktivitas yang cocok hari ini'
                  : 'Tidak ada aktivitas hari ini',
              message: (hasFilter || searching)
                  ? 'Coba ubah kata kunci atau reset filter.'
                  : 'Semua beres! Tambahkan aktivitas baru bila perlu.',
              actionLabel: (hasFilter || searching) ? null : 'Tambah Aktivitas',
              onAction: (hasFilter || searching)
                  ? null
                  : () => openTaskForm(context),
            )
          else
            ...visibleToday.map(taskCard),
        ],
      );

      final upcomingSection = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: 'Mendatang', badge: '${visibleUpcoming.length} Tugas'),
          if (visibleUpcoming.isEmpty)
            EmptyState(
              icon: (hasFilter || searching)
                  ? Icons.search_off_rounded
                  : Icons.event_available_outlined,
              title: (hasFilter || searching)
                  ? 'Tidak ada aktivitas mendatang yang cocok'
                  : 'Belum ada aktivitas mendatang',
              message: (hasFilter || searching)
                  ? 'Coba ubah kata kunci atau reset filter.'
                  : 'Aktivitas dengan tanggal setelah hari ini akan muncul di sini.',
            )
          else
            ...visibleUpcoming.map(taskCard),
        ],
      );

      final Widget tasks = twoColumns
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: todaySection),
                const SizedBox(width: 16),
                Expanded(child: upcomingSection),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                todaySection,
                const SizedBox(height: 10),
                upcomingSection,
              ],
            );

      final categoryDropdown = FilterDropdown<TaskCategory>(
        label: 'Kategori',
        value: _filter,
        options: [
          const FilterOption(
              value: null, label: 'Semua kategori', icon: Icons.apps_rounded),
          for (final c in TaskCategory.values)
            FilterOption(value: c, label: c.label, icon: c.icon),
        ],
        onChanged: (v) => setState(() => _filter = v),
      );
      final memberDropdown = FilterDropdown<String>(
        label: 'Anggota keluarga',
        value: memberFilter,
        options: [
          const FilterOption(
              value: null, label: 'Semua anggota', icon: Icons.people_alt_outlined),
          const FilterOption(
              value: _unassigned,
              label: 'Belum ditugaskan',
              icon: Icons.person_off_outlined),
          for (final m in memberRepo.members)
            FilterOption(
              value: m.id,
              label: m.active ? m.name : '${m.name} (nonaktif)',
              icon: Icons.person_outline,
            ),
        ],
        onChanged: (v) => setState(() => _memberFilter = v),
      );

      // Sempit: dua dropdown berdampingan. Lebar: lebar tetap, rata kiri.
      final Widget filters = contentWidth >= 640
          ? Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(width: 260, child: categoryDropdown),
                SizedBox(width: 260, child: memberDropdown),
              ],
            )
          : Row(
              children: [
                Expanded(child: categoryDropdown),
                const SizedBox(width: 10),
                Expanded(child: memberDropdown),
              ],
            );

      return RefreshIndicator(
        color: AppColors.primaryDark,
        onRefresh: _load,
        child: ResponsiveListView(
          maxWidth: maxContent,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
          children: [
            Text(
              'Halo, ${AuthScope.of(context).currentUser?.name ?? 'Bu Sarah'}! 👋',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            const SizedBox(height: 16),
            AppSearchBar(
              controller: _searchCtrl,
              hint: 'Cari judul, kategori, atau anggota...',
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 12),
            SectionHeader(
              title: 'Filter Tugas',
              trailingText: (hasFilter || searching) ? 'Reset filter' : null,
              onTrailingTap: () => setState(() {
                _filter = null;
                _memberFilter = null;
                _query = '';
                _searchCtrl.clear();
              }),
            ),
            const SizedBox(height: 4),
            filters,
            const SizedBox(height: 18),
            tasks,
          ],
        ),
      );
    });
  }
}
