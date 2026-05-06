import 'package:flutter/material.dart';

import 'package:e_team/presentation/widgets/hera/hera_palette.dart';

class HeraHeader extends StatelessWidget {
  final int energy;
  final AnimationController pulseCtrl;
  final AnimationController glowCtrl;
  final VoidCallback onBack;
  final VoidCallback onSpeak;
  final VoidCallback onVision;
  final VoidCallback onHistory;

  const HeraHeader({
    super.key,
    required this.energy,
    required this.pulseCtrl,
    required this.glowCtrl,
    required this.onBack,
    required this.onSpeak,
    required this.onVision,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: HeraPalette.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: HeraPalette.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              HeraCircleBtn(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: onBack,
              ),
              const SizedBox(width: 12),
              AnimatedBuilder(
                animation: glowCtrl,
                builder: (_, child) => Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: HeraPalette.mauve.withValues(
                          alpha: 0.3 + 0.2 * glowCtrl.value,
                        ),
                        blurRadius: 14 + 8 * glowCtrl.value,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: child,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(23),
                  child: Image.asset(
                    'assets/images/hera.png',
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Agent Hera',
                      style: TextStyle(
                        color: HeraPalette.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: pulseCtrl,
                          builder: (_, _) => Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: HeraPalette.lime.withValues(
                                alpha: 0.6 + 0.4 * pulseCtrl.value,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'SURVEILLANCE IA ACTIVE',
                          style: TextStyle(
                            color: HeraPalette.lime,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: HeraPalette.cardSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '⚡ $energy',
                  style: const TextStyle(
                    color: HeraPalette.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: HeraQuickBtn(
                  icon: Icons.graphic_eq_rounded,
                  label: 'PARLER',
                  isPrimary: true,
                  onTap: onSpeak,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: HeraQuickBtn(
                  icon: Icons.history_rounded,
                  label: 'Historique',
                  isPrimary: false,
                  onTap: onHistory,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: HeraQuickBtn(
                  icon: Icons.radar_rounded,
                  label: 'Vision IA',
                  isPrimary: false,
                  onTap: onVision,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HeraCircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const HeraCircleBtn({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: HeraPalette.cardSoft,
        ),
        child: Icon(icon, color: HeraPalette.textPrimary, size: 16),
      ),
    );
  }
}

class HeraQuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const HeraQuickBtn({
    super.key,
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary ? HeraPalette.mauve : HeraPalette.cardSoft,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(color: HeraPalette.border),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isPrimary ? Colors.white : HeraPalette.textSoft,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : HeraPalette.textSoft,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeraPillTabBar extends StatelessWidget {
  final List<(IconData, String)> tabs;
  final int selected;
  final ValueChanged<int> onSelect;

  const HeraPillTabBar({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: HeraPalette.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HeraPalette.border),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selected == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? HeraPalette.mauve : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tabs[index].$1,
                      size: 17,
                      color: isSelected ? Colors.white : HeraPalette.textMuted,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tabs[index].$2,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : HeraPalette.textMuted,
                        fontSize: 10,
                        fontWeight: isSelected
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
