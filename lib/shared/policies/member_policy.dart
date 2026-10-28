import '../role/role.dart';

/// Aturan hak akses anggota. Fungsi murni: tidak membaca repository atau session.
class MemberPolicy {
  const MemberPolicy._();

  /// Menambah, mengubah, menghapus anggota, dan mengganti peran.
  static bool canManage(Role? role) => role == Role.admin;

  /// Admin terakhir tidak boleh diturunkan menjadi anggota biasa.
  static bool canChangeRole({required Role current, required Role next, required int adminCount}) =>
      !(current == Role.admin && next != Role.admin && adminCount <= 1);

  /// Admin terakhir tidak boleh dihapus.
  static bool canDelete({required Role target, required int adminCount}) =>
      !(target == Role.admin && adminCount <= 1);
}
