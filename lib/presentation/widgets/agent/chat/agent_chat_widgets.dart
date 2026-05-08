import 'package:e_team/presentation/providers/owned_agents_provider.dart';
import 'package:e_team/presentation/utils/domain_model_color_extensions.dart';
import 'package:e_team/presentation/widgets/agent/chat/agent_chat_models.dart';
import 'package:flutter/material.dart';

class AgentChatTheme {
  const AgentChatTheme._();

  static const volt = Color(0xFFCDFF00);
}

class AgentChatScaffoldBackground extends StatelessWidget {
  const AgentChatScaffoldBackground({
    super.key,
    required this.isDark,
    required this.child,
  });

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bgTop = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFEFFAF7);
    final bgBottom = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF2E9FF);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgTop, bgBottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}

class AgentChatHeader extends StatelessWidget {
  const AgentChatHeader({
    super.key,
    required this.agent,
    required this.isDark,
    required this.textMain,
    required this.textSub,
    required this.onBack,
  });

  final OwnedAgent agent;
  final bool isDark;
  final Color textMain;
  final Color textSub;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final accent = agent.agentColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      child: Row(
        children: [
          CircleGlassButton(
            isDark: isDark,
            icon: Icons.arrow_back,
            onTap: onBack,
          ),
          const SizedBox(width: 12),
          AgentChatAvatar(agent: agent, accent: accent, size: 36, radius: 12),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agent.displayName,
                  style: TextStyle(
                    color: textMain,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${agent.agentName.toLowerCase()}@e-team.com',
                  style: TextStyle(
                    color: textSub,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          CircleGlassButton(
            isDark: isDark,
            icon: Icons.volume_up_outlined,
            onTap: () {},
          ),
          const SizedBox(width: 10),
          CircleGlassButton(
            isDark: isDark,
            icon: Icons.more_horiz,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class AgentChatHeroCard extends StatelessWidget {
  const AgentChatHeroCard({
    super.key,
    required this.agent,
    required this.isDark,
    required this.glassColor,
    required this.textMain,
    required this.textSub,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  final OwnedAgent agent;
  final bool isDark;
  final Color glassColor;
  final Color textMain;
  final Color textSub;
  final List<AgentChatSuggestion> suggestions;
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final accent = agent.agentColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: GlassCard(
        color: glassColor,
        borderColor: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06),
        child: Column(
          children: [
            const SizedBox(height: 8),
            AgentChatHeroAvatar(agent: agent, accent: accent),
            const SizedBox(height: 14),
            Text(
              "Hi I’m ${agent.displayName}",
              style: TextStyle(
                color: textMain,
                fontWeight: FontWeight.w900,
                fontSize: 26,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Life’s short — do more, worry way less.",
              style: TextStyle(
                color: textSub,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: suggestions.map((suggestion) {
                return SuggestionPill(
                  isDark: isDark,
                  text: suggestion.label,
                  onTap: () => onSuggestionTap(suggestion.label),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

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

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.color,
    required this.borderColor,
    required this.child,
  });

  final Color color;
  final Color borderColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

class AgentChatAvatar extends StatelessWidget {
  const AgentChatAvatar({
    super.key,
    required this.agent,
    required this.accent,
    required this.size,
    required this.radius,
  });

  final OwnedAgent agent;
  final Color accent;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          agent.agentIllustration,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Icon(Icons.smart_toy, color: accent),
        ),
      ),
    );
  }
}

class AgentChatHeroAvatar extends StatelessWidget {
  const AgentChatHeroAvatar({
    super.key,
    required this.agent,
    required this.accent,
  });

  final OwnedAgent agent;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                accent.withValues(alpha: 0.25),
                accent.withValues(alpha: 0.10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: accent.withValues(alpha: 0.35), width: 3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Image.asset(
              agent.agentIllustration,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  Center(child: Icon(Icons.smart_toy, size: 60, color: accent)),
            ),
          ),
        ),
        Positioned(
          right: 6,
          top: 6,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: const Icon(Icons.help_outline, size: 18),
          ),
        ),
      ],
    );
  }
}

class CircleGlassButton extends StatelessWidget {
  const CircleGlassButton({
    super.key,
    required this.isDark,
    required this.icon,
    required this.onTap,
  });

  final bool isDark;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.65),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

class SuggestionPill extends StatelessWidget {
  const SuggestionPill({
    super.key,
    required this.isDark,
    required this.text,
    required this.onTap,
  });

  final bool isDark;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class ActionPill extends StatelessWidget {
  const ActionPill({
    super.key,
    required this.isDark,
    required this.accent,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool isDark;
  final Color accent;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: accent),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SquareGlassButton extends StatelessWidget {
  const SquareGlassButton({
    super.key,
    required this.isDark,
    required this.icon,
    required this.onTap,
  });

  final bool isDark;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Icon(icon, color: isDark ? Colors.white : Colors.black),
      ),
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
