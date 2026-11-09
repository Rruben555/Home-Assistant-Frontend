import 'package:flutter/foundation.dart';
import '../../../../shared/policies/chore_policy.dart';
import '../../../../shared/session/session.dart';
import '../../../members/members.dart';
import '../../domain/chore.dart';
import '../../domain/chore_repository.dart';

/// Penghubung layar chore dengan [ChoreRepository]. Setiap perubahan data
/// diteruskan ke pendengar, jadi layar cukup memantau controller ini.
class ChoresController extends ChangeNotifier {
  ChoresController({
    required ChoreRepository repository,
    required MemberLookup members,
    required Session session,
  })  : _repo = repository,
        _members = members,
        _session = session {
    _repo.addListener(notifyListeners);
  }

  final ChoreRepository _repo;
  final MemberLookup _members;
  final Session _session;

  @override
  void dispose() {
    _repo.removeListener(notifyListeners);
    super.dispose();
  }

  bool get isAdmin => _session.isAdmin;

  /// Chore belum selesai pada keluarga yang sedang dipilih.
  int get pendingCount => _repo.pendingCount;

  /// Untuk menyembunyikan aksi di UI; repository tetap menolak aksi yang tidak diizinkan.
  bool canComplete(Chore c) => ChorePolicy.canComplete(
        role: _session.role,
        isAssignee: ChorePolicy.isAssignedTo(
          userEmail: _session.user?.email,
          assigneeEmail: _members.byId(c.assigneeId)?.email,
        ),
      );

  Future<List<Chore>> loadChores() => _repo.loadChores();
  Future<Chore> loadChore(String id) => _repo.loadChore(id);
  Future<Chore> create(Chore draft) => _repo.create(draft);
  Future<Chore> update(Chore chore) => _repo.update(chore);
  Future<void> complete(String id) => _repo.complete(id);
  Future<void> delete(String id) => _repo.delete(id);
}
