import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../repository/auth_repository.dart';
// [DEBUG] import '../repository/member_repository.dart';
// [DEBUG] import '../repository/task_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../utils/responsive.dart';
import '../widgets/confirm_dialog.dart';

/// Layar Profil & Pengaturan — persona utama aplikasi, preferensi
/// notifikasi, pengelolaan akun (ubah profil, ganti kata sandi, hapus akun),
/// dan keluar akun.
///
/// Mode uji (simulasi galat / reset data) dinonaktifkan lewat komentar
/// bertanda `// [DEBUG]`. Hapus penanda itu untuk mengaktifkannya kembali.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifOn = true;

  @override
  Widget build(BuildContext context) {
    // [DEBUG] final taskRepo = TaskScope.of(context);
    // [DEBUG] final memberRepo = MemberScope.of(context);
    final authRepo = AuthScope.of(context);
    final user = authRepo.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Home Assistant',
                style: TextStyle(fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
            Text('Profil & Pengaturan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          ],
        ),
      ),
      body: ResponsiveListView(
        maxWidth: 720,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // Persona utama aplikasi.
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
                radius: 46,
                backgroundColor: AppColors.mint,
                child: user == null
                    ? const Icon(Icons.person, size: 44, color: AppColors.primaryDark)
                    : Text(user.initial,
                        style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(user?.name ?? 'Pengguna',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text(user?.email ?? '',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13.5, color: AppColors.textMuted)),
          const SizedBox(height: 12),
          const Center(
            child: Pill(
              text: 'Pengelola Rumah Tangga',
              background: AppColors.primaryLight,
              foreground: AppColors.primaryDark,
              icon: Icons.home_rounded,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 22),
          _sectionTitle('Preferensi'),
          AppCard(
            child: Column(
              children: [
                _switchRow(
                  icon: Icons.notifications_active_outlined,
                  title: 'Notifikasi Pengingat',
                  subtitle: 'Tampilkan pengingat saat waktu aktivitas tiba',
                  value: _notifOn,
                  onChanged: (v) => setState(() => _notifOn = v),
                ),
                // [DEBUG] const Divider(height: 22, color: AppColors.divider),
                // [DEBUG] AnimatedBuilder(
                  // [DEBUG] animation: Listenable.merge([taskRepo, memberRepo, authRepo]),
                  // [DEBUG] builder: (context, _) => _switchRow(
                    // [DEBUG] icon: Icons.bug_report_outlined,
                    // [DEBUG] title: 'Simulasikan Galat Memuat Data',
                    // [DEBUG] subtitle: 'Mode uji: daftar, masuk, dan daftar akun akan gagal untuk menguji tombol "Coba Lagi"',
                    // [DEBUG] value: taskRepo.debugSimulateError,
                    // [DEBUG] onChanged: (v) => setState(() {
                      // [DEBUG] taskRepo.debugSimulateError = v;
                      // [DEBUG] memberRepo.debugSimulateError = v;
                      // [DEBUG] authRepo.debugSimulateError = v;
                    // [DEBUG] }),
                  // [DEBUG] ),
                // [DEBUG] ),
              ],
            ),
          ),
          // [DEBUG] const SizedBox(height: 22),
          // [DEBUG] _sectionTitle('Data Simulasi'),
          // [DEBUG] AppCard(
            // [DEBUG] child: Column(
              // [DEBUG] crossAxisAlignment: CrossAxisAlignment.start,
              // [DEBUG] children: [
                // [DEBUG] const Text('Reset Data Simulasi',
                    // [DEBUG] style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                // [DEBUG] const SizedBox(height: 4),
                // [DEBUG] const Text(
                  // [DEBUG] 'Mengembalikan seluruh aktivitas, anggota keluarga, dan riwayat '
                  // [DEBUG] 'ke data contoh awal. Tindakan ini tidak dapat diurungkan.',
                  // [DEBUG] style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                // [DEBUG] ),
                // [DEBUG] const SizedBox(height: 12),
                // [DEBUG] SizedBox(
                  // [DEBUG] width: double.infinity,
                  // [DEBUG] child: OutlinedButton.icon(
                    // [DEBUG] onPressed: () => _confirmReset(context, taskRepo, memberRepo),
                    // [DEBUG] style: OutlinedButton.styleFrom(
                      // [DEBUG] padding: const EdgeInsets.symmetric(vertical: 13),
                      // [DEBUG] side: const BorderSide(color: AppColors.priorityHighBg),
                      // [DEBUG] shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    // [DEBUG] ),
                    // [DEBUG] icon: const Icon(Icons.restore, size: 18, color: AppColors.priorityHigh),
                    // [DEBUG] label: const Text('Reset Data Simulasi',
                        // [DEBUG] style: TextStyle(color: AppColors.priorityHigh, fontWeight: FontWeight.w700)),
                  // [DEBUG] ),
                // [DEBUG] ),
              // [DEBUG] ],
            // [DEBUG] ),
          // [DEBUG] ),
          const SizedBox(height: 22),
          _sectionTitle('Pengaturan Akun'),
          _menuRow(
            icon: Icons.person_outline,
            title: 'Ubah Profil',
            subtitle: 'Ganti nama dan email akun',
            onTap: () => context.push('/profil/edit'),
          ),
          const SizedBox(height: 10),
          _menuRow(
            icon: Icons.lock_outline,
            title: 'Ganti Kata Sandi',
            subtitle: 'Perbarui kata sandi akun Anda',
            onTap: () => context.push('/profil/sandi'),
          ),
          const SizedBox(height: 22),
          _sectionTitle('Tentang Aplikasi'),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _iconTile(Icons.info_outline),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Home Assistant — Frontend Demo',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                      SizedBox(height: 2),
                      Text('Versi 1.0.0',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      SizedBox(height: 8),
                      Text(
                        'Versi 1.0.0 (frontend + data simulasi). Dibangun mengikuti SRS '
                        '"Aplikasi Home Assistant" — pengelolaan aktivitas rumah tangga, '
                        'anggota keluarga, riwayat, dan asisten AI (balasan demo).',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _confirmLogout(context, authRepo),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.priorityHigh,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('Keluar',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: TextButton(
              onPressed: () => _deleteAccount(context),
              child: const Text('Hapus Akun',
                  style: TextStyle(color: AppColors.priorityHigh, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textDark)),
      );

  /// Kotak ikon membulat ala kartu pengaturan: ikon di kotak mint.
  Widget _iconTile(IconData icon) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primaryDark, size: 22),
      );

  /// Satu menu = satu kartu terpisah: kotak ikon, judul + subjudul, panah.
  Widget _menuRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _iconTile(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.3)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _switchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        _iconTile(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.3)),
            ],
          ),
        ),
        Switch(value: value, activeColor: AppColors.primaryDark, onChanged: onChanged),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context, AuthRepository authRepo) async {
    final ok = await confirmDialog(
      context,
      title: 'Keluar dari akun?',
      message: 'Anda harus masuk lagi untuk mengakses aktivitas dan anggota keluarga.',
      confirmLabel: 'Keluar',
    );
    if (!ok) return;
    // Router otomatis mengalihkan ke halaman masuk.
    authRepo.logout();
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final deleted = await showDialog<bool>(
      context: context,
      builder: (_) => const _DeleteAccountDialog(),
    );
    if (deleted != true || !context.mounted) return;
    // Router otomatis mengalihkan ke halaman masuk.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Akun berhasil dihapus.')));
  }

  // [DEBUG] Future<void> _confirmReset(
      // [DEBUG] BuildContext context, TaskRepository taskRepo, MemberRepository memberRepo) async {
    // [DEBUG] final ok = await confirmDialog(
      // [DEBUG] context,
      // [DEBUG] title: 'Reset data simulasi?',
      // [DEBUG] message: 'Semua aktivitas, anggota keluarga, dan riwayat akan dikembalikan ke data contoh awal.',
      // [DEBUG] confirmLabel: 'Reset',
    // [DEBUG] );
    // [DEBUG] if (!ok || !context.mounted) return;
    // [DEBUG] taskRepo.reset();
    // [DEBUG] memberRepo.reset();
    // [DEBUG] ScaffoldMessenger.of(context)
      // [DEBUG] ..hideCurrentSnackBar()
      // [DEBUG] ..showSnackBar(const SnackBar(content: Text('Data simulasi berhasil direset.')));
  // [DEBUG] }
}

/// Dialog hapus akun: meminta kata sandi sebagai konfirmasi.
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (_passwordCtrl.text.isEmpty) {
      setState(() => _error = 'Kata sandi wajib diisi');
      return;
    }
    final auth = AuthScope.of(context);
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await auth.deleteAccount(password: _passwordCtrl.text);
      if (mounted) Navigator.pop(context, true);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hapus akun?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
              'Akun akan dihapus permanen dan tidak dapat dikembalikan. '
              'Masukkan kata sandi untuk melanjutkan.'),
          const SizedBox(height: 14),
          TextField(
            controller: _passwordCtrl,
            obscureText: _obscure,
            enabled: !_loading,
            onSubmitted: (_) => _submit(),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            decoration: InputDecoration(
              hintText: 'Kata sandi',
              errorText: _error,
              suffixIcon: IconButton(
                icon: Icon(
                    _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Hapus Akun',
                  style: TextStyle(color: AppColors.priorityHigh)),
        ),
      ],
    );
  }
}
