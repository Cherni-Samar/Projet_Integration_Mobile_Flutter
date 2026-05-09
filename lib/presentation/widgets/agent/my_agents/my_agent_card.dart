import 'package:e_team/presentation/providers/owned_agents_provider.dart';
import 'package:e_team/presentation/utils/domain_model_color_extensions.dart';
import 'package:e_team/presentation/widgets/agent/my_agents/my_agents_shared.dart';
import 'package:e_team/presentation/widgets/agent/my_agents/my_agents_theme.dart';
import 'package:flutter/material.dart';

class MyAgentCard extends StatelessWidget {
  const MyAgentCard({
    super.key,
    required this.agent,
    required this.isDark,
    required this.onTap,
    required this.onRename,
  });

  final OwnedAgent agent;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onRename;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: agent.agentColor.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: agent.agentColor.withValues(alpha: isDark ? 0.1 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Row(
          children: [
            AgentAvatar(agent: agent, size: 60, borderRadius: 16),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _AgentNameBlock(agent: agent, isDark: isDark),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_horiz,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        onSelected: (value) {
                          if (value == 'rename') onRename();
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'rename', child: Text('Rename')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: agent.agentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          agent.packTitle,
                          style: TextStyle(
                            color: agent.agentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.bolt, color: agent.agentColor, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        formatAgentEnergy(agent.energy),
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const ReadyBadge(),
          ],
        ),
      ),
    );
  }
}

class _AgentNameBlock extends StatelessWidget {
  const _AgentNameBlock({required this.agent, required this.isDark});

  final OwnedAgent agent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          agent.displayName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        if (agent.displayName != agent.agentName)
          Text(
            agent.agentName,
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}
