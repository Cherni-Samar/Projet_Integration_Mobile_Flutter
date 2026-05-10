import 'package:flutter/material.dart';

class SplashBrandFooter extends StatelessWidget {
  const SplashBrandFooter({
    super.key,
    required this.textReveal,
    required this.textController,
    required this.waveController,
  });

  final Animation<double> textReveal;
  final AnimationController textController;
  final AnimationController waveController;

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
  const SplashBrandTitle({super.key, required this.textController});

  final AnimationController textController;

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
  const SplashLoadingLine({super.key, required this.waveController});

  final AnimationController waveController;

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
