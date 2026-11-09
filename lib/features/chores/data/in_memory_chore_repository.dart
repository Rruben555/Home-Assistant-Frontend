import 'package:flutter/foundation.dart';
import '../../../cores/errors/app_exception.dart';
import '../../../cores/utils/simulation.dart';
import '../../../shared/policies/chore_policy.dart';
import '../../../shared/policies/policy_guard.dart';
import '../../../shared/session/session.dart';
import '../../members/members.dart';
import '../domain/chore.dart';
import '../domain/chore_repository.dart';
import 'chore_seed.dart';

class InMemoryChoreRepository extends ChangeNotifier implements ChoreRepository {
  InMemoryChoreRepository({
    required Session session,
    required MemberLookup members,
    List<Chore>? seed,
  })  : _session = session,
        _members = members,
        _items = List<Chore>.of(seed ?? ChoreSeed.chores());

  final Session _session;
  final MemberLookup _members;
  final List<Chore> _items;
  int _seq = 1000;

  String? get _familyId => _session.familyId;
  List<Chore> get _scoped => [for (final c in _items) if (c.familyId == _familyId) c];

  void _requireManage() => requireAllowed(ChorePolicy.canManage(_session.role));

  bool _canComplete(Chore c) => ChorePolicy.canComplete(
        role: _session.role,
        isAssignee: ChorePolicy.isAssignedTo(
          userEmail: _session.user?.email,
          assigneeEmail: _members.byId(c.assigneeId)?.email,
        ),
      );

  @override
  int get pendingCount => _scoped.where((c) => !c.isCompleted).length;

  @override
  int pendingCountFor(String memberId) =>
      _items.where((c) => !c.isCompleted && c.assigneeId == memberId).length;

  @override
  Future<List<Chore>> loadChores() async {
    await simulateLatency();
    return _scoped;
  }

  @override
  Future<Chore> loadChore(String id) async {
    await simulateLatency();
    return _find(id);
  }

  Chore _find(String id) {
    for (final c in _items) {
      if (c.id == id) return c;
    }
    throw NotFoundException('Chore dengan ID "$id" tidak ditemukan.');
  }

  void _ensureNotDuplicate(Chore draft) {
    final dup = _items.any((c) =>
        c.id != draft.id &&
        c.name.trim().toLowerCase() == draft.name.trim().toLowerCase() &&
        c.assigneeId == draft.assigneeId &&
        c.scheduledAt == draft.scheduledAt);
    if (dup) {
      throw const AppException('Chore yang sama sudah ada untuk anggota dan jadwal tersebut.');
    }
  }

  @override
  Future<Chore> create(Chore draft) async {
    await simulateLatency();
    _requireManage();
    _ensureNotDuplicate(draft);
    final chore = draft.copyWith(id: 'c${_seq++}', familyId: _familyId);
    _items.add(chore);
    notifyListeners();
    return chore;
  }

  @override
  Future<Chore> update(Chore chore) async {
    await simulateLatency();
    _requireManage();
    final i = _items.indexWhere((c) => c.id == chore.id);
    if (i < 0) throw NotFoundException('Chore dengan ID "${chore.id}" tidak ditemukan.');
    _ensureNotDuplicate(chore);
    _items[i] = chore;
    notifyListeners();
    return chore;
  }

  @override
  Future<void> complete(String id) async {
    await simulateLatency();
    final i = _items.indexWhere((c) => c.id == id);
    if (i < 0) throw NotFoundException('Chore dengan ID "$id" tidak ditemukan.');
    requireAllowed(_canComplete(_items[i]), 'Kamu hanya dapat menyelesaikan tugas yang ditugaskan kepadamu.');
    if (_items[i].isCompleted) return; // cegah proses ganda
    _items[i] = _items[i].copyWith(isCompleted: true, completedAt: DateTime.now());
    notifyListeners();
  }

  @override
  Future<void> delete(String id) async {
    await simulateLatency();
    _requireManage();
    final before = _items.length;
    _items.removeWhere((c) => c.id == id);
    if (_items.length == before) throw NotFoundException('Chore dengan ID "$id" tidak ditemukan.');
    notifyListeners();
  }
}
