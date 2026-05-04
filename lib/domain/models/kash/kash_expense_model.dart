class KashExpense {
  final String id;
  final double amount;
  final String currency;
  final String vendor;
  final String category;
  final String description;
  final DateTime date;

  KashExpense({
    required this.id,
    required this.amount,
    required this.currency,
    required this.vendor,
    required this.category,
    required this.description,
    required this.date,
  });
}