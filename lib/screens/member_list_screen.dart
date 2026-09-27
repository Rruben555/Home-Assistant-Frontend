import 'package:flutter/material.dart';
import '../common/async_state.dart';
import '../models/family_member.dart';
import '../repository/member_repository.dart';
import '../repository/task_repository.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/loading_state.dart';
import '../widgets/member_card.dart';
import 'member_form_screen.dart';

/// Modul CRUD kedua — daftar Anggota Keluarga (relasi ID dengan aktivitas
/// lewat `assignedMemberId`). Sama seperti Beranda: memuat data lewat
/// simulasi async pada kunjungan pertama, lalu reaktif terhadap perubahan.
class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  AsyncListState<FamilyMember> _state = const AsyncListState.loading();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _state = const AsyncListState.loading());
    try {
      final members = await MemberScope.of(context).loadMembers();
      if (!mounted) return;
      setState(() => _state = AsyncListState.data(members));
    } catch (e) {
      if (!mounted) return;
      setState(() => _state =
          AsyncListState.error(e.toString().replaceFirst('Exception: ', '')));
    }
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
            Text('Anggota Keluarga',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        backgroundColor: AppColors.primaryDark,
        onPressed: () => openMemberForm(context),
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text('Anggota Baru', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        bottom: false,
        child: switch (_state.status) {
          LoadStatus.loading => const LoadingState(message: 'Memuat anggota keluarga...'),
          LoadStatus.error => ErrorState(
              message: _state.errorMessage ?? 'Terjadi kesalahan.',
              onRetry: _load,
            ),
          LoadStatus.data => AnimatedBuilder(
              animation: Listenable.merge(
                  [MemberScope.of(context), TaskScope.of(context)]),
              builder: (context, _) => _buildList(context),
            ),
        },
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final memberRepo = MemberScope.of(context);
    final members = memberRepo.members;

    return RefreshIndicator(
      color: AppColors.primaryDark,
      onRefresh: _load,
      child: ResponsiveListView(
        maxWidth: 1100,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        children: [
          Text('${members.length} anggota terdaftar',
              style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
          const SizedBox(height: 10),
          if (members.isEmpty)
            EmptyState(
              icon: Icons.people_outline,
              title: 'Belum ada anggota keluarga',
              message: 'Tambahkan anggota agar aktivitas bisa ditugaskan ke orang yang tepat.',
              actionLabel: 'Tambah Anggota',
              onAction: () => openMemberForm(context),
            )
          else
            // 1 kolom di HP, 2-3 kolom di tablet/desktop.
            AdaptiveWrap(
              minItemWidth: 320,
              maxColumns: 3,
              children: [
                for (final m in members)
                  MemberCard(
                    member: m,
                    activeTaskCount: memberRepo.activeTaskCount(m.id),
                    onTap: () => openMemberForm(context, member: m),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}