import 'package:flutter_bloc/flutter_bloc.dart';

import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<CartItemAdded>(_onItemAdded);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartCleared>(_onCleared);
  }

  void _onItemAdded(CartItemAdded event, Emitter<CartState> emit) {
    final alreadyInCart = state.items
        .any((e) => e.agentName == event.item.agentName);
    if (alreadyInCart) {
      emit(state.copyWith(duplicateAttempted: true));
      // Reset flag immediately so listeners don't get stuck
      emit(state.copyWith(duplicateAttempted: false));
      return;
    }
    emit(state.copyWith(
      items: [...state.items, event.item],
      duplicateAttempted: false,
    ));
  }

  void _onItemRemoved(CartItemRemoved event, Emitter<CartState> emit) {
    emit(state.copyWith(
      items: state.items.where((item) => item.id != event.itemId).toList(),
    ));
  }

  void _onCleared(CartCleared event, Emitter<CartState> emit) {
    emit(const CartState());
  }
}
