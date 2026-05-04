import 'package:flutter/material.dart';

class AgentNameHeader extends StatelessWidget {
  final String agentName;
  final String version;
  final bool isDark;

  const AgentNameHeader({
    super.key,
    required this.agentName,
    required this.version,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Text(
            agentName,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            version,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
