import 'member.dart';

/// Pencarian anggota yang hanya membaca. Dipakai fitur lain (chores, family)
/// supaya tidak bergantung pada seluruh [MemberRepository].
abstract interface class MemberLookup {
  Member? byId(String id);

  /// Nama anggota, atau [Member.removedName] bila sudah dihapus.
  String nameOf(String id);

  bool isMember(String familyId, String userId);

  int countIn(String familyId);

  int adminCountIn(String familyId);

  /// Anggota milik [userId] pada keluarga [familyId].
  Member? memberOfUser(String familyId, String userId);
}
