import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../cores/ui/app_card.dart';
import '../../../../cores/ui/app_search_field.dart';
import '../../../../cores/ui/app_snackbar.dart';
import '../../../../cores/ui/async_builder.dart';
import '../../../../cores/ui/badges.dart';
import '../../../../cores/ui/confirm_dialog.dart';
import '../../../../cores/ui/empty_state.dart';
import '../../../../cores/ui/run_action.dart';
import '../../../../shared/role/role.dart';
import '../../domain/member.dart';
import '../controllers/members_controller.dart';
import 'role_toggle_button.dart';

/// Daftar anggota. Admin dapat mengubah, menghapus, dan menjadikan admin; anggota hanya melihat.
class MembersView extends StatefulWidget {
  const MembersView({super.key, required this.members, required this.isAdmin});
  final MembersController members;
  final bool isAdmin;
  @override
  State<MembersView> createState() => _MembersViewState();
}

class _MembersViewState extends State<MembersView> {
  MembersController get _members => widget.members;
  final _search = TextEditingController();
  String _query = '';
  bool _busy = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _setBusy(bool v) => setState(() => _busy = v);

  void _openProfile(String id) => Navigator.pushNamed(context, AppRoutes.memberProfile, arguments: id);

  Future<void> _delete(Member m) async {
    if (_busy) return;
    if (_members.isMe(m.id)) {
      showAppSnack(context, 'Kamu tidak dapat menghapus akunmu sendiri.', isError: true);
      return;
    }
    final ok = await showConfirmDialog(
      context,
      title: 'Hapus anggota?',
      message: 'Anggota ini akan dihapus dari rumah tanggamu. Tindakan ini tidak dapat dibatalkan.',
      detail: m.name,
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (!ok || !mounted) return;
    await runAction<void>(
      context,
      action: () => _members.delete(m.id),
      onBusy: _setBusy,
      catchUnexpected: false,
      onSuccess: (_) => showAppSnack(context, '${m.name} berhasil dihapus'),
    );
  }

  /// Beralih peran: Anggota -> Admin atau Admin -> Anggota (dengan konfirmasi).
  Future<void> _toggleRole(Member m) async {
    if (_busy) return;
    final toAdmin = m.role != Role.admin;
    final isSelf = _members.isMe(m.id);
    final ok = await showConfirmDialog(
      context,
      title: toAdmin ? 'Jadikan admin?' : 'Jadikan anggota biasa?',
      message: toAdmin
          ? 'Anggota ini akan dapat menambah, mengubah, dan menghapus chore serta mengelola anggota.'
          : isSelf
              ? 'Kamu tidak akan lagi dapat mengelola chore dan anggota.'
              : 'Admin ini tidak akan lagi dapat mengelola chore dan anggota.',
      detail: m.name,
      confirmLabel: toAdmin ? 'Jadikan admin' : 'Jadikan anggota',
    );
    if (!ok || !mounted) return;
    await runAction<void>(
      context,
      action: () => _members.setAdmin(m.id, admin: toAdmin),
      onBusy: _setBusy,
      catchUnexpected: false,
      onSuccess: (_) => showAppSnack(
          context, toAdmin ? '${m.name} sekarang menjadi admin' : '${m.name} sekarang menjadi anggota'),
    );
  }

  Widget _build(List<Member> all) {
    final q = _query.trim().toLowerCase();
    final list = all.where((m) => q.isEmpty || m.name.toLowerCase().contains(q)).toList();

    final children = <Widget>[
      AppSearchField(controller: _search, hint: 'Cari anggota...', onChanged: (v) => setState(() => _query = v)),
      const SizedBox(height: AppSpacing.md),
      if (_busy) const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: LinearProgressIndicator(color: AppColors.primary),
      ),
    ];

    if (all.isEmpty) {
      children.add(EmptyState(
        icon: Icons.group_outlined,
        title: 'Belum ada anggota',
        message: 'Anggota keluarga ini akan tampil di sini.',
      ));
    } else if (list.isEmpty) {
      children.add(EmptyState(
        icon: Icons.search_off,
        title: 'Anggota tidak ditemukan',
        message: 'Coba kata kunci lain.',
        actionLabel: 'Reset pencarian',
        onAction: () {
          _search.clear();
          setState(() => _query = '');
        },
      ));
    } else {
      for (final m in list) {
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: AppCard(
            onTap: () => _openProfile(m.id),
            child: Row(children: [
              MemberAvatar(initial: m.initial),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(m.name, style: AppText.h3, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(m.role.label, style: AppText.muted, maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
              if (widget.isAdmin) ...[
                RoleToggleButton(
                  isAdmin: m.role == Role.admin,
                  tooltip: m.role == Role.admin ? 'Jadikan ${m.name} anggota biasa' : 'Jadikan ${m.name} admin',
                  onPressed: _busy ? null : () => _toggleRole(m),
                ),
                IconButton(
                  tooltip: 'Hapus ${m.name}',
                  onPressed: _busy ? null : () => _delete(m),
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                ),
              ],
            ]),
          ),
        ));
      }
    }

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(AppSpacing.md),
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) => AsyncBuilder<List<Member>>(
        loader: _members.loadMembers,
        refreshOn: _members,
        builder: (context, all) => _build(all),
      );
}
