import 'package:flutter/material.dart';

/// A [CustomPainter] that draws a single pulsating ring around a circular
/// avatar. The [progress] value (0.0 → 1.0) drives both the radius expansion
/// and the opacity fade, producing a breathing-ring effect when driven by a
/// repeating [AnimationController].
class PulsatingRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  PulsatingRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3 - progress * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius * (0.8 + progress * 0.2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
