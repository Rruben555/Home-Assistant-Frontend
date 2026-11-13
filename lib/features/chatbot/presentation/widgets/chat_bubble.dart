import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/chat_message.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final m = message;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: m.fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!m.fromUser)
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text('Chore Assistant',
                  style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 14)),
            ),
          Container(
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: m.fromUser ? AppColors.primary : Colors.white,
              borderRadius: AppRadius.lgR,
            ),
            child: Text(m.text, style: AppText.body.copyWith(color: m.fromUser ? Colors.white : AppColors.textDark)),
          ),
        ],
      ),
    );
  }
}
