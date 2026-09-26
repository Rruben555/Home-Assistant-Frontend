import 'package:flutter/material.dart';
import '../models/task.dart';
import '../repository/task_repository.dart';
import '../widgets/confirm_dialog.dart';

/// Tandai selesai (FR-05) + snackbar sukses dengan aksi "Urungkan".
void completeTask(BuildContext context, HouseholdTask task) {
  final repo = TaskScope.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final entryId = repo.complete(task.id);
  if (entryId == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text('"${task.title}" selesai dan masuk riwayat.'),
      action: SnackBarAction(
        label: 'Urungkan',
        onPressed: () => repo.undoComplete(entryId),
      ),
    ));
}

/// Hapus aktivitas dengan dialog konfirmasi (FR-06) + snackbar sukses
/// dengan aksi "Urungkan". Mengembalikan true bila jadi dihapus.
Future<bool> deleteTask(BuildContext context, HouseholdTask task) async {
  final repo = TaskScope.of(context);
  final ok = await confirmDialog(
    context,
    title: 'Hapus aktivitas?',
    message: '"${task.title}" akan dihapus dari daftar aktivitas.',
  );
  if (!ok || !context.mounted) return false;

  final messenger = ScaffoldMessenger.of(context);
  try {
    await repo.deleteTask(task.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: const Text('Aktivitas berhasil dihapus.'),
        action: SnackBarAction(
          label: 'Urungkan',
          onPressed: () => repo.restore(task),
        ),
      ));
    return true;
  } catch (e) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Gagal menghapus: ${_msg(e)}')));
    return false;
  }
}

String _msg(Object e) => e.toString().replaceFirst('Exception: ', '');
