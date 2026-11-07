import 'package:flutter/foundation.dart';
import '../../../shared/session/session.dart';
import 'family.dart';

/// Kontrak data keluarga. Implementasi sekarang in-memory; nanti Firebase.
/// Keluarga yang sedang dipilih disimpan di [Session], bukan di sini.
abstract interface class FamilyRepository implements Listenable {
  Family? byId(String? id);

  Family? byCode(String code);

  /// Keluarga yang diikuti [userId].
  List<Family> familiesOf(String userId);

  Future<List<Family>> loadFamilies(String userId);

  /// Buat keluarga baru; [user] menjadi Admin pertamanya.
  Future<Family> create({required String name, required SessionUser user});

  /// Bergabung lewat kode undangan. Peran awal: Anggota.
  Future<Family> join({required String code, required SessionUser user});
}
