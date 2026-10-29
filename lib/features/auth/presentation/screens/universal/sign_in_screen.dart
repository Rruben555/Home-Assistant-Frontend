import 'package:flutter/material.dart';
import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/theme/app_theme.dart';
import '../../../../../cores/ui/app_card.dart';
import '../../../../../cores/ui/app_scaffold.dart';
import '../../../../../cores/ui/app_text_field.dart';
import '../../../../../cores/ui/primary_button.dart';
import '../../../../../cores/ui/run_action.dart';
import '../../../../../cores/utils/validators.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/auth_switch_link.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.auth});
  final AuthController auth;
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _setSubmitting(bool v) => setState(() => _submitting = v);

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    await runAction<void>(
      context,
      action: () => widget.auth.signIn(email: _email.text, password: _password.text),
      onBusy: _setSubmitting,
      catchUnexpected: false,
      onSuccess: (_) => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.family, (_) => false),
    );
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
        showAppBar: false,
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: AppSpacing.lg),
              const Text('Masuk', style: AppText.h1),
              const SizedBox(height: AppSpacing.sm),
              const Text('Kelola chore rumah tanggamu bersama-sama.', style: AppText.muted),
              const SizedBox(height: AppSpacing.xl),
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(children: [
                  AppTextField(
                    label: 'Email',
                    controller: _email,
                    hint: 'nama@example.com',
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    validator: Validators.email,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Password',
                    controller: _password,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    validator: (v) => Validators.required(v, 'Password'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(label: 'Masuk', loading: _submitting, onPressed: _submit),
                ]),
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthSwitchLink(
                prompt: 'Belum punya akun? ',
                actionLabel: 'Daftar',
                onTap: _submitting ? null : () => Navigator.pushReplacementNamed(context, AppRoutes.register),
              ),
              const SizedBox(height: AppSpacing.md),
            ]),
          ),
        ),
      );
}
