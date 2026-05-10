import 'package:e_team/presentation/widgets/kash/kash_theme.dart';
import 'package:flutter/material.dart';

Color getKashCategoryColor(String category) {
  final colors = {
    'SaaS': KP.accent,
    'Marketing': Colors.purple,
    'Travel': Colors.orange,
    'Office': Colors.green,
    'Salaries': KP.danger,
    'Other': KP.textMuted(false),
  };
  return colors[category] ?? KP.primary;
}
