import 'package:flutter/material.dart';
import '../common/async_state.dart';
import '../models/task.dart';
import '../repository/member_repository.dart';
import '../repository/task_repository.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/responsive.dart';
import '../utils/search.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/loading_state.dart';

/// Layar Riwayat (FR-07) — memuat data lewat simulasi async, dengan filter
/// rentang waktu dan kemampuan menghapus catatan riwayat (aksi destruktif
/// dengan dialog konfirmasi).
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  AsyncListState<HistoryEntry> _state = const AsyncListState.loading();
  int _tab = 0; // 0 Minggu Ini, 1 Bulan Ini, 2 Semua
  static const _tabs = ['Minggu Ini', 'Bulan Ini', 'Semua'];
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
      final history = await TaskScope.of(context).loadHistory();
      if (!mounted) return;
      setState(() => _state = AsyncListState.data(history));
    } catch (e) {
      if (!mounted) return;
      setState(() => _state =
          AsyncListState.error(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  List<HistoryEntry> _filtered(
      List<HistoryEntry> all, MemberRepository memberRepo) {
    final now = DateTime.now();
    final byRange = switch (_tab) {
      0 => all.where((e) => now.difference(e.completedAt).inDays < 7).toList(),
      1 => all.where((e) => now.difference(e.completedAt).inDays < 31).toList(),
      _ => all,
    };
    if (_query.trim().isEmpty) return byRange;
    return byRange
        .where((e) => matchesSearch(_query, [
              e.title,
              e.description,
              e.category.label,
              e.priority.label,
              memberRepo.findById(e.assignedMemberId)?.name,
            ]))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Home Assistant',
                style: TextStyle(fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
            Text('Riwayat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: switch (_state.status) {
          LoadStatus.loading => const LoadingState(message: 'Memuat riwayat...'),
          LoadStatus.error => ErrorState(
              message: _state.errorMessage ?? 'Terjadi kesalahan.',
              onRetry: _load,
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
    final entries = _filtered(repo.history, memberRepo);
    final searching = _query.trim().isNotEmpty;

    final grouped = <String, List<HistoryEntry>>{};
    for (final e in entries) {
      grouped.putIfAbsent(relativeDate(e.completedAt), () => []).add(e);
    }

    return RefreshIndicator(
      color: AppColors.primaryDark,
      onRefresh: _load,
      child: ResponsiveListView(
        maxWidth: 760,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          AppSearchBar(
            controller: _searchCtrl,
            hint: 'Cari riwayat aktivitas...',
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 14),
          _segmented(),
          const SizedBox(height: 16),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Linimasa Tugas Selesai',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
              Text('${entries.length} catatan',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 10),
          if (entries.isEmpty)
            EmptyState(
              icon: searching ? Icons.search_off_rounded : Icons.inbox_outlined,
              title: searching
                  ? 'Riwayat tidak ditemukan'
                  : 'Belum ada riwayat pada rentang ini',
              message: searching
                  ? 'Coba kata kunci lain atau ganti rentang waktu.'
                  : 'Tandai aktivitas selesai di Beranda agar riwayat muncul di sini.',
            )
          else
            for (final group in grouped.entries) ...[
              Row(
                children: [
                  Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 6), decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                  Text(group.key, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const Spacer(),
                  Pill(text: '${group.value.length} Selesai', background: AppColors.primaryLight, foreground: AppColors.primaryDark),
                ],
              ),
              const SizedBox(height: 8),
              ...group.value.map((h) => _HistoryCard(
                    entry: h,
                    assigneeName: memberRepo.findById(h.assignedMemberId)?.name,
                    onDelete: () => _confirmDelete(context, h),
                  )),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, HistoryEntry entry) async {
    final ok = await confirmDialog(
      context,
      title: 'Hapus catatan riwayat?',
      message: '"${entry.title}" akan dihapus dari riwayat.',
    );
    if (!ok || !context.mounted) return;
    TaskScope.of(context).deleteHistory(entry.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Catatan riwayat dihapus.')));
  }

  Widget _segmented() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final selected = i == _tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(_tabs[i],
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: selected ? Colors.white : AppColors.textMuted)),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryEntry entry;
  final String? assigneeName;
  final VoidCallback onDelete;

  const _HistoryCard({required this.entry, this.assigneeName, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(entry.category.icon,
                    color: AppColors.primaryDark, size: 18),
              ),
              const SizedBox(width: 8),
              Pill(text: entry.category.label, background: AppColors.primaryLight, foreground: AppColors.primaryDark),
              const Spacer(),
              const Icon(Icons.access_time, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 3),
              Text(formatTimeWib(entry.time), style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textMuted),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(entry.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          if (entry.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(entry.description, style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.35)),
          ],
          if (assigneeName != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 13, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text('Dikerjakan oleh $assigneeName',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
