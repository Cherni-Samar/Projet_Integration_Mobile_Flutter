import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/owned_agents_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '/data/services/stripe_service.dart';
import '/data/services/payment_plan_metadata_service.dart';
import '/l10n/app_localizations.dart';
import 'package:e_team/data/dtos/user_dto.dart';
import '../agent/my_agents_page.dart';

class CartPage extends StatefulWidget {
  final bool isOnboardingPayment;
  
  const CartPage({Key? key, this.isOnboardingPayment = false}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isProcessing = false;

  String _packIdFromTotalPrice(double totalPrice) {
    final cents = (totalPrice * 100).round();
    return PaymentPlanMetadataService.getPlanIdFromCents(cents);
  }

  Future<void> _handleCheckout(CartProvider cart) async {
    if (_isProcessing) return;

    final l10n = AppLocalizations.of(context)!;

    if (cart.totalPrice == 0) {
      // Check if this is onboarding payment
      if (widget.isOnboardingPayment) {
        _handleOnboardingPaymentSuccess(cart);
      } else {
        _showSuccessDialog(cart);
      }
      return;
    }

    setState(() => _isProcessing = true);

    try {
      late final String packId;
      try {
        packId = _packIdFromTotalPrice(cart.totalPrice);
      } catch (_) {
        throw Exception(l10n.cartUnknownPackForTotal(cart.totalPrice));
      }

      // Extract suggested agents from cart
      final suggestedAgents = cart.agents.map((item) => item.agentName.toLowerCase()).toList();

      final confirm = await StripeService.makePayment(
        packId: packId,
        suggestedAgents: suggestedAgents,
      );

      if (!mounted) return;

      if (confirm == null) {
        // User cancelled the payment sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.paymentCancelledSnack),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (confirm['success'] == true) {
        // Best-effort local cache update (if backend returns user)
        final rawUser = confirm['data']?['user'] ?? confirm['user'];

        if (rawUser is Map<String, dynamic>) {
          final dto = UserDTO.fromJson(rawUser);
          await context.read<UserProvider>().setUser(dto);
        } else {
          if (mounted) {
            await context.read<UserProvider>().refreshFromApi();
          }
        }

        // Check if this is onboarding payment
        if (widget.isOnboardingPayment) {
          _handleOnboardingPaymentSuccess(cart);
        } else {
          _showSuccessDialog(cart);
        }
      } else {
        throw Exception('Payment confirmation failed');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.paymentFailedSnack(
              e.toString().replaceAll('Exception: ', ''),
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _handleOnboardingPaymentSuccess(CartProvider cart) async {
    // Clear cart
    cart.clearCart();
    
    // Refresh user data to get updated active agents
    if (mounted) {
      await context.read<UserProvider>().refreshFromApi();
    }
    
    // Navigate to dashboard first, then push My Agents on top
    if (mounted) {
      // First, navigate to agent marketplace (dashboard) and clear stack
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/agent-marketplace',
        (route) => false, // Clear all previous routes
      );
      
      // Then push My Agents page on top of dashboard
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const MyAgentsPage()),
      );
    }
  }

  void _showSuccessDialog(CartProvider cart) {
    // Transfer purchased agents to OwnedAgentsProvider
    final owned = Provider.of<OwnedAgentsProvider>(context, listen: false);
    for (final item in cart.agents) {
      owned.addAgent(OwnedAgent(
        agentName: item.agentName,
        agentIllustration: item.agentIllustration,
        agentColor: item.agentColor,
        packTitle: item.packTitle,
        energy: item.energy,
        purchasedAt: DateTime.now(),
      ));
    }
    // Refresh energy from API once after purchase — not on every rebuild.
    owned.refreshEnergy();
    cart.clearCart();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle,
                  color: Colors.green, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Success!', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: const Text(
          'Your energy has been credited! Your agents are ready to work. ⚡',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/my-agents',
                (route) => route.settings.name == '/' || route.settings.name == '/splash',
              );
            },
            child: const Text('Go to My Agents'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'Your Cart',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (cart.itemCount > 0)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                cart.clearCart();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cart cleared')));
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          cart.itemCount == 0
              ? Center(
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
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? const Color(0xFFCDFF00)
                              : Colors.black,
                          foregroundColor:
                              isDark ? Colors.black : Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Go to Marketplace'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Suggested Agents Section
                          if (cart.agents.isNotEmpty) ...[
                            Text(
                              'Suggested Agents',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...cart.agents.map((item) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E1E1E)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: item.agentColor.withOpacity(0.25),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: item.agentColor
                                        .withOpacity(isDark ? 0.1 : 0.06),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Agent avatar
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: item.agentColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.asset(
                                        item.agentIllustration,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.person,
                                          color: item.agentColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  // Agent name + pack info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.agentName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'Included',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            // Only show energy if agent has energy > 0
                                            if (item.energy > 0) ...[
                                              const SizedBox(width: 8),
                                              Icon(Icons.bolt,
                                                  color: item.agentColor,
                                                  size: 14),
                                              const SizedBox(width: 2),
                                              Text(
                                                '${_fmtEnergy(item.energy)}',
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.grey[400]
                                                      : Colors.grey[600],
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
                                  // Remove button
                                  GestureDetector(
                                    onTap: () => cart.removeFromCart(item.id),
                                    child: Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                            const SizedBox(height: 24),
                          ],
                          
                          // Selected Plan Section
                          if (cart.plans.isNotEmpty) ...[
                            Text(
                              'Selected Plan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...cart.plans.map((item) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E1E1E)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: item.agentColor.withOpacity(0.25),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: item.agentColor
                                        .withOpacity(isDark ? 0.1 : 0.06),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Plan icon
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: item.agentColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.workspace_premium,
                                      color: item.agentColor,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  // Plan details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.agentName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: item.agentColor
                                                    .withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'Pack ${cart.agents.length} agents',
                                                style: TextStyle(
                                                  color: item.agentColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(Icons.bolt,
                                                color: item.agentColor,
                                                size: 14),
                                            const SizedBox(width: 2),
                                            Text(
                                              '${_fmtEnergy(item.energy)} energy credits',
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600],
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Price
                                  Text(
                                    '\$${item.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: isDark
                                          ? const Color(0xFFCDFF00)
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ],
                        ],
                      ),
                    ),
                    // ── Checkout Footer ──
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Total energy
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.bolt,
                                      color: Color(0xFFF59E0B), size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Total Energy',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${_fmtEnergy(cart.totalEnergy)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Total price
                          Row(
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
                                '\$${cart.totalPrice.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? const Color(0xFFCDFF00)
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Secure badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_outline,
                                  size: 14, color: Colors.grey[500]),
                              const SizedBox(width: 6),
                              Text(
                                'Secured by Stripe',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isProcessing
                                  ? null
                                  : () => _handleCheckout(cart),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? const Color(0xFFCDFF00)
                                    : Colors.black,
                                foregroundColor:
                                    isDark ? Colors.black : Colors.white,
                                disabledBackgroundColor: isDark
                                    ? const Color(0xFFCDFF00).withOpacity(0.5)
                                    : Colors.black.withOpacity(0.5),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isProcessing
                                  ? SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color:
                                            isDark ? Colors.black : Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
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
                    ),
                  ],
                ),
          if (_isProcessing)
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFCDFF00),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _fmtEnergy(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    }
    return n.toString();
  }
}