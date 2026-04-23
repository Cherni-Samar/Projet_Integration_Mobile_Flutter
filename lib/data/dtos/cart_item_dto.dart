class CartItemDto {
  final String id;
  final String agentName;
  final String agentIllustration;
  final int agentColorValue;
  final String packTitle;
  final int energy;
  final double price;

  const CartItemDto({
    required this.id,
    required this.agentName,
    required this.agentIllustration,
    required this.agentColorValue,
    required this.packTitle,
    required this.energy,
    required this.price,
  });

  factory CartItemDto.fromJson(Map<String, dynamic> json) => CartItemDto(
        id: (json['id'] ?? '').toString(),
        agentName: (json['agentName'] ?? '').toString(),
        agentIllustration: (json['agentIllustration'] ?? '').toString(),
        agentColorValue: (json['agentColorValue'] as num?)?.toInt() ?? 0xFF000000,
        packTitle: (json['packTitle'] ?? '').toString(),
        energy: (json['energy'] as num?)?.toInt() ?? 0,
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'agentName': agentName,
        'agentIllustration': agentIllustration,
        'agentColorValue': agentColorValue,
        'packTitle': packTitle,
        'energy': energy,
        'price': price,
      };
}
