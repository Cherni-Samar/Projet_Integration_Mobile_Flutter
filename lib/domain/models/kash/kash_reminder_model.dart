class KashReminder {
  final String id;
  final String title;
  final double amount;
  final String currency;
  final DateTime dueDate;
  final String status;
  final String notes;

  KashReminder({
    required this.id,
    required this.title,
    required this.amount,
    required this.currency,
    required this.dueDate,
    required this.status,
    required this.notes,
  });

  bool get isPaid => status == 'paid';

  bool get isOverdue => !isPaid && dueDate.isBefore(DateTime.now());
}
