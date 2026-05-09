class PricingOffer {
  final String sectionId;
  final String packId;
  final String price;
  final int credits;
  final int? agents;
  final bool isBestValue;

  const PricingOffer({
    required this.sectionId,
    required this.packId,
    required this.price,
    required this.credits,
    this.agents,
    this.isBestValue = false,
  });
}

class PricingOfferSectionId {
  static const subscriptions = 'subscriptions';
  static const energyTopups = 'energy_topups';
}
