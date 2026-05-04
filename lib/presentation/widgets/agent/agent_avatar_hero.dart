import 'package:flutter/material.dart';
import 'package:e_team/core/painters/pulsating_ring_painter.dart';

class AgentAvatarHero extends StatelessWidget {
  final String agentIcon;
  final Color agentColor;
  final AnimationController pulseController;
  final double avatarDx;

  const AgentAvatarHero({
    super.key,
    required this.agentIcon,
    required this.agentColor,
    required this.pulseController,
    this.avatarDx = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.translate(
        offset: Offset(avatarDx, 0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: pulseController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(180, 180),
                  painter: PulsatingRingPainter(
                    progress: pulseController.value,
                    color: agentColor,
                  ),
                );
              },
            ),
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    agentColor.withValues(alpha: 0.2),
                    agentColor.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: agentColor,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: agentColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(70),
                child: Image.asset(
                  agentIcon,
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFCDFF00),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFCDFF00).withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
