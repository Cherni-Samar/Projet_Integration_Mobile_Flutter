import 'package:e_team/presentation/widgets/common/app_loading.dart';
import 'package:flutter/material.dart';

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
                        child: AppLoadingIndicator(
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
