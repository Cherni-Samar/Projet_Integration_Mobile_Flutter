class KashDashboardMetrics {
  final double totalSpent;
  final double totalBudget;
  final int pendingReminders;

  const KashDashboardMetrics({
    required this.totalSpent,
    required this.totalBudget,
    required this.pendingReminders,
  });
}

dynamic kashReadValue(dynamic item, String key) {
  if (item is Map) return item[key];

  try {
    switch (key) {
      case 'vendor':
        return item.vendor;
      case 'amount':
        return item.amount;
      case 'currency':
        return item.currency;
      case 'category':
        return item.category;
      case 'date':
        return item.date;
      case 'limit':
        return item.limit;
      case 'spent':
        return item.spent;
      case 'status':
        return item.status;
      case 'title':
        return item.title;
      case 'dueDate':
        return item.dueDate;
      case 'id':
      case '_id':
        return item.id;
      default:
        return null;
    }
  } catch (_) {
    return null;
  }
}

DateTime kashSafeDate(dynamic value) {
  if (value is DateTime) return value;
  if (value != null) {
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }
  return DateTime.now();
}

KashDashboardMetrics calculateKashDashboardMetrics({
  required List<dynamic> expenses,
  required List<dynamic> budgets,
  required List<dynamic> reminders,
}) {
  var totalSpent = 0.0;
  for (final expense in expenses) {
    final amount =
        (kashReadValue(expense, 'amount') as num?)?.toDouble() ?? 0.0;
    totalSpent += amount;
  }

  var totalBudget = 0.0;
  for (final budget in budgets) {
    final limit = (kashReadValue(budget, 'limit') as num?)?.toDouble() ?? 0.0;
    totalBudget += limit;
  }

  final pendingReminders = reminders
      .where((reminder) => kashReadValue(reminder, 'status') == 'pending')
      .length;

  return KashDashboardMetrics(
    totalSpent: totalSpent,
    totalBudget: totalBudget,
    pendingReminders: pendingReminders,
  );
}

List<String> kashCombinedCategories(List<dynamic> budgets) {
  final categories = <String>{};

  for (final budget in budgets) {
    final category = kashReadValue(budget, 'category')?.toString();
    if (category != null && category.isNotEmpty) {
      categories.add(category);
    }
  }

  categories.addAll([
    'SaaS',
    'Marketing',
    'Travel',
    'Office',
    'Salaries',
    'Other',
  ]);

  return categories.toList();
}
