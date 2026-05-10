import 'package:flutter/material.dart';

import 'package:e_team/presentation/widgets/auth/forgot_password/forgot_password_painter.dart';

class ForgotPasswordNeuralIcon extends StatelessWidget {
  const ForgotPasswordNeuralIcon({super.key, required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: CustomPaint(
              size: const Size(50, 50),
              painter: NeuralCorePainter(
                progress: animation.value,
                color: const Color(0xFF8B5CF6),
              ),
            ),
          ),
        );
      },
    );
  }
}
