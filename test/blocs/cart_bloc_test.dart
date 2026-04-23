import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:e_team/blocs/cart/cart_bloc.dart';
import 'package:e_team/blocs/cart/cart_event.dart';
import 'package:e_team/blocs/cart/cart_state.dart';
import 'package:e_team/data/models/cart_item.dart';
import 'package:flutter/material.dart';

CartItem _makeItem({
  String id = '1',
  String agentName = 'Hera',
  double price = 9.99,
  int energy = 1000,
}) =>
    CartItem(
      id: id,
      agentName: agentName,
      agentIllustration: 'assets/images/hera.png',
      agentColor: const Color(0xFF8B5CF6),
      packTitle: 'Starter',
      energy: energy,
      price: price,
    );

void main() {
  group('CartBloc', () {
    test('initial state is empty CartState', () {
      final bloc = CartBloc();
      expect(bloc.state, const CartState());
      expect(bloc.state.itemCount, 0);
      expect(bloc.state.totalPrice, 0.0);
      expect(bloc.state.totalEnergy, 0);
    });

    blocTest<CartBloc, CartState>(
      'emits updated state when CartItemAdded',
      build: () => CartBloc(),
      act: (bloc) => bloc.add(CartItemAdded(_makeItem())),
      expect: () => [
        isA<CartState>().having((s) => s.items.length, 'items', 1),
      ],
    );

    blocTest<CartBloc, CartState>(
      'does not add duplicate agent',
      build: () => CartBloc(),
      act: (bloc) {
        bloc
          ..add(CartItemAdded(_makeItem(id: '1', agentName: 'Hera')))
          ..add(CartItemAdded(_makeItem(id: '2', agentName: 'Hera')));
      },
      expect: () => [
        // After first add
        isA<CartState>().having((s) => s.items.length, 'items', 1),
        // After duplicate attempt — duplicateAttempted true then false
        isA<CartState>().having((s) => s.duplicateAttempted, 'dup', true),
        isA<CartState>().having((s) => s.duplicateAttempted, 'dup', false),
      ],
    );

    blocTest<CartBloc, CartState>(
      'removes item on CartItemRemoved',
      build: () => CartBloc(),
      seed: () => CartState(items: [_makeItem(id: 'abc')]),
      act: (bloc) => bloc.add(const CartItemRemoved('abc')),
      expect: () => [
        isA<CartState>().having((s) => s.items, 'items', isEmpty),
      ],
    );

    blocTest<CartBloc, CartState>(
      'clears all items on CartCleared',
      build: () => CartBloc(),
      seed: () => CartState(items: [
        _makeItem(id: '1', agentName: 'Hera'),
        _makeItem(id: '2', agentName: 'Kash'),
      ]),
      act: (bloc) => bloc.add(const CartCleared()),
      expect: () => [const CartState()],
    );

    test('calculates totalPrice and totalEnergy correctly', () {
      final state = CartState(items: [
        _makeItem(id: '1', price: 10.0, energy: 1000),
        _makeItem(id: '2', agentName: 'Kash', price: 20.0, energy: 2000),
      ]);
      expect(state.totalPrice, 30.0);
      expect(state.totalEnergy, 3000);
    });
  });
}
