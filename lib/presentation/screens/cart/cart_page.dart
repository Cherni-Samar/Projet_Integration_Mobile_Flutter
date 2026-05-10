import 'package:e_team/data/dtos/user_dto.dart';
import 'package:e_team/data/services/payment_plan_metadata_service.dart';
import 'package:e_team/data/services/stripe_service.dart';
import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/providers/cart_provider.dart';
import 'package:e_team/presentation/providers/owned_agents_provider.dart';
import 'package:e_team/presentation/providers/theme_provider.dart';
import 'package:e_team/presentation/providers/user_provider.dart';
import 'package:e_team/presentation/screens/agent/my_agents_page.dart';
import 'package:e_team/presentation/widgets/cart/cart_content.dart';
import 'package:e_team/presentation/widgets/cart/cart_states.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  final bool isOnboardingPayment;

  const CartPage({super.key, this.isOnboardingPayment = false});

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

      final suggestedAgents = cart.agents
          .map((item) => item.agentName.toLowerCase())
          .toList();

      final confirm = await StripeService.makePayment(
        packId: packId,
        suggestedAgents: suggestedAgents,
      );

      if (!mounted) return;

      if (confirm == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.paymentCancelledSnack),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (confirm['success'] == true) {
        final rawUser = confirm['data']?['user'] ?? confirm['user'];

        if (rawUser is Map<String, dynamic>) {
          final dto = UserDTO.fromJson(rawUser);
          await context.read<UserProvider>().setUser(dto);
        } else if (mounted) {
          await context.read<UserProvider>().refreshFromApi();
        }

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
            l10n.paymentFailedSnack(e.toString().replaceAll('Exception: ', '')),
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

  Future<void> _handleOnboardingPaymentSuccess(CartProvider cart) async {
    cart.clearCart();

    if (mounted) {
      await context.read<UserProvider>().refreshFromApi();
    }

    if (mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/agent-marketplace', (route) => false);

      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const MyAgentsPage()));
    }
  }

  void _showSuccessDialog(CartProvider cart) {
    final owned = context.read<OwnedAgentsProvider>();
    for (final item in cart.agents) {
      owned.addAgent(
        OwnedAgent(
          agentName: item.agentName,
          agentIllustration: item.agentIllustration,
          agentColorValue: item.agentColorValue,
          packTitle: item.packTitle,
          energy: item.energy,
          purchasedAt: DateTime.now(),
        ),
      );
    }

    owned.refreshEnergy();
    cart.clearCart();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 28,
              ),
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
              Navigator.of(dialogContext).pop();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/my-agents',
                (route) =>
                    route.settings.name == '/' ||
                    route.settings.name == '/splash',
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
    final cart = context.watch<CartProvider>();
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFFAFAFA),
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
              onPressed: () => _clearCart(cart),
            ),
        ],
      ),
      body: Stack(
        children: [
          cart.itemCount == 0
              ? CartEmptyState(
                  isDark: isDark,
                  onGoToMarketplace: () => Navigator.pop(context),
                )
              : CartContent(
                  cart: cart,
                  isDark: isDark,
                  isProcessing: _isProcessing,
                  onCheckout: () => _handleCheckout(cart),
                ),
          if (_isProcessing) const CartProcessingOverlay(),
        ],
      ),
    );
  }

  void _clearCart(CartProvider cart) {
    cart.clearCart();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cart cleared')));
  }
}
