import 'package:flutter/material.dart';

class AgentSkillChip extends StatelessWidget {
  final String label;
  final bool isDark;

  const AgentSkillChip({
    Key? key,
    required this.label,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA855F7), width: 1.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFA855F7),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}