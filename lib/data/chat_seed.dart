import '../config/app_config.dart';
import '../models/chat_message.dart';

/// Data simulasi untuk layar AI Asisten (FR-09, FR-10). Tidak ada
/// pemanggilan API sungguhan — satu balasan tetap dipakai untuk demo.
class ChatSeed {
  static List<ChatMessage> initial() => [
        ChatMessage(
          text:
              'Halo Bu Sarah! Saya Asisten AI Home Assistant. Butuh saran jadwal '
              'kebersihan, tips merawat peralatan rumah, atau solusi noda '
              'membandel? Tanyakan apa saja!',
          isUser: false,
          time: DateTime.now(),
        ),
      ];

  static const quickSuggestions = [
    'Rekomendasi jadwal mingguan',
    'Cara bersihkan noda kusam',
    'Tips hemat energi rumah',
  ];

  // Contoh isi kartu saran. Hanya dipakai bila
  // `AppConfig.enableAiSuggestionCards` true (butuh AI sungguhan).
  static const suggestionCards = [
    '🧹 Kamar Mandi — Sikat lantai, dinding, dan bersihkan kloset agar bebas kerak & jamur.',
    '🛏️ Kamar Tidur — Ganti sprei, sarung bantal, dan jemur bantal di bawah terik matahari.',
    '🍳 Dapur — Lap tumpukan minyak di kompor dan bersihkan saringan wastafel cuci piring.',
    '🧺 Pakaian & Tekstil — Cuci tirai tipis atau keset kaki rumah tangga.',
  ];

  static ChatMessage defaultAiReply() {
    return ChatMessage(
      text: 'Terima kasih atas pertanyaannya! Ini balasan demo — fitur AI '
          'sungguhan belum tersambung.',
      isUser: false,
      time: DateTime.now(),
      suggestionCards: AppConfig.enableAiSuggestionCards ? suggestionCards : null,
      actionLabel: AppConfig.enableAiSuggestionCards ? 'Tambahkan ke Jadwal Saya' : null,
    );
  }
}