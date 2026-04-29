import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String agentName;         // 'Hera', 'Kash', etc.
  final String agentIllustration; // 'assets/images/hera.png'
  final Color agentColor;        // agent accent color
  final String packTitle;         // 'Starter', 'Pro', 'Business'
  final int energy;               // energy credits (0 for agents, plan value for plans)
  final double price;             // per-agent price
  final bool isPlan;              // true if this is a plan item, false if agent

  CartItem({
    required this.id,
    required this.agentName,
    required this.agentIllustration,
    required this.agentColor,
    required this.packTitle,
    required this.energy,
    required this.price,
    this.isPlan = false,
  });
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get agents => _items.where((item) => !item.isPlan).toList();
  List<CartItem> get plans => _items.where((item) => item.isPlan).toList();

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalPrice {
    return _items.fold(0.0, (sum, item) => sum + item.price);
  }

  int get totalEnergy {
    // Only sum energy from plan items to avoid double-counting
    return plans.fold(0, (sum, item) => sum + item.energy);
  }
  String selectedPackId = 'energy_boost';

  void setPaymentPack(String packId) {
    selectedPackId = packId;
    notifyListeners();
  }
  /// Returns false if the agent is already in the cart (regardless of pack)
  bool addToCart(CartItem item) {
    // For plans, allow multiple plans but remove existing ones first
    if (item.isPlan) {
      _items.removeWhere((existing) => existing.isPlan);
    } else {
      // For agents, don't allow duplicates
      if (_items.any((existing) => !existing.isPlan && existing.agentName == item.agentName)) {
        return false;
      }
    }
    _items.add(item);
    notifyListeners();
    return true;
  }

  void removeFromCart(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
