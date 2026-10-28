import '../role/role.dart';

/// Aturan hak akses chore. Fungsi murni: tidak membaca repository atau session.
class ChorePolicy {
  const ChorePolicy._();

  /// Membuat, mengubah, dan menghapus chore.
  static bool canManage(Role? role) => role == Role.admin;

  /// Chore ditugaskan ke akun ini, dicek lewat email (bukan nama / id anggota).
  static bool isAssignedTo({String? userEmail, String? assigneeEmail}) {
    if (userEmail == null || assigneeEmail == null) return false;
    return _norm(assigneeEmail) == _norm(userEmail);
  }

  /// Admin boleh menandai selesai semua chore; anggota hanya miliknya sendiri.
  static bool canComplete({required Role? role, required bool isAssignee}) =>
      role == Role.admin || isAssignee;

  static String _norm(String s) => s.trim().toLowerCase();
}
