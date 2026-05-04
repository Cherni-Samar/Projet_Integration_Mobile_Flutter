import 'package:flutter/material.dart';

class AgentHireFab extends StatelessWidget {
  final bool isDark;
  final String agentName;
  final bool isActive;
  final VoidCallback onPressed;

  const AgentHireFab({
    super.key,
    required this.isDark,
    required this.agentName,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isHera = agentName.trim().toLowerCase() == 'hera';
    final canOpenDashboard = isHera && isActive;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFFCDFF00) : Colors.black,
            foregroundColor: isDark ? Colors.black : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            shadowColor: Colors.black.withValues(alpha: 0.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                canOpenDashboard
                    ? Icons.dashboard_outlined
                    : (isHera ? Icons.rocket_launch : Icons.bolt),
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                canOpenDashboard
                    ? 'Ouvrir le Dashboard'
                    : (isHera ? 'Hire Hera' : 'Buy Energy'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
