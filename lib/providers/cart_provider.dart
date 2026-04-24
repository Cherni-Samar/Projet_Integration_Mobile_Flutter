import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
export '../models/cart_item_model.dart';


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
