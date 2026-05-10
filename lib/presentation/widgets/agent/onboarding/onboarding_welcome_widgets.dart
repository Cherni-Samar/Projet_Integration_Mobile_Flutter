import 'dart:math' as math;

import 'package:flutter/material.dart';

class OnboardingSkipButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const OnboardingSkipButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.1),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton.icon(
              onPressed: onPressed,
              icon: const Icon(
                Icons.fast_forward_rounded,
                color: Colors.black,
                size: 18,
              ),
              label: Text(
                label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingWelcomeHeader extends StatelessWidget {
  final String subtitle;

  const OnboardingWelcomeHeader({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'E-Team',
            style: TextStyle(
              color: Colors.black,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 16,
              height: 1.5,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingAiLogo extends StatelessWidget {
  final Animation<double> animation;

  const OnboardingAiLogo({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFCDFF00,
                ).withValues(alpha: 0.3 * animation.value),
                blurRadius: 60,
                spreadRadius: 20,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: animation.value * 2 * math.pi,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFCDFF00).withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                ),
              ),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFCDFF00).withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFFCDFF00),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 50,
                  color: Colors.black,
                ),
              ),
              ...List.generate(4, (index) {
                final angle =
                    (index * math.pi / 2) + (animation.value * 2 * math.pi);
                final x = math.cos(angle) * 90;
                final y = math.sin(angle) * 90;
                return Transform.translate(
                  offset: Offset(x, y),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFCDFF00),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class OnboardingSlideToStart extends StatelessWidget {
  final String label;
  final double slidePosition;
  final double maxSlide;
  final bool isSliding;
  final VoidCallback onDragStart;
  final ValueChanged<double> onDragUpdate;
  final VoidCallback onDragEnd;

  const OnboardingSlideToStart({
    super.key,
    required this.label,
    required this.slidePosition,
    required this.maxSlide,
    required this.isSliding,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(35),
        ),
        child: Stack(
          children: [
            Center(
              child: AnimatedOpacity(
                opacity: slidePosition < maxSlide * 0.3 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFFCDFF00),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: slidePosition + 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: isSliding
                  ? Duration.zero
                  : const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              left: slidePosition,
              top: 8,
              child: GestureDetector(
                onHorizontalDragStart: (_) => onDragStart(),
                onHorizontalDragUpdate: (details) =>
                    onDragUpdate(details.delta.dx),
                onHorizontalDragEnd: (_) => onDragEnd(),
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCDFF00),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFCDFF00).withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    slidePosition > maxSlide * 0.5
                        ? Icons.check_rounded
                        : Icons.arrow_forward_rounded,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
