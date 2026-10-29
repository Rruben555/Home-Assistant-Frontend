import 'app_user.dart';

/// Kontrak autentikasi. Implementasi sekarang in-memory; nanti FirebaseAuthRepository.
abstract interface class AuthRepository {
  AppUser? get currentUser;

  Future<AppUser> signIn({required String email, required String password});

  Future<AppUser> register({required String name, required String email, required String password});

  /// Ubah nama, dan password bila [newPassword] diisi (wajib [currentPassword] yang benar).
  Future<AppUser> updateProfile({required String name, String? currentPassword, String? newPassword});

  void signOut();
}
