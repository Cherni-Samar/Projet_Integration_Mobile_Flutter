import '../../data/models/cart_item.dart';
import '../../domain/repositories/i_cart_repository.dart';

class CartRepository implements ICartRepository {
  final List<CartItem> _items = [];

  @override
  List<CartItem> getItems() => List.unmodifiable(_items);

  @override
  bool addToCart(CartItem item) {
    if (_items.any((e) => e.agentName == item.agentName)) {
      return false;
    }
    _items.add(item);
    return true;
  }

  @override
  void removeFromCart(String id) {
    _items.removeWhere((item) => item.id == id);
  }

  @override
  void clearCart() => _items.clear();

  @override
  double get totalPrice =>
      _items.fold(0.0, (sum, item) => sum + item.price);

  @override
  int get totalEnergy =>
      _items.fold(0, (sum, item) => sum + item.energy);
}
