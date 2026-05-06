import 'package:flutter/material.dart';
import 'kash_theme.dart';

/// Budgets tab for Kash dashboard showing all budgets by project
class KashBudgetsTab extends StatelessWidget {
  final bool isDark;
  final bool loadingBudgets;
  final List<dynamic> budgets;
  final VoidCallback onAddBudget;
  final Widget Function(String message, IconData icon, bool isDark)
  buildEmptyState;
  final dynamic Function(dynamic item, String key) readValue;

  const KashBudgetsTab({
    Key? key,
    required this.isDark,
    required this.loadingBudgets,
    required this.budgets,
    required this.onAddBudget,
    required this.buildEmptyState,
    required this.readValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (loadingBudgets) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        // Header with Add button - ALWAYS VISIBLE
        Container(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Row(
            children: [
              Text(
                'Budgets par projet',
                style: TextStyle(
                  color: KP.text(isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onAddBudget,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: KP.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 13, color: KP.primary),
                      const SizedBox(width: 5),
                      const Text(
                        'Ajouter',
                        style: TextStyle(
                          color: KP.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Content - either list or empty state
        Expanded(
          child: budgets.isEmpty
              ? Center(
                  child: buildEmptyState(
                    'Aucun budget',
                    Icons.trending_up_rounded,
                    isDark,
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  children: budgets.map((b) => _buildBudgetCard(b)).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildBudgetCard(dynamic budget) {
    final category = (readValue(budget, 'category') ?? 'Unknown').toString();
    final limit = (readValue(budget, 'limit') as num?)?.toDouble() ?? 0.0;
    final spent = (readValue(budget, 'spent') as num?)?.toDouble() ?? 0.0;
    final currency = (readValue(budget, 'currency') ?? 'TND').toString();

    final percentage = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final color = percentage > 0.8
        ? KP.danger
        : percentage > 0.5
        ? KP.warning
        : KP.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: KP.card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: KP.border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: TextStyle(
                  color: KP.text(isDark),
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(percentage * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: KP.cardSoft(isDark),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${spent.toStringAsFixed(2)} / ${limit.toStringAsFixed(2)} $currency',
            style: TextStyle(color: KP.textMuted(isDark), fontSize: 11),
          ),
        ],
      ),
    );
  }
}
