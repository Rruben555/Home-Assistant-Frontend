import 'package:flutter/foundation.dart';
import '../role/role.dart';

/// Identitas akun yang sedang masuk (tanpa password).
class SessionUser {
  const SessionUser({required this.id, required this.name, required this.email});
  final String id;
  final String name;
  final String email;

  SessionUser copyWith({String? name}) => SessionUser(id: id, name: name ?? this.name, email: email);
}

/// Anggota milik akun yang sedang masuk pada keluarga terpilih.
class SessionMember {
  const SessionMember({required this.id, required this.role});
  final String id;
  final Role role;
}

/// Mencari anggota milik [userId] pada keluarga [familyId]. Diikat oleh DI
/// agar `shared/` tidak perlu mengenal fitur members.
typedef SessionMemberResolver = SessionMember? Function(String userId, String familyId);

/// Status sesi: akun yang masuk, keluarga terpilih, dan anggota saat ini.
/// Anggota saat ini selalu dihitung ulang, jadi perubahan peran langsung terbaca.
class Session extends ChangeNotifier {
  SessionUser? _user;
  String? _familyId;
  SessionMemberResolver? _resolveMember;

  SessionUser? get user => _user;
  bool get isLoggedIn => _user != null;

  /// Keluarga yang sedang dipilih (null = belum memilih).
  String? get familyId => _familyId;

  /// Anggota milik akun ini pada keluarga terpilih.
  SessionMember? get member {
    final u = _user;
    final f = _familyId;
    if (u == null || f == null) return null;
    return _resolveMember?.call(u.id, f);
  }

  Role? get role => member?.role;
  bool get isAdmin => role == Role.admin;

  void bindMemberResolver(SessionMemberResolver resolver) => _resolveMember = resolver;

  void signIn(SessionUser user) {
    _user = user;
    notifyListeners();
  }

  void updateUser(SessionUser user) {
    _user = user;
    notifyListeners();
  }

  void selectFamily(String id) {
    _familyId = id;
    notifyListeners();
  }

  /// Keluar: akun dan keluarga terpilih dikosongkan.
  void signOut() {
    _user = null;
    _familyId = null;
    notifyListeners();
  }
}
