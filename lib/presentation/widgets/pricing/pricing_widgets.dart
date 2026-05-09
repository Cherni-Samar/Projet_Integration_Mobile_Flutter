import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/models/pricing/pricing_offer.dart';

class PricingColors {
  static const cardBg = Color(0xFF1A1A1A);
  static const volt = Color(0xFFCDFF00);
}

class PricingOffersList extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isDark;
  final bool isProcessing;
  final String? processingPackId;
  final Map<String, List<PricingOffer>> sections;
  final String Function(String sectionId) sectionTitleText;
  final String Function(String packId) offerTitle;
  final ValueChanged<PricingOffer> onPurchase;

  const PricingOffersList({
    super.key,
    required this.l10n,
    required this.isDark,
    required this.isProcessing,
    required this.processingPackId,
    required this.sections,
    required this.sectionTitleText,
    required this.offerTitle,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final entry in sections.entries) ...[
          PricingSectionTitle(sectionTitleText(entry.key)),
          const SizedBox(height: 12),
          for (final offer in entry.value) ...[
            PricingPlanCard(
              title: offerTitle(offer.packId),
              price: offer.price,
              creditsLabel: l10n.pricingCreditsCount(offer.credits),
              agentsLabel: offer.agents != null
                  ? l10n.pricingAgentsCount(offer.agents!)
                  : null,
              isBestValue: offer.isBestValue,
              isDark: isDark,
              isLoading: isProcessing && processingPackId == offer.packId,
              onTap: isProcessing ? null : () => onPurchase(offer),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class PricingSectionTitle extends StatelessWidget {
  final String text;

  const PricingSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}

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
                  child: CircularProgressIndicator(
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

class PricingProcessingOverlay extends StatelessWidget {
  final bool isVisible;

  const PricingProcessingOverlay({super.key, required this.isVisible});

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Positioned.fill(
      child: IgnorePointer(
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.35),
          child: const Center(
            child: CircularProgressIndicator(color: PricingColors.volt),
          ),
        ),
      ),
    );
  }
}

class PricingSuccessDialog extends StatelessWidget {
  final AppLocalizations l10n;
  final String planName;

  const PricingSuccessDialog({
    super.key,
    required this.l10n,
    required this.planName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: PricingColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: PricingColors.volt.withValues(alpha: 0.18),
          width: 0.8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: PricingColors.volt.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: PricingColors.volt.withValues(alpha: 0.12),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: PricingColors.volt,
                size: 32,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.paymentConfirmedTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.paymentConfirmedSubtitle(planName),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PricingColors.volt,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                child: Text(
                  l10n.onboardingChatbotContinue,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
