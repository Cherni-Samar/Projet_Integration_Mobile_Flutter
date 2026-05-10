import 'package:flutter/material.dart';

import 'package:e_team/presentation/providers/owned_agents_provider.dart';

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
