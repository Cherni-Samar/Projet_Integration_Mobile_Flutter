import 'package:e_team/domain/models/user_model.dart';
import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/providers/cart_provider.dart';
import 'package:e_team/presentation/utils/domain_model_color_extensions.dart';
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

class AgentMarketplaceTitle extends StatelessWidget {
  const AgentMarketplaceTitle({
    super.key,
    required this.isDark,
    required this.agentCount,
    required this.l10n,
  });

  final bool isDark;
  final int agentCount;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFCDFF00), Color(0xFFAADD00)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.agentMarketplaceTitle,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.touch_app,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.5),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.agentMarketplaceSwipeToExplore(agentCount),
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.5),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AgentMarketplaceInfo extends StatelessWidget {
  const AgentMarketplaceInfo({
    super.key,
    required this.agent,
    required this.isDark,
    required this.l10n,
  });

  final Map<String, dynamic> agent;
  final bool isDark;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(agent['name']),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            agent['description'],
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.75)
                  : Colors.black.withValues(alpha: 0.75),
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AgentStat(
                icon: Icons.flash_on,
                label: l10n.agentMarketplaceStatResponse,
                value: agent['stats']['response'],
                color: const Color(0xFFCDFF00),
                isDark: isDark,
              ),
              _AgentStat(
                icon: Icons.check_circle,
                label: l10n.agentMarketplaceStatAccuracy,
                value: agent['stats']['accuracy'],
                color: const Color(0xFFA855F7),
                isDark: isDark,
              ),
              _AgentStat(
                icon: Icons.language,
                label: l10n.agentMarketplaceStatLanguages,
                value: agent['stats']['languages'],
                color: colorFromValue(agent['color']),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AgentMarketplaceActions extends StatelessWidget {
  const AgentMarketplaceActions({
    super.key,
    required this.isDark,
    required this.isHiring,
    required this.isActive,
    required this.hasSlots,
    required this.canHire,
    required this.onNext,
    required this.onHire,
    required this.onUpgrade,
  });

  final bool isDark;
  final bool isHiring;
  final bool isActive;
  final bool hasSlots;
  final bool canHire;
  final VoidCallback onNext;
  final VoidCallback onHire;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final buttonFg = isDark ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _NextAgentButton(isDark: isDark, onPressed: onNext),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        colors: [Color(0xFFCDFF00), Color(0xFFAADD00)],
                      )
                    : const LinearGradient(
                        colors: [Colors.black, Color(0xFF1A1A1A)],
                      ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? const Color(0xFFCDFF00).withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: !canHire
                    ? null
                    : isActive
                    ? null
                    : hasSlots
                    ? onHire
                    : onUpgrade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: buttonFg,
                  disabledForegroundColor: buttonFg,
                  disabledBackgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isHiring)
                      SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: buttonFg,
                        ),
                      )
                    else ...[
                      Icon(
                        isActive
                            ? Icons.verified
                            : hasSlots
                            ? Icons.person_add_alt_1
                            : Icons.workspace_premium,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          isActive
                              ? 'Actif'
                              : hasSlots
                              ? 'Hire'
                              : 'Plan plein - Améliorer mon offre',
                          style: TextStyle(
                            color: buttonFg,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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

class _NextAgentButton extends StatelessWidget {
  const _NextAgentButton({required this.isDark, required this.onPressed});

  final bool isDark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          Icons.arrow_forward_ios,
          color: isDark
              ? Colors.white.withValues(alpha: 0.7)
              : Colors.black.withValues(alpha: 0.7),
          size: 20,
        ),
      ),
    );
  }
}

class _AgentStat extends StatelessWidget {
  const _AgentStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.05),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.black.withValues(alpha: 0.6),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w800,
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
