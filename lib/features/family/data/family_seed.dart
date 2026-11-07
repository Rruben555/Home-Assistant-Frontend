import '../domain/family.dart';

/// Data simulasi (kode keluarga: f1 = VEN482, f2 = MLT735).
/// PENTING: list yang dikembalikan harus growable (JANGAN pakai `const [...]`),
/// karena repository menambah isinya saat buat keluarga.
class FamilySeed {
  static List<Family> families() => [
        Family(id: 'f1', name: 'Keluarga Ven', code: 'VEN482'),
        Family(id: 'f2', name: 'Rumah Kos Melati', code: 'MLT735'),
      ];
}
