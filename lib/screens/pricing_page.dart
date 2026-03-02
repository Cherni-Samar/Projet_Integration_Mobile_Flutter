import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/stripe_service.dart';
import '../utils/constants.dart';

class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  State<PricingPage> createState() => _PricingPageState();

  static const cardBg = Color(0xFF1A1A1A);
  static const volt = Color(0xFFCDFF00);
}

class _PricingPageState extends State<PricingPage> {
  final _authService = AuthService();
  bool _isProcessing = false;
  String? _processingPackId;

  List<_Offer> _offers() {
    return const [
      _Offer(
        sectionId: _OfferSectionId.subscriptions,
        packId: 'free_trial',
        price: r'$0',
        credits: 50,
        agents: 1,
      ),
      _Offer(
        sectionId: _OfferSectionId.subscriptions,
        packId: 'basic_plan',
        price: r'$59',
        credits: 250,
        agents: 3,
      ),
      _Offer(
        sectionId: _OfferSectionId.subscriptions,
        packId: 'premium_plan',
        price: r'$99',
        credits: 500,
        agents: 5,
        isBestValue: true,
      ),
      _Offer(
        sectionId: _OfferSectionId.energyTopups,
        packId: 'energy_eco',
        price: r'$10',
        credits: 100,
      ),
      _Offer(
        sectionId: _OfferSectionId.energyTopups,
        packId: 'energy_boost',
        price: r'$35',
        credits: 500,
      ),
    ];
  }

  String _offerTitle(AppLocalizations l10n, String packId) {
    switch (packId) {
      case 'free_trial':
        return l10n.pricingOfferFreeTrial;
      case 'basic_plan':
        return l10n.pricingOfferBasicPlan;
      case 'premium_plan':
        return l10n.pricingOfferPremiumPlan;
      case 'energy_eco':
        return l10n.pricingOfferEcoPack;
      case 'energy_boost':
        return l10n.pricingOfferBoostPack;
      default:
        return packId;
    }
  }

  String _sectionTitleText(AppLocalizations l10n, String sectionId) {
    switch (sectionId) {
      case _OfferSectionId.subscriptions:
        return l10n.pricingSectionSubscriptions;
      case _OfferSectionId.energyTopups:
        return l10n.pricingSectionEnergyTopups;
      default:
        return sectionId;
    }
  }

  Future<void> _handlePurchase(_Offer offer) async {
    if (_isProcessing) return;

    final l10n = AppLocalizations.of(context)!;

    // Free Trial is a special case (Stripe typically doesn't support 0€ intents)
    if (offer.packId == 'free_trial') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pricingFreeTrialAlreadyAvailableSnack),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _processingPackId = offer.packId;
    });

    try {
      final paid = await StripeService.makePayment(packId: offer.packId);
      if (!mounted) return;

      if (!paid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.paymentCancelledSnack),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final paymentIntentId = StripeService.lastPaymentIntentId;
      if (paymentIntentId == null) {
        throw Exception(l10n.paymentMissingIntentId);
      }

      final token = await _authService.getToken();
      if (token == null) {
        throw Exception(l10n.authMustBeLoggedIn);
      }

      final confirm = await ApiService.post(
        endpoint: ApiConstants.confirmPayment,
        body: {'paymentIntentId': paymentIntentId},
        token: token,
      );

      final rawUser = confirm['data']?['user'] ?? confirm['user'];
      if (rawUser is Map<String, dynamic>) {
        await _authService.saveUser(User.fromJson(rawUser));
      } else {
        // Fallback: refresh /me so Marketplace sees latest limits
        await _authService.getMe();
      }

      await _showSuccessDialog(planName: _offerTitle(l10n, offer.packId));
      if (!mounted) return;

      // Return to Marketplace and allow it to refresh.
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
      builder: (ctx) {
        return Dialog(
          backgroundColor: PricingPage.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: PricingPage.volt.withValues(alpha: 0.18),
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
                    color: PricingPage.volt.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: PricingPage.volt.withValues(alpha: 0.12),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: PricingPage.volt,
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
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PricingPage.volt,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.onboardingChatbotContinue,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final offers = _offers();

    final sections = <String, List<_Offer>>{};
    for (final o in offers) {
      sections.putIfAbsent(o.sectionId, () => <_Offer>[]).add(o);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pricingOffersTitle),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final entry in sections.entries) ...[
                _sectionTitle(_sectionTitleText(l10n, entry.key)),
                const SizedBox(height: 12),
                for (final offer in entry.value) ...[
                  _planCard(
                    context,
                    title: _offerTitle(l10n, offer.packId),
                    price: offer.price,
                    credits: offer.credits,
                    creditsLabel: l10n.pricingCreditsCount(offer.credits),
                    agents: offer.agents,
                    agentsLabel: offer.agents != null
                        ? l10n.pricingAgentsCount(offer.agents!)
                        : null,
                    isBestValue: offer.isBestValue,
                    isDark: isDark,
                    isLoading:
                        _isProcessing && _processingPackId == offer.packId,
                    onTap:
                        _isProcessing ? null : () => _handlePurchase(offer),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 8),
              ],
            ],
          ),
          if (_isProcessing)
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFCDFF00),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static Widget _planCard(
    BuildContext context, {
    required String title,
    required String price,
    required int credits,
    required String creditsLabel,
    int? agents,
    required String? agentsLabel,
    bool isBestValue = false,
    required bool isDark,
    required bool isLoading,
    required VoidCallback? onTap,
  }) {
    final borderColor = isBestValue
        ? PricingPage.volt.withValues(alpha: 0.55)
        : Colors.white.withValues(alpha: 0.12);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PricingPage.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: 0.8,
            ),
            boxShadow: isBestValue
                ? [
                    BoxShadow(
                      color: PricingPage.volt.withValues(alpha: 0.18),
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _planMetaLine(
                      creditsLabel: creditsLabel,
                      agentsLabel: agentsLabel,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (isLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: PricingPage.volt,
                  ),
                )
              else
                Text(
                  price,
                  style: const TextStyle(
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

  static Widget _planMetaLine({
    required String creditsLabel,
    required String? agentsLabel,
    required bool isDark,
  }) {
    final textColor = Colors.white.withValues(alpha: 0.7);
    final separatorColor = Colors.white.withValues(alpha: 0.45);

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
          color: PricingPage.volt.withValues(alpha: isDark ? 0.85 : 0.9),
        ),
        Text(creditsLabel, style: baseStyle),
        if (agentsLabel != null) ...[
          Text('•', style: baseStyle.copyWith(color: separatorColor)),
          Text(agentsLabel, style: baseStyle),
        ],
      ],
    );
  }
}

class _Offer {
  final String sectionId;
  final String packId;
  final String price;
  final int credits;
  final int? agents;
  final bool isBestValue;

  const _Offer({
    required this.sectionId,
    required this.packId,
    required this.price,
    required this.credits,
    this.agents,
    this.isBestValue = false,
  });
}

class _OfferSectionId {
  static const subscriptions = 'subscriptions';
  static const energyTopups = 'energy_topups';
}
