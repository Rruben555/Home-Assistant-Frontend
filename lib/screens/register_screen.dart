import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../common/async_state.dart';
import '../repository/auth_repository.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_layout.dart';
import '../widgets/error_state.dart';
import '../widgets/loading_state.dart';

/// Halaman Daftar dengan pola state yang sama seperti layar lain:
///   LoadStatus.data    -> formulir (galat seperti email duplikat = banner)
///   LoadStatus.loading -> LoadingState selama proses simulasi
///   LoadStatus.error   -> ErrorState + "Coba Lagi" (galat sistem/simulasi)
/// Akun baru langsung dalam keadaan masuk; router lalu ke beranda.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscure = true;
  bool _obscureConfirm = true;
  LoadStatus _status = LoadStatus.data;
  String? _error; // galat bisnis (banner di formulir)
  String _failMessage = ''; // galat sistem (ErrorState)

  bool get _isLoading => _status == LoadStatus.loading;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  /// Dipanggil tombol "Daftar": validasi dulu, baru kirim.
  void _submit() {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    _attempt();
  }

  /// Proses pendaftaran. Juga dipakai tombol "Coba Lagi".
  Future<void> _attempt() async {
    if (_isLoading) return; // cegah akun ganda akibat ketukan berulang
    final auth = AuthScope.of(context);
    setState(() {
      _status = LoadStatus.loading;
      _error = null;
    });
    try {
      await auth.register(
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      if (mounted) setState(() => _status = LoadStatus.data);
      // Navigasi ditangani redirect router.
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _status = LoadStatus.data;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = LoadStatus.error;
        _failMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _clearError(String _) {
    if (_error != null) setState(() => _error = null);
  }

  Widget _visibilityToggle(bool obscured, VoidCallback onTap) => IconButton(
        tooltip: obscured ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
        icon: Icon(
          obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: AppColors.textMuted,
        ),
        onPressed: onTap,
      );

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Nama Lengkap',
              hint: 'mis. Sarah Wijaya',
              icon: Icons.person_outline,
              controller: _nameCtrl,
              maxLength: 40,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              nextFocusNode: _emailFocus,
              validator: AuthValidators.name,
              onChanged: _clearError,
            ),
            const SizedBox(height: 6),
            AppTextField(
              label: 'Email',
              hint: 'nama@email.com',
              icon: Icons.mail_outline,
              controller: _emailCtrl,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              autofillHints: const [AutofillHints.email],
              nextFocusNode: _passwordFocus,
              validator: AuthValidators.email,
              onChanged: _clearError,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Kata Sandi',
              hint: 'Minimal 8 karakter, huruf & angka',
              icon: Icons.lock_outline,
              controller: _passwordCtrl,
              focusNode: _passwordFocus,
              obscureText: _obscure,
              textCapitalization: TextCapitalization.none,
              autofillHints: const [AutofillHints.newPassword],
              nextFocusNode: _confirmFocus,
              validator: AuthValidators.newPassword,
              onChanged: _clearError,
              suffixIcon: _visibilityToggle(
                  _obscure, () => setState(() => _obscure = !_obscure)),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Konfirmasi Kata Sandi',
              hint: 'Ulangi kata sandi',
              icon: Icons.lock_reset_outlined,
              controller: _confirmCtrl,
              focusNode: _confirmFocus,
              obscureText: _obscureConfirm,
              textCapitalization: TextCapitalization.none,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.done,
              validator:
                  AuthValidators.confirmPassword(() => _passwordCtrl.text),
              onSubmitted: (_) => _submit(),
              onChanged: _clearError,
              suffixIcon: _visibilityToggle(_obscureConfirm,
                  () => setState(() => _obscureConfirm = !_obscureConfirm)),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              AuthErrorBanner(message: _error!),
            ],
            const SizedBox(height: 18),
            AppButton(
              label: 'Daftar',
              icon: Icons.person_add_alt_1,
              loading: _isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final from = GoRouterState.of(context).uri.queryParameters['from'];
    final loginPath = Uri(
      path: '/login',
      queryParameters: from == null ? null : {'from': from},
    ).toString();

    return AuthLayout(
      title: 'Buat Akun Baru',
      subtitle: 'Daftar untuk mulai mengatur aktivitas dan anggota keluarga.',
      form: switch (_status) {
        LoadStatus.loading => const SizedBox(
            height: 260,
            child: LoadingState(message: 'Membuat akun...'),
          ),
        LoadStatus.error => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ErrorState(
                title: 'Gagal mendaftar',
                message: _failMessage,
                onRetry: _attempt,
              ),
              TextButton(
                onPressed: () => setState(() => _status = LoadStatus.data),
                child: const Text('Kembali ke formulir',
                    style: TextStyle(color: AppColors.primaryDark)),
              ),
            ],
          ),
        LoadStatus.data => _buildForm(),
      },
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Sudah punya akun?',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          TextButton(
            onPressed: _isLoading ? null : () => context.go(loginPath),
            child: const Text('Masuk',
                style: TextStyle(
                    fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
          ),
        ],
      ),
    );
  }
}
