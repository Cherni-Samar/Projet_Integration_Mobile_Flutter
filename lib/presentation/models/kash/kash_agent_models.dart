import 'dart:typed_data';

class KashMessage {
  final bool fromUser;
  final String text;
  final Uint8List? imageBytes;

  const KashMessage({
    required this.fromUser,
    required this.text,
    this.imageBytes,
  });
}

class ExtractedExpense {
  final double amount;
  final String currency;
  final String vendor;
  final String category;
  final String dateIso;
  final String description;

  const ExtractedExpense({
    required this.amount,
    required this.currency,
    required this.vendor,
    required this.category,
    required this.dateIso,
    required this.description,
  });

  factory ExtractedExpense.fromJson(Map<String, dynamic> json) {
    final amountRaw = json['amount'];
    final amount = (amountRaw is num)
        ? amountRaw.toDouble()
        : double.parse('$amountRaw');

    return ExtractedExpense(
      amount: amount,
      currency: (json['currency'] ?? '').toString(),
      vendor: (json['vendor'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      dateIso: (json['date'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
    );
  }
}
