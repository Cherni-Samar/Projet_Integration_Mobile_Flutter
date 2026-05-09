import 'package:e_team/presentation/providers/owned_agents_provider.dart';
import 'package:e_team/presentation/utils/domain_model_color_extensions.dart';
import 'package:flutter/material.dart';

class AgentAvatar extends StatelessWidget {
  const AgentAvatar({
    super.key,
    required this.agent,
    required this.size,
    required this.borderRadius,
  });

  final OwnedAgent agent;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: agent.agentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          agent.agentIllustration,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              Icon(Icons.smart_toy, color: agent.agentColor, size: size / 2),
        ),
      ),
    );
  }
}

class ReadyBadge extends StatelessWidget {
  const ReadyBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Ready',
        style: TextStyle(
          color: Color(0xFF10B981),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
