import 'package:flutter/material.dart';

import 'package:e_team/presentation/providers/cart_provider.dart';
import 'package:e_team/presentation/utils/domain_model_color_extensions.dart';
import 'package:e_team/presentation/widgets/cart/cart_helpers.dart';
import 'package:e_team/presentation/widgets/cart/cart_item_parts.dart';

class CartAgentItemCard extends StatelessWidget {
  const CartAgentItemCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.onRemove,
  });

  final CartItem item;
  final bool isDark;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return CartItemShell(
      item: item,
      isDark: isDark,
      child: Row(
        children: [
          CartItemAvatar(item: item),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CartItemName(item: item, isDark: isDark),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const IncludedBadge(),
                    if (item.energy > 0) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.bolt, color: item.agentColor, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        formatCartEnergy(item.energy),
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.remove_circle_outline,
              color: Colors.grey[400],
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
