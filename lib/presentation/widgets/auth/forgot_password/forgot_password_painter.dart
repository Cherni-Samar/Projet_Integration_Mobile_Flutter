import 'dart:math' as math;

import 'package:flutter/material.dart';

class NeuralCorePainter extends CustomPainter {
  NeuralCorePainter({
    required this.progress,
    this.color = const Color(0xFFCCFF00),
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final centerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 6, centerPaint);

    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final nodePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 6; i++) {
      final angle = (i / 6) * math.pi * 2 + progress * math.pi * 0.5;
      final radius = 18 + math.sin(progress * math.pi * 2) * 2;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;

      final lineOpacity =
          0.3 + (math.sin(progress * math.pi * 2 + i) + 1) / 2 * 0.4;
      canvas.drawLine(
        Offset(x, y),
        center,
        linePaint..color = color.withValues(alpha: lineOpacity),
      );

      final nodeSize = 2.5 + math.sin(progress * math.pi * 2 + i * 0.5) * 0.8;
      canvas.drawCircle(Offset(x, y), nodeSize.abs(), nodePaint);
    }

    final outerPaint = Paint()
      ..color = color.withValues(alpha: 0.2 + progress * 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, 24 + progress * 3, outerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
