import 'package:e_team/presentation/providers/cart_provider.dart';
import 'package:e_team/presentation/widgets/cart/cart_helpers.dart';
import 'package:e_team/presentation/widgets/cart/cart_theme.dart';
import 'package:flutter/material.dart';

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
