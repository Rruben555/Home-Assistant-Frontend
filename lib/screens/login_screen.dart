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
//DEMO
// import '../config/app_config.dart';
//DEMO

/// Halaman Masuk dengan pola state yang sama seperti layar lain:
///   LoadStatus.data    -> formulir (galat kredensial tampil sebagai banner)
///   LoadStatus.loading -> LoadingState selama proses simulasi
///   LoadStatus.error   -> ErrorState + "Coba Lagi" (galat sistem/simulasi)
/// Setelah login berhasil, router (refreshListenable) memindahkan pengguna
/// ke beranda atau ke alamat asal (`?from=`).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordFocus = FocusNode();

  bool _obscure = true;
  LoadStatus _status = LoadStatus.data;
  String? _error; // galat kredensial (banner di formulir)
  String _failMessage = ''; // galat sistem (ErrorState)

  bool get _isLoading => _status == LoadStatus.loading;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  /// Dipanggil tombol "Masuk": validasi dulu, baru kirim.
  void _submit() {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    _attempt();
  }

  /// Proses login. Juga dipakai tombol "Coba Lagi" (data sudah tervalidasi,
  /// dan formulir tidak sedang tampil sehingga tidak divalidasi ulang).
  Future<void> _attempt() async {
    if (_isLoading) return; // cegah ketukan ganda
    final auth = AuthScope.of(context);
    setState(() {
      _status = LoadStatus.loading;
      _error = null;
    });
    try {
      await auth.login(email: _emailCtrl.text, password: _passwordCtrl.text);
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
  //DEMO
  // void _fillDemo() {
  //   setState(() {
  //     _emailCtrl.text = AuthRepository.demoEmail;
  //     _passwordCtrl.text = AuthRepository.demoPassword;
  //     _error = null;
  //   });
  // }
  //DEMO  

  void _clearError(String _) {
    if (_error != null) setState(() => _error = null);
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Email',
              hint: 'nama@email.com',
              icon: Icons.mail_outline,
              controller: _emailCtrl,
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
              hint: 'Masukkan kata sandi',
              icon: Icons.lock_outline,
              controller: _passwordCtrl,
              focusNode: _passwordFocus,
              obscureText: _obscure,
              textCapitalization: TextCapitalization.none,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.done,
              validator: AuthValidators.passwordRequired,
              onSubmitted: (_) => _submit(),
              onChanged: _clearError,
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.textMuted,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              AuthErrorBanner(message: _error!),
            ],
            const SizedBox(height: 18),
            AppButton(
              label: 'Masuk',
              icon: Icons.login,
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
    final registerPath = Uri(
      path: '/register',
      queryParameters: from == null ? null : {'from': from},
    ).toString();

    return AuthLayout(
      title: 'Selamat Datang Kembali',
      subtitle: 'Masuk untuk mengelola aktivitas rumah tangga Anda.',
      form: switch (_status) {
        LoadStatus.loading => const SizedBox(
            height: 260,
            child: LoadingState(message: 'Sedang masuk...'),
          ),
        LoadStatus.error => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ErrorState(
                title: 'Gagal masuk',
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
          const Text('Belum punya akun?',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          TextButton(
            onPressed: _isLoading ? null : () => context.go(registerPath),
            child: const Text('Daftar',
                style: TextStyle(
                    fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
          ),
        ],
      ),
    );
  }
}
