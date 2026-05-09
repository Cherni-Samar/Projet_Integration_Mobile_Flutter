import 'package:e_team/presentation/providers/owned_agents_provider.dart';
import 'package:e_team/presentation/utils/domain_model_color_extensions.dart';
import 'package:e_team/presentation/widgets/agent/chat/agent_chat_models.dart';
import 'package:e_team/presentation/widgets/agent/chat/agent_chat_shared.dart';
import 'package:flutter/material.dart';

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
