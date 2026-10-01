import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'repository/auth_repository.dart';
import 'repository/member_repository.dart';
import 'repository/task_repository.dart';
import 'screens/ai_assistant_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/member_form_screen.dart';
import 'screens/member_list_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/task_detail_screen.dart';
import 'screens/task_form_screen.dart';
import 'widgets/not_found_page.dart';

/// Daftar rute aplikasi:
///   /                  Beranda        /keluarga   Daftar anggota
///   /ai                AI Asisten     /riwayat    Riwayat
///   /profil            Profil         (kelima tab di atas berbagi MainShell)
///   /profil/edit       Ubah profil (nama & email)
///   /profil/sandi      Ganti kata sandi
///   /task/new          Form tambah aktivitas
///   /task/:id          Detail aktivitas
///   /task/:id/edit     Form ubah aktivitas
///   /member/new        Form tambah anggota
///   /member/:id/edit   Form ubah anggota
///   /login             Masuk          /register   Daftar
/// Semua rute selain /login dan /register hanya bisa dibuka setelah masuk;
/// bila belum, pengguna dialihkan ke /login?from=<alamat tujuan>.
/// Alamat lain -> errorBuilder. ID yang tidak ada -> pesan "tidak ditemukan".
GoRouter createAppRouter(AuthRepository auth) => GoRouter(
  initialLocation: '/',
  // Router mengevaluasi ulang `redirect` setiap status login berubah.
  refreshListenable: auth,
  redirect: (context, state) {
    final loc = state.matchedLocation;
    final onAuthPage = _authPaths.contains(loc);

    if (!auth.isLoggedIn) {
      if (onAuthPage) return null;
      // Simpan tujuan awal agar setelah login kembali ke sana.
      return loc == '/'
          ? '/login'
          : Uri(path: '/login', queryParameters: {'from': state.uri.toString()})
              .toString();
    }

    // Sudah masuk tapi membuka halaman masuk/daftar -> arahkan keluar.
    if (onAuthPage) return _safeFrom(state.uri.queryParameters['from']);
    return null;
  },
  errorBuilder: (context, state) => NotFoundPage(
    title: 'Halaman tidak ditemukan',
    message: 'Alamat "${state.uri}" tidak dikenali.',
  ),
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

    // Lima tab utama. State tiap tab dipertahankan saat berpindah tab.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/keluarga', builder: (_, __) => const MemberListScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/ai', builder: (_, __) => const AiAssistantScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/riwayat', builder: (_, __) => const HistoryScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/profil', builder: (_, __) => const ProfileScreen()),
        ]),
      ],
    ),

    // Layar penuh di atas tab. '/task/new' harus sebelum '/task/:id'.
    GoRoute(path: '/task/new', builder: (_, __) => const TaskFormScreen()),
    GoRoute(
      path: '/task/:id',
      builder: (_, state) =>
          TaskDetailScreen(taskId: state.pathParameters['id'] ?? ''),
    ),
    GoRoute(
      path: '/task/:id/edit',
      builder: (_, state) =>
          _TaskEditRoute(id: state.pathParameters['id'] ?? ''),
    ),
    GoRoute(path: '/profil/edit', builder: (_, __) => const EditProfileScreen()),
    GoRoute(path: '/profil/sandi', builder: (_, __) => const ChangePasswordScreen()),
    GoRoute(path: '/member/new', builder: (_, __) => const MemberFormScreen()),
    GoRoute(
      path: '/member/:id/edit',
      builder: (_, state) =>
          _MemberEditRoute(id: state.pathParameters['id'] ?? ''),
    ),
  ],
);

const _authPaths = {'/login', '/register'};

/// Hanya terima alamat internal yang aman (diawali '/', bukan '//' dan bukan
/// halaman auth) agar parameter `from` tidak bisa dipakai mengalihkan ke
/// tempat lain atau membuat loop.
String _safeFrom(String? from) {
  if (from == null || !from.startsWith('/') || from.startsWith('//')) return '/';
  final path = Uri.tryParse(from)?.path;
  if (path == null || _authPaths.contains(path)) return '/';
  return from;
}

/// Mencari aktivitas berdasarkan ID di URL; bila tidak ada -> NotFoundPage.
class _TaskEditRoute extends StatelessWidget {
  final String id;

  const _TaskEditRoute({required this.id});

  @override
  Widget build(BuildContext context) {
    final task = TaskScope.of(context).findById(id);
    if (task == null) {
      return NotFoundPage(
        title: 'Ubah Aktivitas',
        message: 'Aktivitas dengan ID "$id" tidak ditemukan.',
      );
    }
    return TaskFormScreen(task: task);
  }
}

/// Mencari anggota berdasarkan ID di URL; bila tidak ada -> NotFoundPage.
class _MemberEditRoute extends StatelessWidget {
  final String id;

  const _MemberEditRoute({required this.id});

  @override
  Widget build(BuildContext context) {
    final member = MemberScope.of(context).findById(id);
    if (member == null) {
      return NotFoundPage(
        title: 'Ubah Anggota',
        message: 'Anggota dengan ID "$id" tidak ditemukan.',
      );
    }
    return MemberFormScreen(member: member);
  }
}