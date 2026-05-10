import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/widgets/pricing/pricing_colors.dart';

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
