import 'package:flutter/material.dart';

class KashShimmerBubble extends StatelessWidget {
  final AnimationController controller;
  final Widget child;

  const KashShimmerBubble({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final t = controller.value;
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF111511),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: ShaderMask(
              shaderCallback: (rect) {
                final dx = rect.width * (t * 2 - 0.5);
                return LinearGradient(
                  begin: Alignment(-1 + (dx / rect.width), 0),
                  end: Alignment(1 + (dx / rect.width), 0),
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.65),
                    Colors.white.withValues(alpha: 0.15),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.srcATop,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
