import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/providers/cart_provider.dart';
import 'package:e_team/presentation/widgets/agent/agent_appbar_actions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AgentDetailsAppBar extends StatelessWidget {
  const AgentDetailsAppBar({
    super.key,
    required this.l10n,
    required this.isDark,
    required this.onBackPressed,
    required this.onCartPressed,
    required this.onSharePressed,
  });

  final AppLocalizations l10n;
  final bool isDark;
  final VoidCallback onBackPressed;
  final VoidCallback onCartPressed;
  final VoidCallback onSharePressed;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
      pinned: true,
      elevation: 0,
      leading: IconButton(
        onPressed: onBackPressed,
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
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
            size: 20,
          ),
        ),
      ),
      title: Text(
        l10n.agentDetailsTitle,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Consumer<CartProvider>(
          builder: (context, cart, child) {
            return AgentAppBarActions(
              cartItemCount: cart.itemCount,
              onCartPressed: onCartPressed,
              onSharePressed: onSharePressed,
              isDark: isDark,
            );
          },
        ),
      ],
    );
  }
}
