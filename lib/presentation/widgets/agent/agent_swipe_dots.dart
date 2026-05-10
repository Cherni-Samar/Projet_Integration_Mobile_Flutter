import 'package:flutter/material.dart';

class AgentSwipeDots extends StatelessWidget {
  final int itemCount;
  final PageController pageController;
  final int currentIndex;
  final bool isDark;

  const AgentSwipeDots({
    super.key,
    required this.itemCount,
    required this.pageController,
    required this.currentIndex,
    required this.isDark,
  });

  double _pageValue() {
    if (!pageController.hasClients) return currentIndex.toDouble();
    return pageController.page ?? currentIndex.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, _) {
        final page = _pageValue();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(itemCount, (i) {
            final dist = (page - i).abs().clamp(0.0, 1.0);
            final t = 1.0 - dist;
            final width = 6.0 + (10.0 - 6.0) * t;
            const height = 6.0;
            final opacity = 0.35 + (1.0 - 0.35) * t;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(
                  alpha: opacity,
                ),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        );
      },
    );
  }
}
