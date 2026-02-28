import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String agentName;         // 'Hera', 'Kash', etc.
  final String agentIllustration; // 'assets/images/hera.png'
  final Color agentColor;        // agent accent color
  final String packTitle;         // 'Starter', 'Pro', 'Business'
  final int energy;               // 1000, 6000, 15000
  final double price;             // per-agent price

  CartItem({
    required this.id,
    required this.agentName,
    required this.agentIllustration,
    required this.agentColor,
    required this.packTitle,
    required this.energy,
    required this.price,
  });
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalPrice {
    return _items.fold(0.0, (sum, item) => sum + item.price);
  }

  int get totalEnergy {
    return _items.fold(0, (sum, item) => sum + item.energy);
  }

  /// Returns false if the agent is already in the cart (regardless of pack)
  bool addToCart(CartItem item) {
    if (_items.any((existing) => existing.agentName == item.agentName)) {
      return false;
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
