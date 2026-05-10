import 'package:flutter/material.dart';

import 'package:e_team/presentation/providers/cart_provider.dart';
import 'package:e_team/presentation/utils/domain_model_color_extensions.dart';

class CartItemAvatar extends StatelessWidget {
  const CartItemAvatar({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: item.agentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
          item.agentIllustration,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Icon(Icons.person, color: item.agentColor),
        ),
      ),
    );
  }
}

class CartItemShell extends StatelessWidget {
  const CartItemShell({
    super.key,
    required this.item,
    required this.isDark,
    required this.child,
  });

  final CartItem item;
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.agentColor.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: item.agentColor.withValues(alpha: isDark ? 0.1 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class CartItemName extends StatelessWidget {
  const CartItemName({super.key, required this.item, required this.isDark});

  final CartItem item;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      item.agentName,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }
}

class IncludedBadge extends StatelessWidget {
  const IncludedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Included',
        style: TextStyle(
          color: Colors.green,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
