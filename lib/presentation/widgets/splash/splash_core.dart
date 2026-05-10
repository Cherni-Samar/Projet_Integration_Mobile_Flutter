import 'package:flutter/material.dart';

import 'package:e_team/presentation/widgets/splash/splash_painters.dart';

class SplashNeuralCore extends StatelessWidget {
  const SplashNeuralCore({super.key, required this.breath});

  final Animation<double> breath;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: breath,
        builder: (context, child) {
          final scale = 0.8 + (breath.value * 0.2);
          final glowIntensity = 0.3 + (breath.value * 0.4);

          return Transform.scale(
            scale: scale,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFCCFF00).withValues(alpha: glowIntensity),
                    const Color(
                      0xFFCCFF00,
                    ).withValues(alpha: glowIntensity * 0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFFCCFF00,
                    ).withValues(alpha: glowIntensity * 0.6),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size(70, 70),
                  painter: NeuralCorePainter(progress: breath.value),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
