import 'package:e_team/presentation/providers/cart_provider.dart';
import 'package:e_team/presentation/utils/domain_model_color_extensions.dart';
import 'package:e_team/presentation/widgets/cart/cart_helpers.dart';
import 'package:e_team/presentation/widgets/cart/cart_theme.dart';
import 'package:flutter/material.dart';

class CartSectionTitle extends StatelessWidget {
  const CartSectionTitle({
    super.key,
    required this.title,
    required this.isDark,
  });

  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }
}

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
    return _CartItemShell(
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
                _CartItemName(item: item, isDark: isDark),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const _IncludedBadge(),
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
    return _CartItemShell(
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
                _CartItemName(item: item, isDark: isDark),
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

class _CartItemShell extends StatelessWidget {
  const _CartItemShell({
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

class _CartItemName extends StatelessWidget {
  const _CartItemName({required this.item, required this.isDark});

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

class _IncludedBadge extends StatelessWidget {
  const _IncludedBadge();

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
