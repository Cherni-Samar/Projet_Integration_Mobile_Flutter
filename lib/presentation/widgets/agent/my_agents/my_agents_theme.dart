import 'package:flutter/material.dart';

class MyAgentsTheme {
  const MyAgentsTheme._();

  static const volt = Color(0xFFCDFF00);
}

String formatAgentEnergy(int n) {
  if (n >= 1000) {
    return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
  }
  return n.toString();
}
