import 'package:flutter/material.dart';
import 'kash_theme.dart';

/// Expenses tab for Kash dashboard showing all expenses
class KashExpensesTab extends StatelessWidget {
  final bool isDark;
  final bool loadingExpenses;
  final List<dynamic> expenses;
  final VoidCallback onAddExpense;
  final Widget Function(dynamic expense, bool isDark) buildExpenseCard;
  final Widget Function(String message, IconData icon, bool isDark)
  buildEmptyState;

  const KashExpensesTab({
    Key? key,
    required this.isDark,
    required this.loadingExpenses,
    required this.expenses,
    required this.onAddExpense,
    required this.buildExpenseCard,
    required this.buildEmptyState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (loadingExpenses)
      return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        // Header with Add button - ALWAYS VISIBLE
        Container(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Row(
            children: [
              Text(
                'Toutes les dépenses',
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
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
        ),
        const SizedBox(height: 16),
        // Content - either list or empty state
        Expanded(
          child: expenses.isEmpty
              ? Center(
                  child: buildEmptyState(
                    'Aucune dépense',
                    Icons.inbox_rounded,
                    isDark,
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  children: expenses
                      .map((e) => buildExpenseCard(e, isDark))
                      .toList(),
                ),
        ),
      ],
    );
  }
}
