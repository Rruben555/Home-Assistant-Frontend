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

/// Layar Ubah Profil: mengganti nama dan email akun yang sedang masuk.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  final _emailFocus = FocusNode();

  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // initState tidak boleh memakai dependOnInheritedWidget (AuthScope.of).
    final user = context
        .getInheritedWidgetOfExactType<AuthScope>()
        ?.notifier
        ?.currentUser;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _emailFocus.dispose();
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
      await auth.updateProfile(name: _nameCtrl.text, email: _emailCtrl.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui.')));
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

  @override
  Widget build(BuildContext context) {
    final initial = _nameCtrl.text.trim().isEmpty
        ? '?'
        : _nameCtrl.text.trim()[0].toUpperCase();

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
            Text('Ubah Profil',
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
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.mint,
                  child: Text(initial,
                      style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark)),
                ),
              ),
            ),
            const SizedBox(height: 22),
            AppTextField(
              label: 'Nama *',
              controller: _nameCtrl,
              hint: 'Nama lengkap',
              icon: Icons.badge_outlined,
              maxLength: 40,
              textCapitalization: TextCapitalization.words,
              nextFocusNode: _emailFocus,
              validator: AuthValidators.name,
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 6),
            AppTextField(
              label: 'Email *',
              controller: _emailCtrl,
              hint: 'nama@email.com',
              icon: Icons.mail_outline,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              textInputAction: TextInputAction.done,
              validator: AuthValidators.email,
              onSubmitted: (_) => _save(),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
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
              label: 'Simpan Perubahan',
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
