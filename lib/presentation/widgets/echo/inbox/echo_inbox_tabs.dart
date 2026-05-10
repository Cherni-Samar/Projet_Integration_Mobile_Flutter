import 'package:flutter/material.dart';

class EchoInboxTabs extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onSelect;

  const EchoInboxTabs({
    super.key,
    required this.selectedTab,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _EchoInboxTabButton(
              label: 'Received',
              index: 0,
              selectedTab: selectedTab,
              onSelect: onSelect,
            ),
          ),
          Expanded(
            child: _EchoInboxTabButton(
              label: 'Sent',
              index: 1,
              selectedTab: selectedTab,
              onSelect: onSelect,
            ),
          ),
        ],
      ),
    );
  }
}

class _EchoInboxTabButton extends StatelessWidget {
  final String label;
  final int index;
  final int selectedTab;
  final ValueChanged<int> onSelect;

  const _EchoInboxTabButton({
    required this.label,
    required this.index,
    required this.selectedTab,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final selected = selectedTab == index;

    return GestureDetector(
      onTap: () => onSelect(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.black87 : Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
