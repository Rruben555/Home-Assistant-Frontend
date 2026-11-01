import '../../../shared/role/role.dart';

class Member {
  const Member({
    required this.id,
    required this.familyId,
    required this.name,
    required this.email,
    required this.role,
    this.userId,
  });
  final String id;
  final String familyId; // relasi -> Family.id
  final String name;
  final String email;
  final Role role;
  final String? userId; // relasi -> AppUser.id (null = belum punya akun)

  /// Nama pengganti bila anggota yang ditugaskan sudah dihapus.
  static const removedName = 'Anggota dihapus';

  String get initial => name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  Member copyWith({String? id, String? familyId, String? name, String? email, Role? role, String? userId}) => Member(
        id: id ?? this.id,
        familyId: familyId ?? this.familyId,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        userId: userId ?? this.userId,
      );
}
