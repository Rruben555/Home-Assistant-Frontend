import '../../../shared/session/session.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });
  final String id;
  final String name;
  final String email;
  final String password;

  AppUser copyWith({String? name, String? password}) => AppUser(
        id: id,
        name: name ?? this.name,
        email: email,
        password: password ?? this.password,
      );

  /// Versi aman (tanpa password) yang dibagikan ke fitur lain lewat [Session].
  SessionUser toSessionUser() => SessionUser(id: id, name: name, email: email);
}
