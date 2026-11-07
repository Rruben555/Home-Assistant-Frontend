import 'dart:math';
import '../../../cores/utils/validators.dart';

/// Aturan kode undangan keluarga: panjang, karakter, normalisasi, pembuatan, dan validasi.
class FamilyCode {
  const FamilyCode._();

  static const length = 6;

  /// Tanpa karakter yang mudah tertukar (0/O, 1/I/L).
  static const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

  /// Huruf besar, tanpa spasi / tanda hubung.
  static String normalize(String code) => code.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');

  /// Buat kode acak yang belum dipakai ([isTaken] false).
  static String generate(Random random, {required bool Function(String code) isTaken}) {
    while (true) {
      final code = String.fromCharCodes([
        for (var i = 0; i < length; i++) chars.codeUnitAt(random.nextInt(chars.length)),
      ]);
      if (!isTaken(code)) return code;
    }
  }

  static String? validate(String? v) {
    final e = Validators.required(v, 'Kode keluarga');
    if (e != null) return e;
    final c = normalize(v!);
    if (c.length != length || !RegExp(r'^[A-Z0-9]+$').hasMatch(c)) {
      return 'Kode keluarga terdiri dari $length huruf/angka';
    }
    return null;
  }
}
