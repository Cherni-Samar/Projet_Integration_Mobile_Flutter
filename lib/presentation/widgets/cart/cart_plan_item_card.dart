import 'package:flutter/material.dart';

import 'package:e_team/presentation/providers/cart_provider.dart';
import 'package:e_team/presentation/utils/domain_model_color_extensions.dart';
import 'package:e_team/presentation/widgets/cart/cart_helpers.dart';
import 'package:e_team/presentation/widgets/cart/cart_item_parts.dart';
import 'package:e_team/presentation/widgets/cart/cart_theme.dart';

class CartPlanItemCard extends StatelessWidget {
  const CartPlanItemCard({
    super.key,
    required this.item,
    required this.agentCount,
    required this.isDark,
  });

  final CartItem item;
  final int agentCount;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return CartItemShell(
      item: item,
      isDark: isDark,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: item.agentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.workspace_premium,
              color: item.agentColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CartItemName(item: item, isDark: isDark),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: item.agentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Pack $agentCount agents',
                        style: TextStyle(
                          color: item.agentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.bolt, color: item.agentColor, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      '${formatCartEnergy(item.energy)} energy credits',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '\$${item.price.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? CartTheme.volt : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
