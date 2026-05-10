import 'package:e_team/presentation/widgets/kash/kash_dashboard_helpers.dart';
import 'package:e_team/presentation/widgets/kash/kash_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
