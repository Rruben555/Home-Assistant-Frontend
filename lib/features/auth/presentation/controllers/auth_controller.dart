import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../shared/session/session.dart';
import '../../domain/auth_repository.dart';

/// Alur masuk / daftar / ubah profil / keluar. Hasilnya dicatat ke [Session].
class AuthController extends ChangeNotifier {
  AuthController({
    required AuthRepository repository,
    required Session session,
    this.onUserNameChanged,
    this.onSignedIn,
    this.onSignedOut,
  })  : _repo = repository,
        _session = session;

  final AuthRepository _repo;
  final Session _session;

  /// Dipanggil setelah nama pengguna berubah (dirakit di DI untuk menyamakan nama anggota).
  final FutureOr<void> Function(String userId, String name)? onUserNameChanged;

  /// Dipanggil setelah akun berhasil masuk/daftar, sebelum Session terisi
  /// (dirakit di DI untuk memuat keluarga + anggota dari Firebase).
  final Future<void> Function()? onSignedIn;

  /// Dipanggil saat keluar (dirakit di DI untuk mengosongkan cache).
  final void Function()? onSignedOut;

  Future<void> _afterAuth() async {
    try {
      await onSignedIn?.call();
    } catch (_) {
      _repo.signOut(); // jangan biarkan sesi setengah jadi
      rethrow;
    }
  }

  SessionUser? get currentUser => _session.user;
  bool get isLoggedIn => _session.isLoggedIn;

  Future<void> signIn({required String email, required String password}) async {
    final user = await _repo.signIn(email: email, password: password);
    await _afterAuth();
    _session.signIn(user.toSessionUser());
    notifyListeners();
  }

  Future<void> register({required String name, required String email, required String password}) async {
    final user = await _repo.register(name: name, email: email, password: password);
    await _afterAuth();
    _session.signIn(user.toSessionUser());
    notifyListeners();
  }

  Future<void> updateProfile({required String name, String? currentPassword, String? newPassword}) async {
    final user = await _repo.updateProfile(name: name, currentPassword: currentPassword, newPassword: newPassword);
    _session.updateUser(user.toSessionUser());
    await onUserNameChanged?.call(user.id, user.name);
    notifyListeners();
  }

  void logout() {
    _repo.signOut();
    onSignedOut?.call();
    _session.signOut();
    notifyListeners();
  }
}
