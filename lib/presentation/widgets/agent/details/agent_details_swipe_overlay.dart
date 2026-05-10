import 'package:e_team/presentation/widgets/agent/agent_swipe_dots.dart';
import 'package:flutter/material.dart';

class AgentDetailsSwipeDotsOverlay extends StatelessWidget {
  const AgentDetailsSwipeDotsOverlay({
    super.key,
    required this.isVisible,
    required this.itemCount,
    required this.pageController,
    required this.currentIndex,
    required this.isDark,
  });

  final bool isVisible;
  final int itemCount;
  final PageController pageController;
  final int currentIndex;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Positioned(
      top: MediaQuery.of(context).padding.top + kToolbarHeight + 10,
      left: 0,
      right: 0,
      child: Center(
        child: AgentSwipeDots(
          itemCount: itemCount,
          pageController: pageController,
          currentIndex: currentIndex,
          isDark: isDark,
        ),
      ),
    );
  }
}
