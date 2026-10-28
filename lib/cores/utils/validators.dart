import '../constants/app_constants.dart';

class Validators {
  static String? required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null;

  static String? text(String? v, String label, {int min = 2, int max = AppConst.maxNameLength}) {
    final e = required(v, label);
    if (e != null) return e;
    final len = v!.trim().length;
    if (len < min) return '$label minimal $min karakter';
    if (len > max) return '$label maksimal $max karakter (sekarang $len)';
    return null;
  }

  /// Opsional: boleh kosong, tapi bila diisi maksimal [AppConst.maxInstructionLength] karakter.
  static String? instructions(String? v) {
    final len = v?.trim().length ?? 0;
    if (len > AppConst.maxInstructionLength) {
      return 'Instruksi maksimal ${AppConst.maxInstructionLength} karakter (sekarang $len)';
    }
    return null;
  }

  static String? email(String? v) {
    final e = required(v, 'Email');
    if (e != null) return e;
    final t = v!.trim();
    if (t.length > AppConst.maxEmailLength) return 'Email maksimal ${AppConst.maxEmailLength} karakter';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
      return 'Format email tidak valid, contoh: nama@example.com';
    }
    return null;
  }

  static String? password(String? v, {String label = 'Password'}) {
    final e = required(v, label);
    if (e != null) return e;
    if (v!.length < AppConst.minPasswordLength) {
      return '$label minimal ${AppConst.minPasswordLength} karakter (sekarang ${v.length})';
    }
    return null;
  }

  static String? confirmPassword(String? v, String original) {
    final e = required(v, 'Konfirmasi password');
    if (e != null) return e;
    return v == original ? null : 'Konfirmasi password tidak sama dengan password baru';
  }

  static String? selection(Object? v, String message) => v == null ? message : null;
}
