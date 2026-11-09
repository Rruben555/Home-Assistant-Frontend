import '../domain/chore.dart';

/// Data simulasi: 27 chore (24 di keluarga f1, 3 di f2).
/// PENTING: list yang dikembalikan harus growable (JANGAN pakai `const [...]`),
/// karena repository menambah / mengubah isinya.
class ChoreSeed {
  // (nama, anggota, offset hari, jam, selesai?)
  static List<Chore> chores() {
    final now = DateTime.now();
    final specs = <(String, String, int, int, bool)>[
      ('Cuci piring', 'm1', 0, 18, false),
      ('Sapu ruang tamu', 'm2', 0, 16, false),
      ('Siram tanaman', 'm3', 0, 7, true),
      ('Bersihkan kamar mandi', 'm4', 0, 19, false),
      ('Ganti sprei', 'm1', 1, 9, false),
      ('Pel lantai dapur', 'm2', 1, 17, false),
      ('Buang sampah', 'm3', 1, 20, false),
      ('Pangkas rumput', 'm5', 2, 8, false),
      ('Sikat lantai kamar mandi', 'm6', 2, 15, false),
      ('Rapikan rak buku', 'm1', 3, 10, false),
      ('Cuci gorden', 'm4', 4, 11, false),
      ('Bersihkan kulkas', 'm5', 5, 14, false),
      ('Rapikan lemari', 'm2', 6, 13, false),
      ('Bersihkan kaca jendela', 'm6', 7, 9, false),
      ('Cuci piring', 'm1', -1, 18, true),
      ('Buang sampah', 'm2', -1, 20, true),
      ('Sapu halaman', 'm3', -2, 8, true),
      ('Cuci wastafel', 'm4', -2, 19, true),
      ('Ganti sprei', 'm1', -3, 9, true),
      ('Lap debu ruang tamu', 'm5', -4, 16, true),
      ('Pel lantai kamar', 'm6', -5, 10, true),
      ('Siram tanaman', 'm1', -6, 7, true),
      ('Cuci piring', 'm3', -7, 18, true),
      ('Bersihkan kompor', 'm2', -8, 17, true),
      // Keluarga f2
      ('Sapu lorong kos', 'm7', 0, 17, false),
      ('Buang sampah', 'm8', 1, 19, false),
      ('Cuci dapur bersama', 'm7', -1, 20, true),
    ];

    final result = <Chore>[];
    for (var i = 0; i < specs.length; i++) {
      final s = specs[i];
      final at = DateTime(now.year, now.month, now.day + s.$3, s.$4);
      result.add(Chore(
        id: 'c${i + 1}',
        familyId: i >= 24 ? 'f2' : 'f1',
        name: s.$1,
        assigneeId: s.$2,
        instructions: i == 0
            ? 'Cuci piring, gelas, dan peralatan makan.'
            : 'Kerjakan "${s.$1.toLowerCase()}" sampai bersih lalu rapikan peralatan.',
        scheduledAt: at,
        isCompleted: s.$5,
        completedAt: s.$5 ? at.add(const Duration(minutes: 30)) : null,
      ));
    }
    return result;
  }
}
