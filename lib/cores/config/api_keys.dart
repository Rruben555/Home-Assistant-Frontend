/// Kunci API. Jangan menaruh kunci asli di kode; isi lewat
/// `flutter run --dart-define=CHATBOT_API_KEY=...`.
class ApiKeys {
  static const chatbot = String.fromEnvironment('CHATBOT_API_KEY');
}
