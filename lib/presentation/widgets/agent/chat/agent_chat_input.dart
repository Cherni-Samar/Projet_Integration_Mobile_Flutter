import 'package:e_team/presentation/widgets/agent/chat/agent_chat_models.dart';
import 'package:e_team/presentation/widgets/agent/chat/agent_chat_shared.dart';
import 'package:e_team/presentation/widgets/agent/chat/agent_chat_theme.dart';
import 'package:flutter/material.dart';

class AgentChatBottomBar extends StatelessWidget {
  const AgentChatBottomBar({
    super.key,
    required this.actions,
    required this.controller,
    required this.isDark,
    required this.accent,
    required this.glassColor,
    required this.textMain,
    required this.onActionTap,
    required this.onSend,
  });

  final List<AgentChatQuickAction> actions;
  final TextEditingController controller;
  final bool isDark;
  final Color accent;
  final Color glassColor;
  final Color textMain;
  final ValueChanged<String> onActionTap;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 10,
        bottom: 10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: glassColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: actions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, index) {
                final action = actions[index];
                return ActionPill(
                  isDark: isDark,
                  accent: accent,
                  icon: action.icon,
                  label: action.label,
                  onTap: () => onActionTap(action.label),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SquareGlassButton(isDark: isDark, icon: Icons.add, onTap: () {}),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: TextStyle(
                    color: textMain,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Message…',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1E1E1E)
                        : Colors.white.withValues(alpha: 0.65),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: onSend,
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => onSend(controller.text),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [AgentChatTheme.volt, const Color(0xFFAADD00)]
                          : [
                              accent.withValues(alpha: 0.25),
                              accent.withValues(alpha: 0.12),
                            ],
                    ),
                    color: isDark ? null : Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? Colors.transparent
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Icon(
                    Icons.mic_none_rounded,
                    color: isDark ? Colors.black : accent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
