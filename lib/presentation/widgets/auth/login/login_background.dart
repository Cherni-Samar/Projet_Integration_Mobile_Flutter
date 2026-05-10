import 'package:flutter/material.dart';

import 'package:e_team/presentation/widgets/auth/login/login_painter.dart';

class LoginGlowBackground extends StatelessWidget {
  const LoginGlowBackground({
    super.key,
    required this.glowController,
    required this.isDark,
  });

  final AnimationController glowController;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -100,
      right: -100,
      child: AnimatedBuilder(
        animation: glowController,
        builder: (context, child) {
          return Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFCDFF00).withValues(
                    alpha: isDark ? 0.15 : 0.08 + glowController.value * 0.04,
                  ),
                  Colors.transparent,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key, required this.isDark, required this.progress});

  final bool isDark;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFFCDFF00), Color(0xFFAADD00)],
                )
              : const LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A)]),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0xFFCDFF00).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: CustomPaint(
          size: const Size(50, 50),
          painter: NeuralCorePainter(progress: progress, isDark: isDark),
        ),
      ),
    );
  }
}
