// Satu-satunya tempat yang merakit repository + controller, dan satu-satunya
// yang boleh mengimpor implementasi di `data/` milik fitur.
import '../../features/auth/auth.dart';
import '../../features/auth/data/in_memory_auth_repository.dart';
import '../../shared/session/session.dart';

/// Semua objek yang hidup selama aplikasi berjalan.
class AppDependencies {
  const AppDependencies({
    required this.session,
    required this.auth,
  });

  final Session session;
  final AuthController auth;
}

class Injection {
  /// Rakit repository in-memory + controller. Ganti repository di sini
  /// (mis. FirebaseAuthRepository) tanpa menyentuh layar.
  static AppDependencies build() {
    final session = Session();

    final authRepo = InMemoryAuthRepository();

    return AppDependencies(
      session: session,
      auth: AuthController(
        repository: authRepo,
        session: session,
      ),
    );
  }
}
