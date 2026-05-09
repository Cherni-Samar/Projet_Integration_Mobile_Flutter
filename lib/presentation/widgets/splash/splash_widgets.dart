import 'dart:math' as math;

import 'package:flutter/material.dart';

class SplashBackground extends StatelessWidget {
  final AnimationController breathController;
  final AnimationController waveController;

  const SplashBackground({
    super.key,
    required this.breathController,
    required this.waveController,
  });

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
  final AnimationController waveController;

  const SplashWaveRings({super.key, required this.waveController});

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

class SplashNeuralCore extends StatelessWidget {
  final Animation<double> breath;

  const SplashNeuralCore({super.key, required this.breath});

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

class SplashBrandFooter extends StatelessWidget {
  final Animation<double> textReveal;
  final AnimationController textController;
  final AnimationController waveController;

  const SplashBrandFooter({
    super.key,
    required this.textReveal,
    required this.textController,
    required this.waveController,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: FadeTransition(
            opacity: textReveal,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SplashBrandTitle(textController: textController),
                const SizedBox(height: 12),
                const SplashTagline(),
                const SizedBox(height: 32),
                SplashLoadingLine(waveController: waveController),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SplashBrandTitle extends StatelessWidget {
  final AnimationController textController;

  const SplashBrandTitle({super.key, required this.textController});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: 'E-Team'.split('').asMap().entries.map((entry) {
        final index = entry.key;
        final letter = entry.value;
        return AnimatedBuilder(
          animation: textController,
          builder: (context, child) {
            final letterProgress = (textController.value * 6 - index).clamp(
              0.0,
              1.0,
            );
            return Opacity(
              opacity: letterProgress,
              child: Transform.translate(
                offset: Offset(0, (1 - letterProgress) * 20),
                child: Text(
                  letter,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1,
                    letterSpacing: 2,
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class SplashTagline extends StatelessWidget {
  const SplashTagline({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFCCFF00).withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'AI that works for you',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class SplashLoadingLine extends StatelessWidget {
  final AnimationController waveController;

  const SplashLoadingLine({super.key, required this.waveController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: AnimatedBuilder(
        animation: waveController,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: (waveController.value * 2) % 1.0,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFCCFF00)),
            minHeight: 2,
            borderRadius: BorderRadius.circular(1),
          );
        },
      ),
    );
  }
}

class NeuralCorePainter extends CustomPainter {
  final double progress;

  NeuralCorePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final centerPaint = Paint()
      ..color = const Color(0xFFCCFF00)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 8, centerPaint);

    final linePaint = Paint()
      ..color = const Color(0xFFCCFF00).withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final nodePaint = Paint()
      ..color = const Color(0xFFCCFF00)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 6; i++) {
      final angle = (i / 6) * math.pi * 2 + progress * math.pi * 0.5;
      final radius = 22 + math.sin(progress * math.pi * 2) * 3;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;

      final lineOpacity =
          0.3 + (math.sin(progress * math.pi * 2 + i) + 1) / 2 * 0.4;
      canvas.drawLine(
        Offset(x, y),
        center,
        linePaint
          ..color = const Color(0xFFCCFF00).withValues(alpha: lineOpacity),
      );

      final nodeSize = 3 + math.sin(progress * math.pi * 2 + i * 0.5) * 1;
      canvas.drawCircle(Offset(x, y), nodeSize.abs(), nodePaint);
    }

    final outerPaint = Paint()
      ..color = const Color(0xFFCCFF00).withValues(alpha: 0.2 + progress * 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, 28 + progress * 4, outerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class NeuralFluidPainter extends CustomPainter {
  final double progress;
  final double time;

  NeuralFluidPainter({required this.progress, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (var i = 0; i < 20; i++) {
      final angle = (i / 20) * math.pi * 2 + time * math.pi;
      final distance = 100 + math.sin(time * math.pi * 2 + i) * 50;
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance * 0.6;
      final radius = 30 + math.sin(progress * math.pi + i) * 20;

      final gradient = RadialGradient(
        colors: [
          const Color(0xFFCCFF00).withValues(alpha: 0.1),
          Colors.transparent,
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: Offset(x, y), radius: radius),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    final linePaint = Paint()
      ..color = const Color(0xFFCCFF00).withValues(alpha: 0.05)
      ..strokeWidth = 0.5;

    for (var i = 0; i < 8; i++) {
      final angle1 = (i / 8) * math.pi * 2 + time * 0.5;
      final angle2 = ((i + 1) / 8) * math.pi * 2 + time * 0.5;
      final r = 150 + math.sin(progress * math.pi * 2) * 30;

      final p1 = Offset(
        center.dx + math.cos(angle1) * r,
        center.dy + math.sin(angle1) * r * 0.6,
      );
      final p2 = Offset(
        center.dx + math.cos(angle2) * r,
        center.dy + math.sin(angle2) * r * 0.6,
      );

      canvas.drawLine(p1, p2, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
