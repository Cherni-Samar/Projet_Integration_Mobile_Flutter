class CartItem {
  final String id;
  final String agentName; // 'Hera', 'Kash', etc.
  final String agentIllustration; // 'assets/images/hera.png'
  final int agentColorValue; // agent accent color value
  final String packTitle; // 'Starter', 'Pro', 'Business'
  final int energy; // energy credits (0 for agents, plan value for plans)
  final double price; // per-agent price
  final bool isPlan; // true if this is a plan item, false if agent

  CartItem({
    required this.id,
    required this.agentName,
    required this.agentIllustration,
    required this.agentColorValue,
    required this.packTitle,
    required this.energy,
    required this.price,
    this.isPlan = false,
  });
}
