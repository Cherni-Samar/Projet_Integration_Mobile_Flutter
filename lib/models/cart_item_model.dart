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
