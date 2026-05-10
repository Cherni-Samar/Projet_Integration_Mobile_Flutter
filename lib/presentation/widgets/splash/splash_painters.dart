import 'dart:math' as math;

import 'package:flutter/material.dart';

class NeuralCorePainter extends CustomPainter {
  NeuralCorePainter({required this.progress});

  final double progress;

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
  NeuralFluidPainter({required this.progress, required this.time});

  final double progress;
  final double time;

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
