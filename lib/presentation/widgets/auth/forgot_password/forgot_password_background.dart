import 'package:flutter/material.dart';

class ForgotPasswordGlow extends StatelessWidget {
  const ForgotPasswordGlow({super.key, required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -50,
      left: -50,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(
                    0xFF8B5CF6,
                  ).withValues(alpha: 0.08 + animation.value * 0.04),
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

class ForgotPasswordBackButton extends StatelessWidget {
  const ForgotPasswordBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black.withValues(alpha: 0.7),
            size: 18,
          ),
        ),
      ),
    );
  }
}
