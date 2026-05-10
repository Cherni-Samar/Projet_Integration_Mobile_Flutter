import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:e_team/presentation/widgets/hera/voice/hera_voice_theme.dart';

class HeraVoiceBackground extends StatelessWidget {
  const HeraVoiceBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _LinesPainter(), size: Size.infinite);
  }
}

class _LinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = HeraVoiceTheme.accent.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width * 0.74, size.height * 0.14);

    for (double r = 30; r < 180; r += 18) {
      final path = Path();
      for (double a = 0; a <= math.pi * 2; a += 0.12) {
        final wobble = math.sin(a * 3) * 4 + math.cos(a * 5) * 2;
        final x = center.dx + math.cos(a) * (r + wobble);
        final y = center.dy + math.sin(a) * (r + wobble);
        if (a == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
