import '../domain/app_user.dart';

/// Data simulasi: 1 akun.
/// PENTING: list yang dikembalikan harus growable (JANGAN pakai `const [...]`),
/// karena repository menambah isinya saat register.
class AuthSeed {
  static List<AppUser> users() => [
        AppUser(id: 'u1', name: 'Ven', email: 'ven@example.com', password: 'ven12345'),
      ];
}
