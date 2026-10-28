// Satu-satunya tempat yang merakit repository + controller, dan satu-satunya
// yang boleh mengimpor implementasi di `data/` milik fitur.
import '../../shared/session/session.dart';

/// Semua objek yang hidup selama aplikasi berjalan.
class AppDependencies {
  const AppDependencies({required this.session});

  final Session session;
}

class Injection {
  /// Rakit repository in-memory + controller. Ganti repository di sini
  /// (mis. FirebaseAuthRepository) tanpa menyentuh layar.
  static AppDependencies build() {
    final session = Session();

    return AppDependencies(session: session);
  }
}
