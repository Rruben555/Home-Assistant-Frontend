import '../../../cores/errors/app_exception.dart';
import '../../../cores/utils/simulation.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';
import 'auth_seed.dart';

class InMemoryAuthRepository implements AuthRepository {
  InMemoryAuthRepository({List<AppUser>? seed}) : _users = List<AppUser>.of(seed ?? AuthSeed.users());

  final List<AppUser> _users;
  AppUser? _current;
  int _seq = 100;

  @override
  AppUser? get currentUser => _current;

  @override
  Future<AppUser> signIn({required String email, required String password}) async {
    await simulateLatency();
    for (final u in _users) {
      if (u.email.toLowerCase() == email.trim().toLowerCase()) {
        if (u.password != password) throw const AppException('Password salah. Periksa kembali password kamu.');
        _current = u;
        return u;
      }
    }
    throw const AppException('Email belum terdaftar. Silakan daftar terlebih dahulu.');
  }

  @override
  Future<AppUser> register({required String name, required String email, required String password}) async {
    await simulateLatency();
    final exists = _users.any((u) => u.email.toLowerCase() == email.trim().toLowerCase());
    if (exists) throw const AppException('Email sudah terdaftar. Gunakan email lain atau masuk.');
    final user = AppUser(id: 'u${_seq++}', name: name.trim(), email: email.trim(), password: password);
    _users.add(user);
    _current = user;
    return user;
  }

  @override
  Future<AppUser> updateProfile({required String name, String? currentPassword, String? newPassword}) async {
    await simulateLatency();
    final user = _current;
    if (user == null) throw const AppException('Sesi berakhir, silakan masuk lagi.');
    var updated = user.copyWith(name: name.trim());
    if (newPassword != null && newPassword.isNotEmpty) {
      if (user.password != currentPassword) throw const AppException('Password saat ini salah.');
      if (newPassword == currentPassword) throw const AppException('Password baru harus berbeda dari password saat ini.');
      updated = updated.copyWith(password: newPassword);
    }
    final i = _users.indexWhere((u) => u.id == user.id);
    if (i >= 0) _users[i] = updated;
    _current = updated;
    return updated;
  }

  @override
  void signOut() => _current = null;
}
