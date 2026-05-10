import 'package:e_team/presentation/widgets/kash/kash_theme.dart';
import 'package:flutter/material.dart';

class KashDashboardHeader extends StatelessWidget {
  const KashDashboardHeader({
    super.key,
    required this.isDark,
    required this.energy,
    required this.pulseController,
    required this.glowController,
    required this.onBack,
  });

  final bool isDark;
  final int energy;
  final AnimationController pulseController;
  final AnimationController glowController;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: KP.card(isDark),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: KP.border(isDark)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.07),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: KP.text(isDark),
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedBuilder(
            animation: glowController,
            builder: (_, child) => Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: KP.primary.withValues(
                      alpha: 0.25 + 0.2 * glowController.value,
                    ),
                    blurRadius: 14 + 8 * glowController.value,
                  ),
                ],
              ),
              child: child,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: Image.asset(
                'assets/images/kash.png',
                width: 46,
                height: 46,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => CircleAvatar(
                  backgroundColor: KP.primary,
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kash Dashboard',
                  style: TextStyle(
                    color: KP.text(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: pulseController,
                      builder: (_, _) => Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: KP.primary.withValues(
                            alpha: 0.6 + 0.4 * pulseController.value,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'FINANCIAL MANAGEMENT',
                      style: TextStyle(
                        color: KP.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '⚡ $energy',
              style: TextStyle(
                color: KP.text(isDark),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
