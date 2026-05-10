import 'package:e_team/presentation/widgets/common/app_loading.dart';
import 'package:flutter/material.dart';

import 'package:e_team/presentation/widgets/pricing/pricing_colors.dart';

class PricingPlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String creditsLabel;
  final String? agentsLabel;
  final bool isBestValue;
  final bool isDark;
  final bool isLoading;
  final VoidCallback? onTap;

  const PricingPlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.creditsLabel,
    required this.agentsLabel,
    required this.isBestValue,
    required this.isDark,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isBestValue
        ? PricingColors.volt.withValues(alpha: 0.55)
        : Colors.white.withValues(alpha: 0.12);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? PricingColors.cardBg : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 0.8),
            boxShadow: isBestValue
                ? [
                    BoxShadow(
                      color: PricingColors.volt.withValues(alpha: 0.18),
                      blurRadius: 22,
                      spreadRadius: 0.6,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    PricingPlanMetaLine(
                      creditsLabel: creditsLabel,
                      agentsLabel: agentsLabel,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: AppLoadingIndicator(
                    strokeWidth: 2.4,
                    color: PricingColors.volt,
                  ),
                )
              else
                Text(
                  price,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PricingPlanMetaLine extends StatelessWidget {
  final String creditsLabel;
  final String? agentsLabel;
  final bool isDark;

  const PricingPlanMetaLine({
    super.key,
    required this.creditsLabel,
    required this.agentsLabel,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : Colors.black.withValues(alpha: 0.65);

    final separatorColor = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : Colors.black.withValues(alpha: 0.35);
    final baseStyle = TextStyle(
      color: textColor,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.3,
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        Icon(
          Icons.bolt,
          size: 14,
          color: PricingColors.volt.withValues(alpha: isDark ? 0.85 : 0.9),
        ),
        Text(creditsLabel, style: baseStyle),
        if (agentsLabel != null) ...[
          Text('•', style: baseStyle.copyWith(color: separatorColor)),
          Text(agentsLabel!, style: baseStyle),
        ],
      ],
    );
  }
}
