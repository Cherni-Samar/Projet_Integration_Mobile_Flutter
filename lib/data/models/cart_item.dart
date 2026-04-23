import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CartItem extends Equatable {
  final String id;
  final String agentName;
  final String agentIllustration;
  final Color agentColor;
  final String packTitle;
  final int energy;
  final double price;

  const CartItem({
    required this.id,
    required this.agentName,
    required this.agentIllustration,
    required this.agentColor,
    required this.packTitle,
    required this.energy,
    required this.price,
  });

  @override
  List<Object?> get props =>
      [id, agentName, agentIllustration, agentColor, packTitle, energy, price];
}
