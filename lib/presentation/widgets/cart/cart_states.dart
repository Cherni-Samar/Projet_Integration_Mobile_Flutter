import 'package:e_team/presentation/widgets/cart/cart_theme.dart';
import 'package:flutter/material.dart';

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
