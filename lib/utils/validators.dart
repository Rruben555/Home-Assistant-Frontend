/// Validator form autentikasi. Mengembalikan pesan galat, atau null bila valid.
class AuthValidators {
  static final _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  static String? name(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Nama wajib diisi';
    if (s.length < 2) return 'Nama minimal 2 karakter';
    if (s.length > 40) return 'Nama maksimal 40 karakter';
    return null;
  }

  static String? email(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Email wajib diisi';
    if (!_emailRe.hasMatch(s)) return 'Format email tidak valid';
    return null;
  }

  /// Untuk login cukup memastikan tidak kosong.
  static String? passwordRequired(String? v) =>
      (v ?? '').isEmpty ? 'Kata sandi wajib diisi' : null;

  /// Untuk pendaftaran: minimal 8 karakter, mengandung huruf dan angka.
  static String? newPassword(String? v) {
    final s = v ?? '';
    if (s.isEmpty) return 'Kata sandi wajib diisi';
    if (s.length < 8) return 'Kata sandi minimal 8 karakter';
    if (!RegExp(r'[A-Za-z]').hasMatch(s) || !RegExp(r'\d').hasMatch(s)) {
      return 'Gunakan kombinasi huruf dan angka';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() original) {
    return (v) {
      if ((v ?? '').isEmpty) return 'Konfirmasi kata sandi wajib diisi';
      if (v != original()) return 'Kata sandi tidak sama';
      return null;
    };
  }
}
