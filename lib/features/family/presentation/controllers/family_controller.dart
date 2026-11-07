import 'package:flutter/foundation.dart';
import '../../../../cores/errors/app_exception.dart';
import '../../../../shared/session/session.dart';
import '../../../members/members.dart';
import '../../domain/family.dart';
import '../../domain/family_repository.dart';

/// Penghubung layar keluarga dengan [FamilyRepository]. Perubahan keluarga maupun
/// anggota diteruskan ke pendengar (jumlah anggota dan keanggotaan ikut berubah).
class FamilyController extends ChangeNotifier {
  FamilyController({
    required FamilyRepository repository,
    required MemberRepository members,
    required Session session,
  })  : _repo = repository,
        _members = members,
        _session = session {
    _repo.addListener(notifyListeners);
    _members.addListener(notifyListeners);
  }

  final FamilyRepository _repo;
  final MemberRepository _members;
  final Session _session;

  @override
  void dispose() {
    _repo.removeListener(notifyListeners);
    _members.removeListener(notifyListeners);
    super.dispose();
  }

  /// Keluarga yang sedang dipilih (null = belum memilih).
  String? get currentId => _session.familyId;
  Family? get current => _repo.byId(_session.familyId);

  bool get hasUser => _session.user != null;

  String get _userId => _session.user?.id ?? '';

  List<Family> get families => _repo.familiesOf(_userId);
  bool get hasFamilies => families.isNotEmpty;

  Future<List<Family>> loadFamilies() => _repo.loadFamilies(_userId);

  int memberCount(String familyId) => _members.countIn(familyId);

  void select(String familyId) => _session.selectFamily(familyId);

  SessionUser _requireUser() {
    final user = _session.user;
    if (user == null) throw const AppException('Sesi berakhir, silakan masuk lagi.');
    return user;
  }

  Future<Family> create({required String name}) async => _repo.create(name: name, user: _requireUser());

  Future<Family> join({required String code}) async => _repo.join(code: code, user: _requireUser());
}
