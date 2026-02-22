import 'package:flutter/material.dart';

class HrDashboardPage extends StatelessWidget {
  final String heraMessage; // ← reçoit le "Hello World" de Hera

  const HrDashboardPage({Key? key, required this.heraMessage})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Row(
          children: [
            Text('👥', style: TextStyle(fontSize: 22)),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hera',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'HR Agent • Online',
                  style: TextStyle(color: Color(0xFFCDFF00), fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🤖 Avatar Hera
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.5),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('👥', style: TextStyle(fontSize: 48)),
                ),
              ),

              const SizedBox(height: 32),

              // 💬 Message de Hera
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      '🤖 Hera dit :',
                      style: TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      heraMessage, // ← "Hello World!" vient du BackEnd
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 📋 Tasks à venir (disabled pour l'instant)
              const Text(
                'TASKS À VENIR',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildTaskButton('🏖️', 'Demander un congé', disabled: true),
              const SizedBox(height: 12),
              _buildTaskButton('👤', 'Onboarding employé', disabled: true),
              const SizedBox(height: 12),
              _buildTaskButton('📊', 'Voir les absences', disabled: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskButton(String icon, String label, {bool disabled = false}) {
    return Opacity(
      opacity: disabled ? 0.35 : 1.0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (disabled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Soon',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
