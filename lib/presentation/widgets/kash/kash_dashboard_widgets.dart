import 'package:e_team/presentation/widgets/kash/kash_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KashDashboardHeader extends StatelessWidget {
  const KashDashboardHeader({
    super.key,
    required this.isDark,
    required this.energy,
    required this.pulseController,
    required this.glowController,
    required this.onBack,
  });

  final bool isDark;
  final int energy;
  final AnimationController pulseController;
  final AnimationController glowController;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: KP.card(isDark),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: KP.border(isDark)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.07),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: KP.text(isDark),
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedBuilder(
            animation: glowController,
            builder: (_, child) => Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: KP.primary.withValues(
                      alpha: 0.25 + 0.2 * glowController.value,
                    ),
                    blurRadius: 14 + 8 * glowController.value,
                  ),
                ],
              ),
              child: child,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: Image.asset(
                'assets/images/kash.png',
                width: 46,
                height: 46,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => CircleAvatar(
                  backgroundColor: KP.primary,
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kash Dashboard',
                  style: TextStyle(
                    color: KP.text(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: pulseController,
                      builder: (_, _) => Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: KP.primary.withValues(
                            alpha: 0.6 + 0.4 * pulseController.value,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'FINANCIAL MANAGEMENT',
                      style: TextStyle(
                        color: KP.primary,
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
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '⚡ $energy',
              style: TextStyle(
                color: KP.text(isDark),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

class KashExpenseCard extends StatelessWidget {
  const KashExpenseCard({
    super.key,
    required this.isDark,
    required this.vendor,
    required this.amount,
    required this.currency,
    required this.category,
    required this.date,
  });

  final bool isDark;
  final String vendor;
  final double amount;
  final String currency;
  final String category;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final categoryColor = getKashCategoryColor(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: KP.card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: KP.border(isDark)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: categoryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor,
                  style: TextStyle(
                    color: KP.text(isDark),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: KP.textMuted(isDark),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('EEE dd MMM', 'fr_FR').format(date),
                      style: TextStyle(
                        color: KP.textMuted(isDark),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('•', style: TextStyle(color: KP.textMuted(isDark))),
                    const SizedBox(width: 8),
                    Text(
                      category,
                      style: TextStyle(
                        color: KP.textMuted(isDark),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} $currency',
            style: TextStyle(
              color: KP.danger,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class KashEmptyState extends StatelessWidget {
  const KashEmptyState({
    super.key,
    required this.message,
    required this.icon,
    required this.isDark,
  });

  final String message;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: KP.card(isDark),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: KP.border(isDark)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: KP.textSoft(isDark)),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(color: KP.textMuted(isDark), fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Color getKashCategoryColor(String category) {
  final colors = {
    'SaaS': KP.accent,
    'Marketing': Colors.purple,
    'Travel': Colors.orange,
    'Office': Colors.green,
    'Salaries': KP.danger,
    'Other': KP.textMuted(false),
  };
  return colors[category] ?? KP.primary;
}
