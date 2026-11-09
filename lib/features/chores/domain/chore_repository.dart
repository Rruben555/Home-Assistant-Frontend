import 'package:flutter/foundation.dart';
import 'chore.dart';

/// Kontrak data chore. Implementasi sekarang in-memory; nanti Firebase.
abstract interface class ChoreRepository implements Listenable {
  /// Chore belum selesai pada keluarga yang sedang dipilih.
  int get pendingCount;

  /// Chore belum selesai milik satu anggota (semua keluarga).
  int pendingCountFor(String memberId);

  Future<List<Chore>> loadChores();

  Future<Chore> loadChore(String id);

  Future<Chore> create(Chore draft);

  Future<Chore> update(Chore chore);

  Future<void> complete(String id);

  Future<void> delete(String id);
}
