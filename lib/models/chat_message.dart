/// Data chatbot sesuai SRS: pesan pengguna, respons chatbot, waktu percakapan.
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  /// Opsional: daftar saran yang ditampilkan sebagai kartu di bawah balasan AI.
  final List<String>? suggestionCards;

  /// Opsional: teks tombol aksi di bawah kartu saran.
  final String? actionLabel;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.suggestionCards,
    this.actionLabel,
  });
}
