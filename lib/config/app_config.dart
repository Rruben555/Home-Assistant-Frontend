import 'package:flutter/foundation.dart' show kDebugMode;

/// Saklar fitur khusus pengembangan/demo. Kodenya tetap ada dan aktif di
/// proyek; yang diatur di sini hanya apakah bagiannya TAMPIL / BERJALAN.
class AppConfig {
  const AppConfig._();

  /// Tombol "Isi akun demo" di halaman Masuk. Bawaan: hanya tampil pada
  /// build debug, otomatis hilang di build release. Ubah ke `true` bila
  /// versi demo/rilis memang perlu menampilkannya.
  static const bool showDemoLogin = kDebugMode;

  /// Kartu saran + tombol "Tambahkan ke Jadwal" pada balasan AI. Butuh AI
  /// sungguhan untuk menghasilkan saran, jadi bawaannya nonaktif.
  static const bool enableAiSuggestionCards = false;
}
