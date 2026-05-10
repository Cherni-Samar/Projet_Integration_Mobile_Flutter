import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e_team/data/dtos/user_dto.dart';
import 'package:e_team/data/services/payment_plan_metadata_service.dart';
import 'package:e_team/data/services/stripe_service.dart';
import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/models/pricing/pricing_offer.dart';
import 'package:e_team/presentation/providers/user_provider.dart';
import 'package:e_team/presentation/widgets/common/app_snack_bar.dart';
import 'package:e_team/presentation/widgets/pricing/pricing_dialogs.dart';
import 'package:e_team/presentation/widgets/pricing/pricing_offers_list.dart';
import 'package:e_team/presentation/widgets/pricing/pricing_processing_overlay.dart';

class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  bool _isProcessing = false;
  String? _processingPackId;

  List<PricingOffer> _offers() {
    return PaymentPlanMetadataService.getPricingOffers().map((offerData) {
      return PricingOffer(
        sectionId: offerData['sectionId'],
        packId: offerData['packId'],
        price: offerData['price'],
        credits: offerData['credits'],
        agents: offerData['agents'] > 0 ? offerData['agents'] : null,
        isBestValue: offerData['isBestValue'],
      );
    }).toList();
  }

  String _offerTitle(AppLocalizations l10n, String packId) {
    return PaymentPlanMetadataService.getLocalizedTitle(l10n, packId);
  }

  String _sectionTitleText(AppLocalizations l10n, String sectionId) {
    switch (sectionId) {
      case PricingOfferSectionId.subscriptions:
        return l10n.pricingSectionSubscriptions;
      case PricingOfferSectionId.energyTopups:
        return l10n.pricingSectionEnergyTopups;
      default:
        return sectionId;
    }
  }

  Future<void> _handlePurchase(PricingOffer offer) async {
    if (_isProcessing) return;

    final l10n = AppLocalizations.of(context)!;

    // Free Trial is a special case (Stripe typically doesn't support 0€ intents)
    if (offer.packId == 'free_trial') {
      if (!mounted) return;
      AppSnackBar.info(context, l10n.pricingFreeTrialAlreadyAvailableSnack);
      return;
    }

    setState(() {
      _isProcessing = true;
      _processingPackId = offer.packId;
    });

    try {
      final confirm = await StripeService.makePayment(
        packId: offer.packId,
        suggestedAgents: null, // No suggested agents from this flow
      );
      if (!mounted) return;

      if (confirm == null) {
        // User cancelled the payment sheet
        AppSnackBar.warning(context, l10n.paymentCancelledSnack);
        return;
      }

      final rawUser = confirm['data']?['user'] ?? confirm['user'];
      if (rawUser is Map<String, dynamic>) {
        final dto = UserDTO.fromJson(rawUser);
        await context.read<UserProvider>().setUser(dto);
      } else {
        await context.read<UserProvider>().refreshFromApi();
      }

      await _showSuccessDialog(planName: _offerTitle(l10n, offer.packId));
      if (!mounted) return;

      // Return to Marketplace and allow it to refresh.
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _processingPackId = null;
        });
      }
    }
  }

  Future<void> _showSuccessDialog({required String planName}) async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (context) =>
          PricingSuccessDialog(l10n: l10n, planName: planName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final offers = _offers();

    final sections = <String, List<PricingOffer>>{};
    for (final o in offers) {
      sections.putIfAbsent(o.sectionId, () => <PricingOffer>[]).add(o);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pricingOffersTitle)),
      body: Stack(
        children: [
          PricingOffersList(
            l10n: l10n,
            isDark: isDark,
            isProcessing: _isProcessing,
            processingPackId: _processingPackId,
            sections: sections,
            sectionTitleText: (sectionId) => _sectionTitleText(l10n, sectionId),
            offerTitle: (packId) => _offerTitle(l10n, packId),
            onPurchase: _handlePurchase,
          ),
          PricingProcessingOverlay(isVisible: _isProcessing),
        ],
      ),
    );
  }
}
