import 'package:flutter/foundation.dart';
import '../../../shared/role/role.dart';
import '../../../shared/session/session.dart';
import 'member.dart';
import 'member_lookup.dart';

/// Jumlah chore yang belum selesai milik anggota. Disediakan DI oleh fitur chores
/// agar members tidak mengimpor chores.
typedef PendingChoreCount = int Function(String memberId);

/// Kontrak data anggota. Implementasi sekarang in-memory; nanti Firebase.
abstract interface class MemberRepository implements Listenable, MemberLookup {
  /// Anggota milik keluarga yang sedang dipilih.
  List<Member> get snapshot;

  Future<List<Member>> loadMembers();

  Future<Member> loadMember(String id);

  Future<Member> create(Member draft);

  Future<Member> update(Member member);

  Future<void> delete(String id);

  /// Admin mengubah peran anggota: [admin] true = Admin, false = Anggota.
  Future<Member> setAdmin(String id, {required bool admin});

  /// Samakan nama anggota di semua keluarga setelah pengguna mengubah namanya di profil.
  void syncUserName(String userId, String name);

  /// Dipakai saat pengguna bergabung lewat kode (tanpa latensi). Bila email pengguna sudah
  /// tercatat sebagai anggota yang belum punya akun, data itu dihubungkan ke akun ini.
  Member joinAsMember({required String familyId, required SessionUser user});

  /// Dipakai saat pengguna membuat keluarga (tanpa latensi).
  Member addForUser({required String familyId, required SessionUser user, Role role = Role.admin});
}
