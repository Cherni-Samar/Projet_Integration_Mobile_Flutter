import 'package:flutter/material.dart';

import 'package:e_team/presentation/widgets/hera/voice/hera_voice_theme.dart';

class HeraVoiceOrbStage extends StatelessWidget {
  const HeraVoiceOrbStage({
    super.key,
    required this.pulseController,
    required this.floatController,
    required this.pulseAnimation,
    required this.floatAnimation,
  });

  final AnimationController pulseController;
  final AnimationController floatController;
  final Animation<double> pulseAnimation;
  final Animation<double> floatAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([pulseController, floatController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, floatAnimation.value),
          child: Transform.scale(scale: pulseAnimation.value, child: child),
        );
      },
      child: const HeraOrb(),
    );
  }
}

class HeraOrb extends StatelessWidget {
  const HeraOrb({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: HeraVoiceTheme.accent.withValues(alpha: 0.18),
                  blurRadius: 60,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
          Container(
            width: 214,
            height: 214,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF7B4FD4),
                  HeraVoiceTheme.accent,
                  Color(0xFFD4A8FF),
                  Color(0xFF7B4FD4),
                  Color(0xFF3A1F6E),
                  Color(0xFF1A1A2E),
                ],
              ),
            ),
          ),
          Container(
            width: 194,
            height: 194,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.35),
                  HeraVoiceTheme.accent.withValues(alpha: 0.50),
                  const Color(0xFF080808),
                ],
                stops: const [0.0, 0.38, 1.0],
              ),
            ),
          ),
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  HeraVoiceTheme.accent.withValues(alpha: 0.80),
                  const Color(0xFF6B3FA0).withValues(alpha: 0.60),
                  Colors.black,
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
