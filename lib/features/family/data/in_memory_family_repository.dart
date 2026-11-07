import 'dart:math';

import 'package:flutter/foundation.dart';
import '../../../cores/errors/app_exception.dart';
import '../../../cores/utils/simulation.dart';
import '../../../shared/role/role.dart';
import '../../../shared/session/session.dart';
import '../../members/members.dart';
import '../domain/family.dart';
import '../domain/family_code.dart';
import '../domain/family_repository.dart';
import 'family_seed.dart';

class InMemoryFamilyRepository extends ChangeNotifier implements FamilyRepository {
  InMemoryFamilyRepository({required MemberRepository members, List<Family>? seed})
      : _members = members,
        _items = List<Family>.of(seed ?? FamilySeed.families());

  final MemberRepository _members;
  final List<Family> _items;
  int _seq = 100;
  final Random _random = Random();

  @override
  Family? byId(String? id) {
    if (id == null) return null;
    for (final f in _items) {
      if (f.id == id) return f;
    }
    return null;
  }

  @override
  Family? byCode(String code) {
    final c = FamilyCode.normalize(code);
    for (final f in _items) {
      if (f.code == c) return f;
    }
    return null;
  }

  @override
  List<Family> familiesOf(String userId) =>
      [for (final f in _items) if (_members.isMember(f.id, userId)) f];

  @override
  Future<List<Family>> loadFamilies(String userId) async {
    await simulateLatency();
    return familiesOf(userId);
  }

  @override
  Future<Family> create({required String name, required SessionUser user}) async {
    await simulateLatency();
    final dup = familiesOf(user.id).any((f) => f.name.trim().toLowerCase() == name.trim().toLowerCase());
    if (dup) throw const AppException('Kamu sudah punya keluarga dengan nama yang sama.');
    final code = FamilyCode.generate(_random, isTaken: (c) => byCode(c) != null); // pastikan unik
    final family = Family(id: 'f${_seq++}', name: name.trim(), code: code);
    _items.add(family);
    _members.addForUser(familyId: family.id, user: user, role: Role.admin);
    notifyListeners();
    return family;
  }

  @override
  Future<Family> join({required String code, required SessionUser user}) async {
    await simulateLatency();
    final family = byCode(code);
    if (family == null) throw const AppException('Kode keluarga tidak ditemukan. Periksa kembali kodenya.');
    if (_members.isMember(family.id, user.id)) {
      throw AppException('Kamu sudah menjadi anggota ${family.name}.');
    }
    _members.joinAsMember(familyId: family.id, user: user);
    notifyListeners();
    return family;
  }
}
