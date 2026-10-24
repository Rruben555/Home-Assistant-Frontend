import 'package:flutter/material.dart';
import '../models/task.dart';
import '../data/dummy_data.dart';
import '../models/family_member.dart';
import 'task_repository.dart';

/// Modul CRUD kedua: Anggota Keluarga. Berelasi dengan `TaskRepository`
/// lewat `HouseholdTask.assignedMemberId` (relasi ID antar modul).
class MemberRepository extends ChangeNotifier {
  MemberRepository(this._taskRepository) {
    _seed();
  }

  final TaskRepository _taskRepository;
  final List<FamilyMember> _members = [];
  int _seq = 0;

  void _seed() {
    _members
      ..clear()
      ..addAll(DummyData.members());
  }

  String _newId() => 'm-${DateTime.now().microsecondsSinceEpoch}-${_seq++}';

  List<FamilyMember> get members => List.unmodifiable(_members);

  FamilyMember? findById(String? id) {
    if (id == null) return null;
    for (final m in _members) {
      if (m.id == id) return m;
    }
    return null;
  }

  /// Jumlah aktivitas aktif (belum selesai) yang ditugaskan ke anggota ini.
  int activeTaskCount(String memberId) => _taskRepository.tasks
      .where((t) => t.assignedMemberId == memberId && !t.isDone)
      .length;

  Future<List<FamilyMember>> loadMembers({bool? simulateError}) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return members;
  }

  Future<void> addMember({
    required String name,
    required MemberRole role,
    required TaskCategory favoriteCategory,
    required AvatarColorOption avatarColor,
    required bool active,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _members.add(FamilyMember(
      id: _newId(),
      name: name,
      role: role,
      favoriteCategory: favoriteCategory,
      avatarColor: avatarColor,
      active: active,
    ));
    notifyListeners();
  }

  Future<void> updateMember(FamilyMember member) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final i = _members.indexWhere((m) => m.id == member.id);
    if (i == -1) return;
    _members[i] = member;
    notifyListeners();
  }

  /// Menghapus anggota sekaligus melepas relasi ID pada aktivitas yang
  /// masih menunjuk ke anggota ini, agar tidak ada relasi menggantung.
  Future<void> deleteMember(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _members.removeWhere((m) => m.id == id);
    _taskRepository.unassignMember(id);
    notifyListeners();
  }

  void restore(FamilyMember member) {
    if (findById(member.id) != null) return;
    _members.add(member);
    notifyListeners();
  }
}

class MemberScope extends InheritedNotifier<MemberRepository> {
  const MemberScope({
    super.key,
    required MemberRepository repository,
    required super.child,
  }) : super(notifier: repository);

  static MemberRepository of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MemberScope>();
    assert(scope != null, 'MemberScope tidak ditemukan di widget tree');
    return scope!.notifier!;
  }
}
