import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../app/theme/app_theme.dart';
import '../../../../../cores/ui/run_action.dart';
import '../../controllers/chatbot_controller.dart';
import '../../widgets/chat_bubble.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key, required this.chatbot});
  final ChatbotController chatbot;
  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  ChatbotController get _chat => widget.chatbot;

  @override
  void initState() {
    super.initState();
    _chat.reset();
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollDown() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
        }
      });

  Future<void> _send([String? retryText]) async {
    final text = (retryText ?? _input.text).trim();
    if (text.isEmpty || _chat.sending) return;
    if (retryText == null) _input.clear();
    final running = runAction<void>(
      context,
      action: () => _chat.send(text, addUserMessage: retryText == null),
      onRetry: () => _send(text),
      catchUnexpected: false,
    );
    _scrollDown();
    await running;
    _scrollDown();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: _chat,
        builder: (context, _) => Column(children: [
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                const Center(child: Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text('Hari ini', style: AppText.muted),
                )),
                for (final m in _chat.messages) ChatBubble(message: m),
                if (_chat.sending)
                  const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Chore Assistant sedang mengetik...', style: AppText.muted),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _input,
              enabled: true,
              minLines: 1,
              maxLines: 4,
              inputFormatters: [LengthLimitingTextInputFormatter(200)],
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              style: AppText.body,
              decoration: InputDecoration(
                hintText: 'Tanya soal chore kamu...',
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(6),
                  child: IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                    tooltip: 'Kirim',
                    onPressed: _chat.sending ? null : _send,
                    icon: const Icon(Icons.arrow_upward, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ]),
      );
}
