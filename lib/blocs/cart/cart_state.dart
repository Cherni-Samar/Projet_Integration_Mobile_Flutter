import 'package:equatable/equatable.dart';

import '../../data/models/cart_item.dart';

class CartState extends Equatable {
  final List<CartItem> items;
  final bool duplicateAttempted;

  const CartState({
    this.items = const [],
    this.duplicateAttempted = false,
  });

  double get totalPrice =>
      items.fold(0.0, (sum, item) => sum + item.price);

  int get totalEnergy =>
      items.fold(0, (sum, item) => sum + item.energy);

  int get itemCount => items.length;

  CartState copyWith({
    List<CartItem>? items,
    bool? duplicateAttempted,
  }) {
    return CartState(
      items: items ?? this.items,
      duplicateAttempted: duplicateAttempted ?? this.duplicateAttempted,
    );
  }

  @override
  List<Object?> get props => [items, duplicateAttempted];
}
