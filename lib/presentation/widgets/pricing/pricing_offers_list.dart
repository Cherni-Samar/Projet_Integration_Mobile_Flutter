import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/models/pricing/pricing_offer.dart';
import 'package:e_team/presentation/widgets/pricing/pricing_plan_card.dart';

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
