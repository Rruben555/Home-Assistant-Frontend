import 'package:flutter/material.dart';
import '../repository/auth_repository.dart';
import '../theme/app_theme.dart';
import '../utils/navigation.dart';
import '../utils/responsive.dart';
import '../utils/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_layout.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/icon_tile.dart';

/// Layar Ganti Kata Sandi: kata sandi lama + kata sandi baru (dua kali).
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _newFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    _newFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = AuthScope.of(context);
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await auth.changePassword(
        currentPassword: _currentCtrl.text,
        newPassword: _newCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
            const SnackBar(content: Text('Kata sandi berhasil diganti.')));
      goBackOrHome(context, '/profil');
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _error = e.message;
      });
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

  Widget _visibilityToggle(bool obscure, VoidCallback onTap) => IconButton(
        tooltip: obscure ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: AppColors.textMuted,
        ),
        onPressed: onTap,
      );

  void _clearError(String _) {
    if (_error != null) setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Home Assistant',
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600)),
            Text('Ganti Kata Sandi',
                style: TextStyle(
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
            const Center(
              child: IconTile(Icons.lock_reset_outlined, size: 72, iconSize: 34),
            ),
            const SizedBox(height: 22),
            AppTextField(
              label: 'Kata Sandi Lama *',
              controller: _currentCtrl,
              hint: 'Masukkan kata sandi lama',
              icon: Icons.lock_outline,
              obscureText: _obscureCurrent,
              textCapitalization: TextCapitalization.none,
              nextFocusNode: _newFocus,
              validator: AuthValidators.passwordRequired,
              onChanged: _clearError,
              suffixIcon: _visibilityToggle(_obscureCurrent,
                  () => setState(() => _obscureCurrent = !_obscureCurrent)),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Kata Sandi Baru *',
              controller: _newCtrl,
              hint: 'Minimal 8 karakter, huruf & angka',
              icon: Icons.lock_reset_outlined,
              focusNode: _newFocus,
              obscureText: _obscureNew,
              textCapitalization: TextCapitalization.none,
              nextFocusNode: _confirmFocus,
              validator: AuthValidators.newPassword,
              onChanged: _clearError,
              suffixIcon: _visibilityToggle(
                  _obscureNew, () => setState(() => _obscureNew = !_obscureNew)),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Konfirmasi Kata Sandi Baru *',
              controller: _confirmCtrl,
              hint: 'Ulangi kata sandi baru',
              icon: Icons.lock_reset_outlined,
              focusNode: _confirmFocus,
              obscureText: _obscureConfirm,
              textCapitalization: TextCapitalization.none,
              textInputAction: TextInputAction.done,
              validator: AuthValidators.confirmPassword(() => _newCtrl.text),
              onSubmitted: (_) => _save(),
              onChanged: _clearError,
              suffixIcon: _visibilityToggle(_obscureConfirm,
                  () => setState(() => _obscureConfirm = !_obscureConfirm)),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              AuthErrorBanner(message: _error!),
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
              label: 'Simpan Kata Sandi',
              icon: Icons.check_circle_outline,
              onPressed: _save,
              loading: _isSubmitting,
            ),
          ),
        ),
      ),
    );
  }
}
