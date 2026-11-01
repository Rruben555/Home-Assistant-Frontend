import 'package:flutter/foundation.dart';
import '../../../cores/errors/app_exception.dart';
import '../../../cores/utils/simulation.dart';
import '../../../shared/policies/member_policy.dart';
import '../../../shared/policies/policy_guard.dart';
import '../../../shared/role/role.dart';
import '../../../shared/session/session.dart';
import '../domain/member.dart';
import '../domain/member_repository.dart';
import 'member_seed.dart';

class InMemoryMemberRepository extends ChangeNotifier implements MemberRepository {
  InMemoryMemberRepository({
    required Session session,
    required PendingChoreCount pendingChoreCount,
    List<Member>? seed,
  })  : _session = session,
        _pendingChoreCount = pendingChoreCount,
        _items = List<Member>.of(seed ?? MemberSeed.members());

  final Session _session;
  final PendingChoreCount _pendingChoreCount;
  final List<Member> _items;
  int _seq = 100;

  String? get _familyId => _session.familyId;
  List<Member> get _scoped => [for (final m in _items) if (m.familyId == _familyId) m];

  void _requireManage() => requireAllowed(MemberPolicy.canManage(_session.role));

  @override
  List<Member> get snapshot => List<Member>.unmodifiable(_scoped);

  @override
  Member? byId(String id) {
    for (final m in _items) {
      if (m.id == id) return m;
    }
    return null;
  }

  @override
  String nameOf(String id) => byId(id)?.name ?? Member.removedName;

  @override
  bool isMember(String familyId, String userId) =>
      _items.any((m) => m.familyId == familyId && m.userId == userId);

  @override
  int adminCountIn(String familyId) =>
      _items.where((m) => m.familyId == familyId && m.role == Role.admin).length;

  @override
  int countIn(String familyId) => _items.where((m) => m.familyId == familyId).length;

  @override
  Member? memberOfUser(String familyId, String userId) {
    for (final m in _items) {
      if (m.familyId == familyId && m.userId == userId) return m;
    }
    return null;
  }

  @override
  Future<List<Member>> loadMembers() async {
    await simulateLatency();
    return _scoped;
  }

  @override
  Future<Member> loadMember(String id) async {
    await simulateLatency();
    final m = byId(id);
    if (m == null) throw NotFoundException('Anggota dengan ID "$id" tidak ditemukan.');
    return m;
  }

  void _ensureEmailFree(String familyId, String email, String? exceptId) {
    final dup = _items.any((m) =>
        m.familyId == familyId && m.id != exceptId && m.email.toLowerCase() == email.trim().toLowerCase());
    if (dup) throw AppException('Email $email sudah terdaftar sebagai anggota.');
  }

  void _ensureNotLastAdminDemoted(Member current, Role newRole) {
    final allowed = MemberPolicy.canChangeRole(
      current: current.role,
      next: newRole,
      adminCount: adminCountIn(current.familyId),
    );
    if (!allowed) {
      throw const AppException('Keluarga harus punya minimal 1 admin. Jadikan anggota lain admin dulu.');
    }
  }

  @override
  Future<Member> create(Member draft) async {
    await simulateLatency();
    _requireManage();
    final fid = _familyId ?? draft.familyId;
    _ensureEmailFree(fid, draft.email, null);
    final m = draft.copyWith(id: 'm${_seq++}', familyId: fid);
    _items.add(m);
    notifyListeners();
    return m;
  }

  @override
  Future<Member> update(Member member) async {
    await simulateLatency();
    final i = _items.indexWhere((m) => m.id == member.id);
    if (i < 0) throw NotFoundException('Anggota dengan ID "${member.id}" tidak ditemukan.');
    _requireManage();
    _ensureNotLastAdminDemoted(_items[i], member.role);
    _ensureEmailFree(_items[i].familyId, member.email, member.id);
    _items[i] = member;
    notifyListeners();
    return member;
  }

  @override
  Future<void> delete(String id) async {
    await simulateLatency();
    _requireManage();
    final target = byId(id);
    if (target != null &&
        !MemberPolicy.canDelete(target: target.role, adminCount: adminCountIn(target.familyId))) {
      throw const AppException('Admin terakhir tidak dapat dihapus. Jadikan anggota lain admin dulu.');
    }
    final pending = _pendingChoreCount(id);
    if (pending > 0) {
      throw AppException(
          'Anggota masih memiliki $pending chore aktif. Pindahkan atau selesaikan chore tersebut dulu.');
    }
    final before = _items.length;
    _items.removeWhere((m) => m.id == id);
    if (_items.length == before) throw NotFoundException('Anggota dengan ID "$id" tidak ditemukan.');
    notifyListeners();
  }

  @override
  Future<Member> setAdmin(String id, {required bool admin}) async {
    await simulateLatency();
    _requireManage();
    final i = _items.indexWhere((m) => m.id == id);
    if (i < 0) throw NotFoundException('Anggota dengan ID "$id" tidak ditemukan.');
    final newRole = admin ? Role.admin : Role.member;
    _ensureNotLastAdminDemoted(_items[i], newRole);
    final updated = _items[i].copyWith(role: newRole);
    _items[i] = updated;
    notifyListeners();
    return updated;
  }

  @override
  void syncUserName(String userId, String name) {
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].userId == userId) _items[i] = _items[i].copyWith(name: name);
    }
    notifyListeners();
  }

  @override
  Member joinAsMember({required String familyId, required SessionUser user}) {
    final email = user.email.trim().toLowerCase();
    final i = _items.indexWhere(
        (m) => m.familyId == familyId && m.userId == null && m.email.trim().toLowerCase() == email);
    if (i >= 0) {
      final claimed = _items[i].copyWith(userId: user.id);
      _items[i] = claimed;
      notifyListeners();
      return claimed;
    }
    return addForUser(familyId: familyId, user: user, role: Role.member);
  }

  @override
  Member addForUser({required String familyId, required SessionUser user, Role role = Role.admin}) {
    final m = Member(
      id: 'm${_seq++}',
      familyId: familyId,
      name: user.name,
      email: user.email,
      role: role,
      userId: user.id,
    );
    _items.add(m);
    notifyListeners();
    return m;
  }
}
