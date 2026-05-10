import 'package:e_team/presentation/widgets/kash/kash_theme.dart';
import 'package:flutter/material.dart';

class KashPillTabBar extends StatelessWidget {
  const KashPillTabBar({
    super.key,
    required this.isDark,
    required this.tabs,
    required this.selectedTab,
    required this.onTabSelected,
  });

  final bool isDark;
  final List<(IconData, String)> tabs;
  final int selectedTab;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: KP.card(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: KP.border(isDark)),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final selected = selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? KP.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tabs[index].$1,
                      size: 17,
                      color: selected ? Colors.white : KP.textMuted(isDark),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tabs[index].$2,
                      style: TextStyle(
                        color: selected ? Colors.white : KP.textMuted(isDark),
                        fontSize: 10,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
