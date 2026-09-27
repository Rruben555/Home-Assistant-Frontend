import 'package:flutter/material.dart';
import '../models/family_member.dart';
import '../repository/member_repository.dart';
import '../widgets/confirm_dialog.dart';

/// Hapus anggota keluarga dengan dialog konfirmasi + snackbar sukses
/// dengan aksi "Urungkan". Relasi ID pada aktivitas otomatis dilepas oleh
/// repository. Mengembalikan true bila jadi dihapus.
Future<bool> deleteMember(BuildContext context, FamilyMember member) async {
  final repo = MemberScope.of(context);
  final ok = await confirmDialog(
    context,
    title: 'Hapus anggota keluarga?',
    message:
        '"${member.name}" akan dihapus. Aktivitas yang ditugaskan ke ${member.name} '
        'akan menjadi belum ditugaskan.',
  );
  if (!ok || !context.mounted) return false;

  final messenger = ScaffoldMessenger.of(context);
  try {
    await repo.deleteMember(member.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('"${member.name}" berhasil dihapus.'),
        action: SnackBarAction(
          label: 'Urungkan',
          onPressed: () => repo.restore(member),
        ),
      ));
    return true;
  } catch (e) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content:
              Text('Gagal menghapus: ${e.toString().replaceFirst('Exception: ', '')}')));
    return false;
  }
}
