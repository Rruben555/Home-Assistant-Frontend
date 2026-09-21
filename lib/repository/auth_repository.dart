import 'package:flutter/material.dart';
import '../models/app_user.dart';

/// Galat autentikasi dengan pesan yang siap ditampilkan ke pengguna.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class _StoredUser {
  final AppUser user;
  final String password;
  const _StoredUser(this.user, this.password);
}

/// Modul autentikasi (register, login, logout) dengan data simulasi
/// in-memory, mengikuti pola `TaskRepository` / `MemberRepository`.
///
/// CATATAN: kata sandi di sini disimpan apa adanya HANYA karena ini data
/// simulasi tanpa backend. Pada aplikasi sungguhan, kirim kredensial ke
/// server lewat HTTPS dan jangan pernah menyimpan kata sandi di perangkat.

// DEMO AKUN
class AuthRepository extends ChangeNotifier {
  AuthRepository() {
    // Akun demo agar login bisa langsung dicoba.
    _users.add(const _StoredUser(
      AppUser(id: 'u-demo', name: 'Bu Sarah', email: demoEmail),
      demoPassword,
     ));
   }

  static const demoEmail = 'sarah@example.com';
  static const demoPassword = 'password123';
  // DEMO AKUN

  final List<_StoredUser> _users = [];
  AppUser? _currentUser;
  int _seq = 0;

  // [DEBUG] /// Mode uji (sama seperti repository lain): bila true, register & login
  // [DEBUG] /// gagal dengan galat sistem sehingga skenario "Coba Lagi" bisa diuji.
  // [DEBUG] bool debugSimulateError = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Email tidak peka huruf besar/kecil dan spasi di tepi diabaikan.
  static String normalizeEmail(String email) => email.trim().toLowerCase();

  _StoredUser? _find(String email) {
    final key = normalizeEmail(email);
    for (final u in _users) {
      if (u.user.email == key) return u;
    }
    return null;
  }

  /// Mendaftarkan akun baru lalu langsung masuk.
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    // [DEBUG] if (debugSimulateError) {
      // [DEBUG] throw Exception('Simulasi gagal mendaftarkan akun');
    // [DEBUG] }
    if (_find(email) != null) {
      throw const AuthException('Email sudah terdaftar. Silakan masuk.');
    }
    final user = AppUser(
      id: 'u-${DateTime.now().microsecondsSinceEpoch}-${_seq++}',
      name: name.trim(),
      email: normalizeEmail(email),
    );
    _users.add(_StoredUser(user, password));
    _currentUser = user;
    notifyListeners();
    return user;
  }

  /// Masuk dengan email & kata sandi. Pesan galat sengaja sama untuk
  /// "email tidak ada" dan "kata sandi salah" agar tidak membocorkan
  /// email mana yang terdaftar.
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    // [DEBUG] if (debugSimulateError) {
      // [DEBUG] throw Exception('Simulasi gagal masuk ke akun');
    // [DEBUG] }
    final stored = _find(email);
    if (stored == null || stored.password != password) {
      throw const AuthException('Email atau kata sandi salah.');
    }
    _currentUser = stored.user;
    notifyListeners();
    return stored.user;
  }

  void logout() {
    if (_currentUser == null) return;
    _currentUser = null;
    notifyListeners();
  }

  /// Mengubah nama & email akun yang sedang masuk.
  Future<AppUser> updateProfile({
    required String name,
    required String email,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final current = _currentUser;
    final i = current == null
        ? -1
        : _users.indexWhere((u) => u.user.id == current.id);
    if (current == null || i == -1) {
      throw const AuthException('Sesi berakhir. Silakan masuk lagi.');
    }
    final newEmail = normalizeEmail(email);
    final other = _find(newEmail);
    if (other != null && other.user.id != current.id) {
      throw const AuthException('Email sudah dipakai akun lain.');
    }
    final updated = AppUser(id: current.id, name: name.trim(), email: newEmail);
    _users[i] = _StoredUser(updated, _users[i].password);
    _currentUser = updated;
    notifyListeners();
    return updated;
  }

  /// Mengganti kata sandi. Kata sandi lama harus benar.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final current = _currentUser;
    final i = current == null
        ? -1
        : _users.indexWhere((u) => u.user.id == current.id);
    if (current == null || i == -1) {
      throw const AuthException('Sesi berakhir. Silakan masuk lagi.');
    }
    if (_users[i].password != currentPassword) {
      throw const AuthException('Kata sandi lama salah.');
    }
    if (currentPassword == newPassword) {
      throw const AuthException(
          'Kata sandi baru tidak boleh sama dengan yang lama.');
    }
    _users[i] = _StoredUser(_users[i].user, newPassword);
    notifyListeners();
  }

  /// Menghapus akun yang sedang masuk (butuh kata sandi), lalu keluar.
  Future<void> deleteAccount({required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final current = _currentUser;
    final i = current == null
        ? -1
        : _users.indexWhere((u) => u.user.id == current.id);
    if (current == null || i == -1) {
      throw const AuthException('Sesi berakhir. Silakan masuk lagi.');
    }
    if (_users[i].password != password) {
      throw const AuthException('Kata sandi salah.');
    }
    _users.removeAt(i);
    _currentUser = null;
    notifyListeners();
  }
}

class AuthScope extends InheritedNotifier<AuthRepository> {
  const AuthScope({
    super.key,
    required AuthRepository repository,
    required super.child,
  }) : super(notifier: repository);

  static AuthRepository of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope tidak ditemukan di widget tree');
    return scope!.notifier!;
  }
}
