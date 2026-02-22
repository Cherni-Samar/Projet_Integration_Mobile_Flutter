import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final String plan; // 'free', 'hourly', 'monthly'
  final double price;
  final Color color;
  final String illustration;

  CartItem({
    required this.id,
    required this.title,
    required this.plan,
    required this.price,
    required this.color,
    required this.illustration,
  });
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalPrice {
    return _items.fold(0.0, (sum, item) => sum + item.price);
  }

  void addToCart(CartItem item) {
    // Check if agent is already in cart to maybe prevent duplicates or just allow it
    // For now, allow multiple since they might buy different plans? 
    // Actually, usually you hire an agent once. Let's allow adding for now.
    _items.add(item);
    notifyListeners();
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
