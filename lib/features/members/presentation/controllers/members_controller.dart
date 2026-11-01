import 'package:flutter/foundation.dart';
import '../../../../shared/role/role.dart';
import '../../../../shared/session/session.dart';
import '../../domain/member.dart';
import '../../domain/member_repository.dart';

/// Penghubung layar anggota dengan [MemberRepository]. Setiap perubahan data
/// diteruskan ke pendengar, jadi layar cukup memantau controller ini.
class MembersController extends ChangeNotifier {
  MembersController({required MemberRepository repository, required Session session})
      : _repo = repository,
        _session = session {
    _repo.addListener(notifyListeners);
  }

  final MemberRepository _repo;
  final Session _session;

  @override
  void dispose() {
    _repo.removeListener(notifyListeners);
    super.dispose();
  }

  /// Anggota keluarga yang sedang dipilih.
  List<Member> get members => _repo.snapshot;

  Member? byId(String id) => _repo.byId(id);
  String nameOf(String id) => _repo.nameOf(id);

  /// Peran dan id anggota milik akun yang sedang masuk (pada keluarga terpilih).
  Role? get myRole => _session.role;
  String? get myMemberId => _session.member?.id;
  bool get isAdmin => _session.isAdmin;
  bool isMe(String memberId) => myMemberId == memberId;

  Future<List<Member>> loadMembers() => _repo.loadMembers();
  Future<Member> loadMember(String id) => _repo.loadMember(id);
  Future<void> delete(String id) => _repo.delete(id);
  Future<Member> setAdmin(String id, {required bool admin}) => _repo.setAdmin(id, admin: admin);
}
