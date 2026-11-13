/// Kontrak penjawab chatbot. Implementasi sekarang berbasis aturan; nanti bisa layanan AI.
abstract interface class ChatbotRepository {
  Future<String> reply(String message);
}
