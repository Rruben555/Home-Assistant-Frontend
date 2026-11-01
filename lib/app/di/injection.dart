// Satu-satunya tempat yang merakit repository + controller, dan satu-satunya
// yang boleh mengimpor implementasi di `data/` milik fitur.
import '../../features/auth/auth.dart';
import '../../features/auth/data/in_memory_auth_repository.dart';
import '../../features/members/data/in_memory_member_repository.dart';
import '../../features/members/members.dart';
import '../../shared/session/session.dart';

/// Semua objek yang hidup selama aplikasi berjalan.
class AppDependencies {
  const AppDependencies({
    required this.session,
    required this.auth,
    required this.members,
  });

  final Session session;
  final AuthController auth;
  final MembersController members;
}

class Injection {
  /// Rakit repository in-memory + controller. Ganti repository di sini
  /// (mis. FirebaseAuthRepository) tanpa menyentuh layar.
  static AppDependencies build() {
    final session = Session();

    // Jumlah chore aktif baru tersedia setelah fitur chores ada; sementara selalu 0.
    final memberRepo = InMemoryMemberRepository(
      session: session,
      pendingChoreCount: (_) => 0,
    );
    final authRepo = InMemoryAuthRepository();

    // Anggota saat ini pada Session dihitung dari data members.
    session.bindMemberResolver((userId, familyId) {
      final m = memberRepo.memberOfUser(familyId, userId);
      return m == null ? null : SessionMember(id: m.id, role: m.role);
    });

    return AppDependencies(
      session: session,
      auth: AuthController(
        repository: authRepo,
        session: session,
        onUserNameChanged: memberRepo.syncUserName,
      ),
      members: MembersController(repository: memberRepo, session: session),
    );
  }
}
