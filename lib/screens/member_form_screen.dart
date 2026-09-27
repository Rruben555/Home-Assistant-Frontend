import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/family_member.dart';
import '../models/task.dart';
import '../repository/member_repository.dart';
import '../theme/app_theme.dart';
import '../utils/member_actions.dart';
import '../utils/navigation.dart';
import '../utils/responsive.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_text_field.dart';
import '../widgets/member_avatar.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/icon_tile.dart';

Future<void> openMemberForm(BuildContext context, {FamilyMember? member}) {
  return context.push(
      member == null ? '/member/new' : '/member/${member.id}/edit');
}

/// Form Create/Update untuk modul Anggota Keluarga. 5 field (nama, peran,
/// kategori favorit, warna avatar, status aktif) dengan 4 jenis input
/// (teks, dropdown x2, pilihan chip, switch).
class MemberFormScreen extends StatefulWidget {
  final FamilyMember? member;

  const MemberFormScreen({super.key, this.member});

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  final _nameFocus = FocusNode();

  late MemberRole _role;
  late TaskCategory _favoriteCategory;
  late AvatarColorOption _avatarColor;
  late bool _active;
  bool _isSubmitting = false;

  bool get _isEdit => widget.member != null;

  @override
  void initState() {
    super.initState();
    final m = widget.member;
    _nameCtrl = TextEditingController(text: m?.name ?? '');
    _role = m?.role ?? MemberRole.anak;
    _favoriteCategory = m?.favoriteCategory ?? TaskCategory.cleaning;
    _avatarColor = m?.avatarColor ?? AvatarColorOption.hijau;
    _active = m?.active ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final member = widget.member;
    if (member == null || _isSubmitting) return;
    final router = GoRouter.of(context);
    final deleted = await deleteMember(context, member);
    if (!deleted) return;
    if (router.canPop()) {
      router.pop();
    } else {
      router.go('/keluarga');
    }
  }

  String? _validateName(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Nama wajib diisi';
    if (value.length < 2) return 'Nama minimal 2 karakter';
    if (value.length > 40) return 'Nama maksimal 40 karakter';
    final repo = MemberScope.of(context);
    final duplicate = repo.members.any((m) =>
        m.id != widget.member?.id && m.name.toLowerCase() == value.toLowerCase());
    if (duplicate) return 'Nama ini sudah dipakai anggota lain';
    return null;
  }

  Future<void> _save() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final repo = MemberScope.of(context);
    final name = _nameCtrl.text.trim();

    try {
      if (widget.member == null) {
        await repo.addMember(
          name: name,
          role: _role,
          favoriteCategory: _favoriteCategory,
          avatarColor: _avatarColor,
          active: _active,
        );
      } else {
        await repo.updateMember(widget.member!.copyWith(
          name: name,
          role: _role,
          favoriteCategory: _favoriteCategory,
          avatarColor: _avatarColor,
          active: _active,
        ));
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(_isEdit
              ? 'Perubahan anggota berhasil disimpan.'
              : 'Anggota keluarga berhasil ditambahkan.'),
        ));
      goBackOrHome(context, '/keluarga');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(
              'Gagal menyimpan: ${e.toString().replaceFirst('Exception: ', '')}'),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = FamilyMember(
      id: widget.member?.id ?? '',
      name: _nameCtrl.text.trim().isEmpty ? '?' : _nameCtrl.text.trim(),
      role: _role,
      favoriteCategory: _favoriteCategory,
      avatarColor: _avatarColor,
      active: _active,
    );

    return GradientScaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Home Assistant',
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600)),
            Text(_isEdit ? 'Ubah Anggota' : 'Tambah Anggota',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark)),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ResponsiveListView(
          maxWidth: 640,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x290F7A5C),
                        blurRadius: 18,
                        offset: Offset(0, 6)),
                  ],
                ),
                child: MemberAvatar(member: preview, radius: 40),
              ),
            ),
            const SizedBox(height: 22),
            AppTextField(
              label: 'Nama Anggota *',
              controller: _nameCtrl,
              hint: 'Contoh: Kirana',
              icon: Icons.badge_outlined,
              maxLength: 40,
              focusNode: _nameFocus,
              textInputAction: TextInputAction.done,
              validator: _validateName,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 18),
            _label('Peran dalam Keluarga'),
            _roleDropdown(),
            const SizedBox(height: 18),
            _label('Kategori Favorit'),
            _categoryDropdown(),
            const SizedBox(height: 18),
            _label('Warna Avatar'),
            _colorChips(),
            const SizedBox(height: 18),
            AppCard(
              child: Row(
                children: [
                  const IconTile(Icons.toggle_on_outlined),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status Aktif',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        Text('Nonaktifkan bila anggota sedang tidak tinggal di rumah',
                            style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _active,
                    activeColor: AppColors.primaryDark,
                    onChanged: (v) => setState(() => _active = v),
                  ),
                ],
              ),
            ),
            if (_isEdit) ...[
              const SizedBox(height: 22),
              AppButton(
                label: 'Hapus Anggota',
                icon: Icons.delete_outline,
                outlined: true,
                color: AppColors.priorityHigh,
                onPressed: _isSubmitting ? null : _delete,
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              16, 10, 16, 10 + MediaQuery.of(context).viewInsets.bottom),
          child: MaxWidthBox(
            maxWidth: 640,
            child: AppButton(
              label: _isEdit ? 'Simpan Perubahan' : 'Simpan Anggota',
              icon: Icons.check_circle_outline,
              onPressed: _save,
              loading: _isSubmitting,
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      );

  Widget _roleDropdown() {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<MemberRole>(
          value: _role,
          isExpanded: true,
          decoration: const InputDecoration(border: InputBorder.none),
          items: MemberRole.values
              .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
              .toList(),
          onChanged: (v) => setState(() => _role = v ?? _role),
        ),
      ),
    );
  }

  Widget _categoryDropdown() {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<TaskCategory>(
          value: _favoriteCategory,
          isExpanded: true,
          decoration: const InputDecoration(border: InputBorder.none),
          items: TaskCategory.values
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(c.icon, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(c.label),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _favoriteCategory = v ?? _favoriteCategory),
        ),
      ),
    );
  }

  Widget _colorChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: AvatarColorOption.values.map((c) {
        final selected = _avatarColor == c;
        return GestureDetector(
          onTap: () => setState(() => _avatarColor = c),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? c.color.withOpacity(0.15) : AppColors.card,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: selected ? c.color : AppColors.divider, width: selected ? 1.6 : 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 8, backgroundColor: c.color),
                const SizedBox(width: 6),
                Text(c.label,
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: selected ? AppColors.textDark : AppColors.textMuted)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}