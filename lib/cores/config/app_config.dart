/// Konfigurasi aplikasi yang bukan rahasia.
class AppConfig {
  static const appName = 'House Chore Manager';

  /// Jeda buatan untuk repository in-memory agar state loading / error terlihat.
  static const simulatedDelay = Duration(milliseconds: 700);

  /// Layar lebar (768 / 1280 px): konten dibatasi 560 px dan diletakkan di tengah.
  static const maxContentWidth = 560.0;
}
