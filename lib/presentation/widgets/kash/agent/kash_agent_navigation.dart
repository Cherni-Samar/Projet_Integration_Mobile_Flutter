import 'package:flutter/material.dart';

import 'package:e_team/presentation/widgets/kash/agent/kash_agent_theme.dart';

class KashTabNavigation extends StatelessWidget {
  const KashTabNavigation({
    super.key,
    required this.selectedTab,
    required this.onSelect,
  });

  final int selectedTab;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF111511),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _KashTabButton(
            title: '💬 Discussion',
            index: 0,
            selectedTab: selectedTab,
            onSelect: onSelect,
          ),
          _KashTabButton(
            title: '💰 Statistiques',
            index: 1,
            selectedTab: selectedTab,
            onSelect: onSelect,
          ),
        ],
      ),
    );
  }
}

class _KashTabButton extends StatelessWidget {
  const _KashTabButton({
    required this.title,
    required this.index,
    required this.selectedTab,
    required this.onSelect,
  });

  final String title;
  final int index;
  final int selectedTab;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? KashAgentShell.volt.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? KashAgentShell.volt : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
