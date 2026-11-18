import 'package:flutter/material.dart';
import '../../../../../app/theme/app_theme.dart';
import '../../../../../cores/constants/app_constants.dart';
import '../../../../../cores/ui/app_card.dart';
import '../../../../../cores/ui/app_scaffold.dart';
import '../../../../../cores/ui/app_snackbar.dart';
import '../../../../../cores/ui/app_text_field.dart';
import '../../../../../cores/ui/confirm_dialog.dart';
import '../../../../../cores/ui/primary_button.dart';
import '../../../../../cores/ui/run_action.dart';
import '../../../../../cores/ui/unsaved_changes_guard.dart';
import '../../../../../cores/utils/validators.dart';
import '../../../../auth/auth.dart';

/// Edit profil: hanya nama dan password yang dapat diubah. Email tampil saja.
/// Bagian password opsional: kosongkan semuanya bila hanya ingin mengganti nama.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.auth});
  final AuthController auth;
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  String _initialName = '';
  bool _submitting = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final user = widget.auth.currentUser;
    _name.text = user?.name ?? '';
    _email.text = user?.email ?? '';
    _initialName = _name.text;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _wantsPassword => _current.text.isNotEmpty || _new.text.isNotEmpty || _confirm.text.isNotEmpty;
  bool get _nameChanged => _name.text.trim() != _initialName;
  bool get _dirty => _nameChanged || _wantsPassword;

  Future<void> _submit() async {
    if (_submitting) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (!_dirty) {
      showAppSnack(context, 'Belum ada perubahan untuk disimpan.');
      return;
    }
    final ok = await showSubmitConfirm(
      context,
      message: _wantsPassword && _nameChanged
          ? 'Nama dan password kamu akan diperbarui.'
          : _wantsPassword
              ? 'Password kamu akan diganti dengan password baru.'
              : 'Nama kamu akan diperbarui.',
      confirmLabel: 'Ya, simpan',
    );
    if (!ok || !mounted) return;
    await runAction<void>(
      context,
      action: () => widget.auth.updateProfile(
        name: _name.text,
        currentPassword: _current.text,
        newPassword: _new.text,
      ),
      onBusy: (busy) => setState(() => _submitting = busy),
      logLabel: 'Edit profil',
      onSuccess: (_) {
        setState(() => _saved = true);
        showAppSnack(context, 'Profil berhasil diperbarui');
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) => UnsavedChangesGuard(
        hasChanges: () => _dirty,
        enabled: !_saved,
        listenables: [_name, _current, _new, _confirm],
        child: _scaffold(),
      );

  Widget _scaffold() => AppScaffold(
        body: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Edit profil', style: AppText.h1),
                const SizedBox(height: AppSpacing.sm),
                const Text('Perbarui nama atau password kamu.', style: AppText.muted),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(children: [
                    AppTextField(
                      label: 'Nama',
                      controller: _name,
                      maxLength: AppConst.maxNameLength,
                      validator: (v) => Validators.text(v, 'Nama'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      label: 'Alamat email',
                      controller: _email,
                      readOnly: true,
                      helper: 'Email tidak dapat diubah.',
                      suffixIcon: const Icon(Icons.lock_outline, size: 20),
                    ),
                  ]),
                ),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Ganti password (opsional)', style: AppText.h3),
                    const SizedBox(height: AppSpacing.xs),
                    const Text('Kosongkan bagian ini jika tidak ingin mengganti password.',
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Password saat ini',
                      controller: _current,
                      obscureText: true,
                      validator: (v) => _wantsPassword ? Validators.required(v, 'Password saat ini') : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Password baru',
                      controller: _new,
                      obscureText: true,
                      helper: 'Gunakan minimal ${AppConst.minPasswordLength} karakter.',
                      validator: (v) => _wantsPassword ? Validators.password(v, label: 'Password baru') : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Konfirmasi password baru',
                      controller: _confirm,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      validator: (v) => _wantsPassword ? Validators.confirmPassword(v, _new.text) : null,
                    ),
                  ]),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(label: 'Simpan perubahan', loading: _submitting, onPressed: _submit),
                const SizedBox(height: AppSpacing.sm),
                AppTextButton(label: 'Batal', onPressed: _submitting ? null : () => Navigator.maybePop(context)),
              ]),
            ),
          ),
      );
}
