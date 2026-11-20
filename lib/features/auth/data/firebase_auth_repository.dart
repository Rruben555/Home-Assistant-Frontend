import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../cores/errors/app_exception.dart';
import '../../../cores/firebase/firebase_guard.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// Password tidak pernah disimpan di aplikasi, jadi diisi kosong.
  AppUser _toAppUser(User u) {
    final email = (u.email ?? '').toLowerCase();
    final name = (u.displayName ?? '').trim();
    return AppUser(id: u.uid, name: name.isEmpty ? email.split('@').first : name, email: email, password: '');
  }

  @override
  AppUser? get currentUser {
    final u = _auth.currentUser;
    return u == null ? null : _toAppUser(u);
  }

  @override
  Future<AppUser> signIn({required String email, required String password}) async {
    final cred = await firebaseCall(
      () => _auth.signInWithEmailAndPassword(email: email.trim(), password: password),
    );
    final user = cred.user;
    if (user == null) throw const AppException('Gagal masuk. Silakan coba lagi.');
    return _toAppUser(user);
  }

  @override
  Future<AppUser> register({required String name, required String email, required String password}) {
    return firebaseCall(() async {
      final cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      final user = cred.user;
      if (user == null) throw const AppException('Pendaftaran gagal. Silakan coba lagi.');
      await user.updateDisplayName(name.trim());
      await user.reload();
      return _toAppUser(_auth.currentUser ?? user);
    });
  }

  @override
  Future<AppUser> updateProfile({required String name, String? currentPassword, String? newPassword}) {
    final user = _auth.currentUser;
    if (user == null) throw const AppException('Sesi berakhir, silakan masuk lagi.');
    final wantsPassword = newPassword != null && newPassword.isNotEmpty;

    return firebaseCall(() async {
      if (wantsPassword) {
        if (newPassword == currentPassword) {
          throw const AppException('Password baru harus berbeda dari password saat ini.');
        }
        // Verifikasi password lama dengan autentikasi ulang.
        try {
          await user.reauthenticateWithCredential(
            EmailAuthProvider.credential(email: user.email ?? '', password: currentPassword ?? ''),
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
            throw const AppException('Password saat ini salah.');
          }
          rethrow;
        }
        await user.updatePassword(newPassword);
      }
      await user.updateDisplayName(name.trim());
      await user.reload();
      return _toAppUser(_auth.currentUser ?? user);
    });
  }

  @override
  void signOut() {
    unawaited(_auth.signOut());
  }
}
