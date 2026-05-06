class KashBudgetDTO {
  final String id;
  final String category;
  final double limit;
  final double spent;
  final String currency;

  KashBudgetDTO.fromJson(Map<String, dynamic> json)
    : id = json['_id'] ?? '',
      category = json['category'] ?? '',
      limit = (json['limit'] ?? 0).toDouble(),
      spent = (json['spent'] ?? 0).toDouble(),
      currency = json['currency'] ?? 'TND';
}
