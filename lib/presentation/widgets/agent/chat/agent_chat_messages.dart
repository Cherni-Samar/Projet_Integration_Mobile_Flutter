import 'package:e_team/presentation/widgets/agent/chat/agent_chat_models.dart';
import 'package:e_team/presentation/widgets/agent/chat/agent_chat_theme.dart';
import 'package:flutter/material.dart';

class AgentChatMessages extends StatelessWidget {
  const AgentChatMessages({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.isDark,
    required this.accent,
    required this.textMain,
    required this.textSub,
  });

  final List<AgentChatMessage> messages;
  final ScrollController scrollController;
  final bool isDark;
  final Color accent;
  final Color textMain;
  final Color textSub;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'Start a conversation…',
          style: TextStyle(color: textSub, fontWeight: FontWeight.w600),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      itemCount: messages.length,
      itemBuilder: (_, index) {
        final message = messages[index];
        return AgentChatBubble(
          isDark: isDark,
          accent: accent,
          textMain: textMain,
          msg: message.text,
          fromUser: message.fromUser,
        );
      },
    );
  }
}

class AgentChatBubble extends StatelessWidget {
  const AgentChatBubble({
    super.key,
    required this.isDark,
    required this.accent,
    required this.textMain,
    required this.msg,
    required this.fromUser,
  });

  final bool isDark;
  final Color accent;
  final Color textMain;
  final String msg;
  final bool fromUser;

  @override
  Widget build(BuildContext context) {
    final bg = fromUser
        ? (isDark ? AgentChatTheme.volt : Colors.black)
        : (isDark
              ? const Color(0xFF1E1E1E)
              : Colors.white.withValues(alpha: 0.75));
    final fg = fromUser
        ? (isDark ? Colors.black : AgentChatTheme.volt)
        : textMain;

    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: fromUser
                ? Colors.transparent
                : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06)),
          ),
        ),
        child: Text(
          msg,
          style: TextStyle(
            color: fg,
            fontSize: 14,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
