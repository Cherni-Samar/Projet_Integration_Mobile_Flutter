import 'package:flutter/material.dart';

class AgentAppBarActions extends StatelessWidget {
  final int cartItemCount;
  final VoidCallback onCartPressed;
  final VoidCallback onSharePressed;
  final bool isDark;

  const AgentAppBarActions({
    super.key,
    required this.cartItemCount,
    required this.onCartPressed,
    required this.onSharePressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cart button with badge
        Stack(
          children: [
            IconButton(
              onPressed: onCartPressed,
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: isDark ? Colors.white : Colors.black,
                  size: 20,
                ),
              ),
            ),
            if (cartItemCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$cartItemCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        // Share button
        IconButton(
          onPressed: onSharePressed,
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.share_outlined,
              color: isDark ? Colors.white : Colors.black,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
