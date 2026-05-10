class PaymentPlan {
  final String id;
  final String title;
  final double price;
  final int agentsAllowed;
  final int energyCredits;
  final String description;
  final String displayLabel;
  final bool isRecommended;
  final bool isBestValue;

  const PaymentPlan({
    required this.id,
    required this.title,
    required this.price,
    required this.agentsAllowed,
    required this.energyCredits,
    required this.description,
    required this.displayLabel,
    this.isRecommended = false,
    this.isBestValue = false,
  });

  /// Get price in cents for backend/Stripe integration
  int get priceInCents => (price * 100).round();

  /// Get formatted price string for display
  String get formattedPrice => '\$${price.toStringAsFixed(0)}';

  /// Convert to Map for backward compatibility
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'agentsAllowed': agentsAllowed,
      'energyCredits': energyCredits,
      'description': description,
      'displayLabel': displayLabel,
      'isRecommended': isRecommended,
      'isBestValue': isBestValue,
      'priceInCents': priceInCents,
      'formattedPrice': formattedPrice,
    };
  }
}
