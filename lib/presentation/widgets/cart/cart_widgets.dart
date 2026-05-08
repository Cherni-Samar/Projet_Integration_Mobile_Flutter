import 'package:e_team/presentation/providers/cart_provider.dart';
import 'package:e_team/presentation/utils/domain_model_color_extensions.dart';
import 'package:flutter/material.dart';

class CartTheme {
  const CartTheme._();

  static const volt = Color(0xFFCDFF00);
}

class CartEmptyState extends StatelessWidget {
  const CartEmptyState({
    super.key,
    required this.isDark,
    required this.onGoToMarketplace,
  });

  final bool isDark;
  final VoidCallback onGoToMarketplace;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bolt_outlined,
            size: 80,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No agents yet',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Visit an agent to buy an energy pack',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onGoToMarketplace,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? CartTheme.volt : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Go to Marketplace'),
          ),
        ],
      ),
    );
  }
}

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

class CartCheckoutFooter extends StatelessWidget {
  const CartCheckoutFooter({
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          _FooterValueRow(
            label: 'Total Energy',
            value: formatCartEnergy(cart.totalEnergy),
            icon: Icons.bolt,
            valueColor: const Color(0xFFF59E0B),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _PriceRow(totalPrice: cart.totalPrice, isDark: isDark),
          const SizedBox(height: 16),
          const _SecureStripeBadge(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isProcessing ? null : onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? CartTheme.volt : Colors.black,
                foregroundColor: isDark ? Colors.black : Colors.white,
                disabledBackgroundColor: isDark
                    ? CartTheme.volt.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isProcessing
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: isDark ? Colors.black : Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.credit_card, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Pay with Stripe',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartProcessingOverlay extends StatelessWidget {
  const CartProcessingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.35),
          child: const Center(
            child: CircularProgressIndicator(color: CartTheme.volt),
          ),
        ),
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

class _FooterValueRow extends StatelessWidget {
  const _FooterValueRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.valueColor,
    required this.isDark,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color valueColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: valueColor, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.totalPrice, required this.isDark});

  final double totalPrice;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Text(
          '\$${totalPrice.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? CartTheme.volt : Colors.black,
          ),
        ),
      ],
    );
  }
}

class _SecureStripeBadge extends StatelessWidget {
  const _SecureStripeBadge();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Text(
          'Secured by Stripe',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
      ],
    );
  }
}

String formatCartEnergy(int n) {
  if (n >= 1000) {
    return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
  }
  return n.toString();
}
