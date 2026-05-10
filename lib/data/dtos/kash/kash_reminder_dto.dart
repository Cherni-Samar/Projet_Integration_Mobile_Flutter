class KashReminderDTO {
  final String id;
  final String title;
  final double amount;
  final String currency;
  final DateTime dueDate;
  final String status;
  final String notes;

  KashReminderDTO.fromJson(Map<String, dynamic> json)
    : id = json['_id'] ?? '',
      title = json['title'] ?? '',
      amount = (json['amount'] ?? 0).toDouble(),
      currency = json['currency'] ?? 'TND',
      dueDate = DateTime.parse(json['dueDate']),
      status = json['status'] ?? 'pending',
      notes = json['notes'] ?? '';
}
