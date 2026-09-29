import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/chat_seed.dart';
import '../models/chat_message.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/responsive.dart';
import '../widgets/icon_tile.dart';

/// Layar AI Asisten (FR-09, FR-10) — chat berbahasa natural, balasan demo
/// (tidak ada pemanggilan API sungguhan sesuai batasan tugas ini).
class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final List<ChatMessage> _messages = List.of(ChatSeed.initial());
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  void _send([String? text]) {
    final content = (text ?? _inputController.text).trim();
    // Cegah kirim ganda: abaikan bila kosong atau balasan AI sedang diketik.
    if (content.isEmpty || _isTyping) return;
    setState(() {
      _messages.add(ChatMessage(text: content, isUser: true, time: DateTime.now()));
      _inputController.clear();
      _isTyping = true;
    });
    _scrollToEnd();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatSeed.defaultAiReply());
        _isTyping = false;
      });
      _scrollToEnd();
    });
  }

  void _scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Home Assistant',
                style: TextStyle(fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
            Text('AI Asisten', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              // Saat ruang vertikal sempit (HP landscape / keyboard terbuka)
              // sembunyikan kartu info & saran cepat agar area chat lega.
              final showExtras = constraints.maxHeight >= 420;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _chatMaxWidth),
                  child: Column(
                    children: [
                      if (showExtras) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _agentCard(),
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('SARAN CEPAT',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _quickSuggestions(),
                        const SizedBox(height: 6),
                      ],
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          itemCount: _messages.length,
                          itemBuilder: (context, i) => _Bubble(message: _messages[i]),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          _InputBar(controller: _inputController, onSend: () => _send(), enabled: !_isTyping),
        ],
      ),
    );
  }

  Widget _agentCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          const IconTile(Icons.smart_toy_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: const [
                  Text('Asisten Cerdas', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  SizedBox(width: 6),
                  Pill(text: 'Demo', background: AppColors.primaryLight, foreground: AppColors.primaryDark),
                ]),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.circle, size: 8, color: _isTyping ? AppColors.priorityMedium : Colors.green),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(_isTyping ? 'Sedang mengetik...' : 'Online • Siap Membantu',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickSuggestions() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: ChatSeed.quickSuggestions
            .map((s) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: OutlinedButton(
                    onPressed: () => _send(s),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.card,
                      shape: const StadiumBorder(),
                      side: const BorderSide(color: AppColors.divider)),
                    child: Text(s, style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

/// Lebar maksimum kolom chat di layar lebar (tablet/desktop).
const double _chatMaxWidth = 800;

class _Bubble extends StatelessWidget {
  final ChatMessage message;

  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
            maxWidth: math.min(MediaQuery.sizeOf(context).width * 0.78, 560),
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primaryDark : AppColors.card,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                border: isUser ? null : Border.all(color: AppColors.divider),
                boxShadow: const [
                  BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(color: isUser ? Colors.white : AppColors.textDark, fontSize: 13.5, height: 1.4),
                  ),
                  // Kartu saran: tampil hanya bila balasan membawa `suggestionCards`
                  // (lihat `AppConfig.enableAiSuggestionCards`).
                  if (message.suggestionCards != null) ...[
                    const SizedBox(height: 10),
                    ...message.suggestionCards!.map(
                      (s) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(s, style: const TextStyle(fontSize: 12.5, color: AppColors.textDark, height: 1.35)),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text('Mau saya langsung tambahkan aktivitas ini ke jadwal tugas Anda?',
                        style: TextStyle(fontSize: 12.5, color: AppColors.textDark)),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Aktivitas ditambahkan ke jadwal (demo).')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                        label: Text(message.actionLabel ?? 'Tambahkan',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(formatClock(message.time), style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                  if (isUser) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.done_all, size: 13, color: AppColors.primary),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;

  const _InputBar({required this.controller, required this.onSend, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SafeArea(
        top: false,
        child: MaxWidthBox(
          maxWidth: _chatMaxWidth - 32,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.divider),
                    boxShadow: const [
                      BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
                    ],
                  ),
                  child: TextField(
                    controller: controller,
                    enabled: enabled,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    decoration: const InputDecoration(
                      hintText: 'Tanyakan sesuatu tentang rumah tangga...',
                      hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: enabled ? AppColors.primaryDark : AppColors.divider,
                child: IconButton(
                  icon: Icon(Icons.send_rounded, color: enabled ? Colors.white : AppColors.textMuted, size: 18),
                  onPressed: enabled ? onSend : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
