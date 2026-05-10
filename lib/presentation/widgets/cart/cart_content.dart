import 'package:e_team/presentation/providers/cart_provider.dart';
import 'package:e_team/presentation/widgets/cart/cart_footer.dart';
import 'package:e_team/presentation/widgets/cart/cart_agent_item_card.dart';
import 'package:e_team/presentation/widgets/cart/cart_plan_item_card.dart';
import 'package:e_team/presentation/widgets/cart/cart_section_title.dart';
import 'package:flutter/material.dart';

class CartContent extends StatelessWidget {
  const CartContent({
    super.key,
    required this.cart,
    required this.isDark,
    required this.isProcessing,
    required this.onCheckout,
  });

  final CartProvider cart;
  final bool isDark;
  final bool isProcessing;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (cart.agents.isNotEmpty) ...[
                CartSectionTitle(title: 'Suggested Agents', isDark: isDark),
                const SizedBox(height: 12),
                ...cart.agents.map(
                  (item) => CartAgentItemCard(
                    item: item,
                    isDark: isDark,
                    onRemove: () => cart.removeFromCart(item.id),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (cart.plans.isNotEmpty) ...[
                CartSectionTitle(title: 'Selected Plan', isDark: isDark),
                const SizedBox(height: 12),
                ...cart.plans.map(
                  (item) => CartPlanItemCard(
                    item: item,
                    agentCount: cart.agents.length,
                    isDark: isDark,
                  ),
                ),
              ],
            ],
          ),
        ),
        CartCheckoutFooter(
          cart: cart,
          isDark: isDark,
          isProcessing: isProcessing,
          onCheckout: onCheckout,
        ),
      ],
    );
  }
}
