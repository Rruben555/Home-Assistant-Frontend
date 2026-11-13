import '../../../cores/utils/simulation.dart';
import '../../chores/chores.dart';
import '../domain/chatbot_repository.dart';

class RuleBasedChatbotRepository implements ChatbotRepository {
  RuleBasedChatbotRepository({required ChoreRepository chores}) : _chores = chores;
  final ChoreRepository _chores;

  @override
  Future<String> reply(String message) async {
    await simulateLatency(const Duration(milliseconds: 900));
    final q = message.toLowerCase();
    final pending = _chores.pendingCount;

    if (q.contains('mudah') || q.contains('malas') || q.contains('semangat') || q.contains('ringan')) {
      return 'Mulai dari yang kecil! Pilih satu ruangan, setel timer 10 menit, dan fokus pada satu tugas '
          'dalam satu waktu. Kemajuan sekecil apa pun tetap berarti.';
    }
    if (q.contains('jadwal') || q.contains('hari ini') || q.contains('chore')) {
      return pending == 0
          ? 'Semua chore sudah selesai. Kerja bagus!'
          : 'Saat ini ada $pending chore yang belum selesai. Mulai dari yang jadwalnya paling dekat ya.';
    }
    if (q.contains('piring') || q.contains('dapur')) {
      return 'Rendam piring berminyak 5 menit dulu, lalu cuci dari gelas, piring, hingga wajan.';
    }
    if (q.contains('kamar mandi')) {
      return 'Semprot pembersih, diamkan 5 menit, baru sikat dari atas ke bawah supaya lebih cepat.';
    }
    if (q.contains('halo') || q.contains('hai')) return 'Halo! Ada yang bisa kubantu soal chore hari ini?';
    return 'Aku belum paham pertanyaan itu. Coba tanya soal jadwal chore, tips membersihkan dapur, '
        'atau cara membuat bersih-bersih terasa lebih mudah.';
  }
}
