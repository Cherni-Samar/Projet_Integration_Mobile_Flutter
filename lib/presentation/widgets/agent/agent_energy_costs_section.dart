import 'package:flutter/material.dart';
import 'agent_energy_cost_item.dart';

class AgentEnergyCostsSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> energyCosts;
  final Color agentColor;
  final bool isDark;

  const AgentEnergyCostsSection({
    super.key,
    required this.title,
    required this.energyCosts,
    required this.agentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: energyCosts.asMap().entries.map((entry) {
              final i = entry.key;
              final task = entry.value;
              return AgentEnergyCostItem(
                task: task,
                color: agentColor,
                isDark: isDark,
                isLast: i == energyCosts.length - 1,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
