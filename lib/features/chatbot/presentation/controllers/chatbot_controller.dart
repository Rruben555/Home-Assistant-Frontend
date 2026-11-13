import 'package:flutter/foundation.dart';
import '../../../../shared/session/session.dart';
import '../../domain/chat_message.dart';
import '../../domain/chatbot_repository.dart';

/// Riwayat percakapan dan status "sedang mengetik".
class ChatbotController extends ChangeNotifier {
  ChatbotController({required ChatbotRepository repository, required Session session})
      : _repo = repository,
        _session = session;

  final ChatbotRepository _repo;
  final Session _session;
  final List<ChatMessage> _messages = [];
  bool _sending = false;

  List<ChatMessage> get messages => List<ChatMessage>.unmodifiable(_messages);
  bool get sending => _sending;

  /// Mulai percakapan baru dengan sapaan. Dipanggil layar sebelum build pertamanya
  /// (tanpa notifikasi), sehingga riwayat tidak terbawa antar-sesi.
  void reset() {
    final name = _session.user?.name ?? 'kamu';
    _messages
      ..clear()
      ..add(ChatMessage('Hai, $name! Butuh bantuan soal chore? Tanya apa saja.', fromUser: false));
    _sending = false;
  }

  /// Kirim [text]. [addUserMessage] false dipakai saat mencoba lagi (pesan sudah ada).
  Future<void> send(String text, {bool addUserMessage = true}) async {
    if (_sending) return;
    if (addUserMessage) _messages.add(ChatMessage(text, fromUser: true));
    _sending = true;
    notifyListeners();
    try {
      final reply = await _repo.reply(text);
      _messages.add(ChatMessage(reply, fromUser: false));
    } finally {
      _sending = false;
      notifyListeners();
    }
  }
}
