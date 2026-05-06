class KashExpenseDTO {
  final String id;
  final double amount;
  final String currency;
  final String vendor;
  final String category;
  final String description;
  final DateTime date;

  KashExpenseDTO.fromJson(Map<String, dynamic> json)
    : id = json['_id'] ?? '',
      amount = (json['amount'] ?? 0).toDouble(),
      currency = json['currency'] ?? 'TND',
      vendor = json['vendor'] ?? '',
      category = json['category'] ?? '',
      description = json['description'] ?? '',
      date = DateTime.parse(json['date']);
}
