import 'package:flutter/material.dart';
import 'kash_theme.dart';

/// Overview tab for Kash dashboard showing stats and recent expenses
class KashOverviewTab extends StatelessWidget {
  final bool isDark;
  final bool loadingExpenses;
  final double totalSpent;
  final double totalBudget;
  final int pendingReminders;
  final List<dynamic> expenses;
  final VoidCallback onAddExpense;
  final Widget Function(dynamic expense, bool isDark) buildExpenseCard;
  final Widget Function(String message, IconData icon, bool isDark) buildEmptyState;

  const KashOverviewTab({
    Key? key,
    required this.isDark,
    required this.loadingExpenses,
    required this.totalSpent,
    required this.totalBudget,
    required this.pendingReminders,
    required this.expenses,
    required this.onAddExpense,
    required this.buildExpenseCard,
    required this.buildEmptyState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      children: [
        _buildStatsPulse(),
        const SizedBox(height: 16),
        _buildRecentExpenses(),
      ],
    );
  }

  Widget _buildStatsPulse() {
    final pct = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: KP.card(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: KP.border(isDark)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _statItem(
                  totalSpent.toStringAsFixed(2),
                  'DÉPENSÉ',
                  KP.danger,
                  Icons.trending_down_rounded,
                ),
              ),
              Container(width: 1, height: 50, color: KP.border(isDark)),
              Expanded(
                child: _statItem(
                  totalBudget.toStringAsFixed(2),
                  'BUDGET',
                  KP.primary,
                  Icons.account_balance_rounded,
                ),
              ),
              Container(width: 1, height: 50, color: KP.border(isDark)),
              Expanded(
                child: _statItem(
                  '$pendingReminders',
                  'PAIEMENTS',
                  KP.warning,
                  Icons.notifications_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Utilisation du budget', style: TextStyle(color: KP.textMuted(isDark), fontSize: 11)),
              const Spacer(),
              Text(
                '${(pct * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: pct > 0.8 ? KP.danger : KP.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 7,
              backgroundColor: KP.cardSoft(isDark),
              valueColor: AlwaysStoppedAnimation(pct > 0.8 ? KP.danger : KP.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(
    String val,
    String label,
    Color color,
    IconData icon,
  ) =>
      Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            val,
            style: TextStyle(
              color: KP.text(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: KP.textMuted(isDark),
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      );

  Widget _buildRecentExpenses() {
    if (loadingExpenses) return const Center(child: CircularProgressIndicator());
    if (expenses.isEmpty)
      return buildEmptyState('Aucune dépense', Icons.inbox_rounded, isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Dépenses récentes',
              style: TextStyle(
                color: KP.text(isDark),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onAddExpense,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: KP.primary.withOpacity(0.12),
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
        const SizedBox(height: 12),
        ...expenses.take(5).map((e) => buildExpenseCard(e, isDark)),
      ],
    );
  }
}
