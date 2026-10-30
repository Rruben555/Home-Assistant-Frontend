import 'package:flutter/material.dart';
import '../../../../../app/routes/app_routes.dart';
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
import '../../controllers/auth_controller.dart';
import '../../widgets/auth_switch_link.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.auth});
  final AuthController auth;
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _submitting = false;
  bool _saved = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _dirty =>
      _name.text.isNotEmpty || _email.text.isNotEmpty || _password.text.isNotEmpty || _confirm.text.isNotEmpty;

  void _setSubmitting(bool v) => setState(() => _submitting = v);

  Future<void> _goSignIn() async {
    if (_dirty && !await showDiscardConfirm(context)) return;
    if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.signIn);
  }

  Future<void> _submit() async {
    if (_submitting) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final ok = await showSubmitConfirm(
      context,
      message: 'Buat akun baru dengan data yang kamu isi?',
      detail: _email.text.trim(),
      confirmLabel: 'Ya, daftar',
    );
    if (!ok || !mounted) return;
    await runAction<void>(
      context,
      action: () => widget.auth.register(name: _name.text, email: _email.text, password: _password.text),
      onBusy: _setSubmitting,
      logLabel: 'Register',
      onSuccess: (_) {
        setState(() => _saved = true);
        showAppSnack(context, 'Akun berhasil dibuat. Selamat datang!');
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.family, (_) => false);
      },
    );
  }

  @override
  Widget build(BuildContext context) => UnsavedChangesGuard(
        hasChanges: () => _dirty,
        enabled: !_saved,
        listenables: [_name, _email, _password, _confirm],
        child: _scaffold(context),
      );

  Widget _scaffold(BuildContext context) => AppScaffold(
        showAppBar: false,
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: AppSpacing.lg),
              const Text('Daftar', style: AppText.h1),
              const SizedBox(height: AppSpacing.xl),
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(children: [
                  AppTextField(
                    label: 'Nama lengkap',
                    controller: _name,
                    maxLength: AppConst.maxNameLength,
                    validator: (v) => Validators.text(v, 'Nama lengkap'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: 'Email',
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Password',
                    controller: _password,
                    obscureText: true,
                    helper: 'Gunakan minimal ${AppConst.minPasswordLength} karakter.',
                    validator: Validators.password,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Konfirmasi password',
                    controller: _confirm,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    validator: (v) => Validators.confirmPassword(v, _password.text),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(label: 'Daftar', loading: _submitting, onPressed: _submit),
                ]),
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthSwitchLink(
                prompt: 'Sudah punya akun? ',
                actionLabel: 'Masuk',
                onTap: _submitting ? null : _goSignIn,
              ),
            ]),
          ),
        ),
      );
}
