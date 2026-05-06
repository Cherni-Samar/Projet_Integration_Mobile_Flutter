class KashBudget {
  final String id;
  final String category;
  final double limit;
  final double spent;
  final String currency;

  KashBudget({
    required this.id,
    required this.category,
    required this.limit,
    required this.spent,
    required this.currency,
  });

  double get remaining => limit - spent;

  double get usagePercent => limit == 0 ? 0 : (spent / limit).clamp(0, 1);
}
