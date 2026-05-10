import 'package:flutter/material.dart';

import 'package:e_team/presentation/widgets/splash/splash_painters.dart';

class SplashBackground extends StatelessWidget {
  const SplashBackground({
    super.key,
    required this.breathController,
    required this.waveController,
  });

  final AnimationController breathController;
  final AnimationController waveController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: breathController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: NeuralFluidPainter(
            progress: breathController.value,
            time: waveController.value,
          ),
        );
      },
    );
  }
}

class SplashWaveRings extends StatelessWidget {
  const SplashWaveRings({super.key, required this.waveController});

  final AnimationController waveController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(4, (index) {
        return AnimatedBuilder(
          animation: waveController,
          builder: (context, child) {
            final delay = index * 0.25;
            final waveProgress = (waveController.value + delay) % 1.0;

            return Center(
              child: Container(
                width: 200 + (waveProgress * 300),
                height: 200 + (waveProgress * 300),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(
                      0xFFCCFF00,
                    ).withValues(alpha: (1 - waveProgress) * 0.3),
                    width: 1.5,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
