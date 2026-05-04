import 'package:flutter/material.dart';
import 'agent_skill_chip.dart';

class AgentSkillsSection extends StatelessWidget {
  final String title;
  final List<String> skills;
  final bool isDark;

  const AgentSkillsSection({
    super.key,
    required this.title,
    required this.skills,
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
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: skills
              .map((skill) => AgentSkillChip(label: skill, isDark: isDark))
              .toList(),
        ),
      ],
    );
  }
}
