import 'package:e_team/domain/models/user_model.dart';
import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/providers/cart_provider.dart';
import 'package:e_team/presentation/widgets/common/round_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AgentMarketplaceHeader extends StatelessWidget {
  const AgentMarketplaceHeader({
    super.key,
    required this.isDark,
    required this.currentUser,
    required this.animation,
    required this.l10n,
    required this.onProfileTap,
    required this.onCartTap,
    required this.onNotificationsTap,
  });

  final bool isDark;
  final User? currentUser;
  final Animation<double> animation;
  final AppLocalizations l10n;
  final VoidCallback onProfileTap;
  final VoidCallback onCartTap;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: BoxDecoration(
            gradient: _headerGradient(isDark, animation.value),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onProfileTap,
                  child: _UserSummary(
                    isDark: isDark,
                    currentUser: currentUser,
                    l10n: l10n,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Consumer<CartProvider>(
                builder: (context, cart, child) {
                  return _HeaderIconWithDot(
                    isDark: isDark,
                    icon: Icons.shopping_cart_outlined,
                    showDot: cart.itemCount > 0,
                    dotColor: Colors.red,
                    onPressed: onCartTap,
                  );
                },
              ),
              const SizedBox(width: 8),
              _HeaderIconWithDot(
                isDark: isDark,
                icon: Icons.notifications_outlined,
                showDot: true,
                dotColor: const Color(0xFFCDFF00),
                useGradientDot: true,
                onPressed: onNotificationsTap,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UserSummary extends StatelessWidget {
  const _UserSummary({
    required this.isDark,
    required this.currentUser,
    required this.l10n,
  });

  final bool isDark;
  final User? currentUser;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFA855F7), Color(0xFF8B5CF6)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA855F7).withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isDark
                  ? const Color(0xFFCDFF00).withValues(alpha: 0.3)
                  : Colors.white,
              width: 2.5,
            ),
          ),
          child: Center(
            child: Text(
              _userInitial(currentUser),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.agentMarketplaceWelcomeBack,
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _userDisplayName(currentUser),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderIconWithDot extends StatelessWidget {
  const _HeaderIconWithDot({
    required this.isDark,
    required this.icon,
    required this.showDot,
    required this.dotColor,
    required this.onPressed,
    this.useGradientDot = false,
  });

  final bool isDark;
  final IconData icon;
  final bool showDot;
  final Color dotColor;
  final VoidCallback onPressed;
  final bool useGradientDot;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RoundIconButton(isDark: isDark, icon: icon, onPressed: onPressed),
        if (showDot)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: useGradientDot ? null : dotColor,
                gradient: useGradientDot
                    ? const LinearGradient(
                        colors: [Color(0xFFCDFF00), Color(0xFFAADD00)],
                      )
                    : null,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: dotColor.withValues(alpha: 0.8),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

String _userInitial(User? user) {
  final name = user?.name;
  if (name != null && name.isNotEmpty) return name[0].toUpperCase();
  final email = user?.email;
  if (email != null && email.isNotEmpty) return email[0].toUpperCase();
  return 'U';
}

String _userDisplayName(User? user) {
  final name = user?.name;
  if (name != null && name.isNotEmpty) return name;
  final email = user?.email;
  if (email != null && email.isNotEmpty) return email.split('@').first;
  return 'User';
}

LinearGradient _headerGradient(bool isDark, double animationValue) {
  if (isDark) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF1A1A1A),
        const Color(0xFF2D2D2D),
        Color.lerp(
          const Color(0xFF2D2D2D),
          const Color(0xFFCDFF00).withValues(alpha: 0.05),
          animationValue,
        )!,
      ],
    );
  }

  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white,
      const Color(0xFFFAFAFA),
      Color.lerp(
        const Color(0xFFFAFAFA),
        const Color(0xFFCDFF00).withValues(alpha: 0.03),
        animationValue,
      )!,
    ],
  );
}
