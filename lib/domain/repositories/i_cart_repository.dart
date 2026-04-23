import '../../data/models/cart_item.dart';

abstract class ICartRepository {
  List<CartItem> getItems();
  /// Returns false if the agent is already in the cart.
  bool addToCart(CartItem item);
  void removeFromCart(String id);
  void clearCart();
  double get totalPrice;
  int get totalEnergy;
}
