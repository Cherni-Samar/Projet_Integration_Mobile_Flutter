import 'package:e_team/domain/models/payment_plan_model.dart';
import 'package:e_team/l10n/app_localizations.dart';

class PaymentPlanMetadataService {
  static const List<PaymentPlan> _plans = [
    PaymentPlan(
      id: 'free_trial',
      title: 'Free Trial',
      price: 0.0,
      agentsAllowed: 1,
      energyCredits: 50,
      description: 'Try the platform for free',
      displayLabel: 'Free Trial',
      isRecommended: false,
      isBestValue: false,
    ),
    PaymentPlan(
      id: 'basic_plan',
      title: 'Basic Plan',
      price: 59.0,
      agentsAllowed: 3,
      energyCredits: 250,
      description: 'Perfect for small teams',
      displayLabel: 'Pack 3 agents',
      isRecommended: false,
      isBestValue: false,
    ),
    PaymentPlan(
      id: 'premium_plan',
      title: 'Premium Plan',
      price: 99.0,
      agentsAllowed: 5,
      energyCredits: 500,
      description: 'Best for growing teams',
      displayLabel: 'Pack 5 agents',
      isRecommended: true,
      isBestValue: true,
    ),
    PaymentPlan(
      id: 'energy_eco',
      title: 'Eco Pack',
      price: 10.0,
      agentsAllowed: 0, // Energy-only pack
      energyCredits: 100,
      description: 'Small energy boost',
      displayLabel: 'Energy Top-up',
      isRecommended: false,
      isBestValue: false,
    ),
    PaymentPlan(
      id: 'energy_boost',
      title: 'Boost Pack',
      price: 35.0,
      agentsAllowed: 0, // Energy-only topup, no agent limit change
      energyCredits: 500,
      description: 'Large energy boost',
      displayLabel: 'Pack Boost',
      isRecommended: false,
      isBestValue: false,
    ),
  ];

  /// Get all available plans
  static List<PaymentPlan> getAllPlans() {
    return List.unmodifiable(_plans);
  }

  /// Get plan by ID with safe fallback
  static PaymentPlan getPlanById(String id) {
    try {
      return _plans.firstWhere((plan) => plan.id == id);
    } catch (e) {
      // Safe fallback to basic_plan if unknown ID
      print('⚠️ Unknown plan ID: $id, falling back to basic_plan');
      return _plans.firstWhere((plan) => plan.id == 'basic_plan');
    }
  }

  /// Get subscription plans only (excludes energy-only packs)
  static List<PaymentPlan> getSubscriptionPlans() {
    return _plans.where((plan) => plan.agentsAllowed > 0 && 
                                  (plan.id == 'basic_plan' || plan.id == 'premium_plan')).toList();
  }

  /// Get energy top-up plans only
  static List<PaymentPlan> getEnergyTopupPlans() {
    return _plans.where((plan) => plan.id == 'energy_eco' || plan.id == 'energy_boost').toList();
  }

  /// Get recommended plan for number of agents
  static PaymentPlan getRecommendedPlanForAgents(int agentCount) {
    if (agentCount >= 4) {
      return getPlanById('premium_plan');
    } else if (agentCount >= 2) {
      return getPlanById('basic_plan');
    } else {
      // For single agent, use basic_plan (minimum subscription)
      // energy_boost is energy-only topup, not suitable for agent onboarding
      return getPlanById('basic_plan');
    }
  }

  /// Get plan ID from price in cents (for cart_page.dart compatibility)
  static String getPlanIdFromCents(int cents) {
    try {
      final plan = _plans.firstWhere((plan) => plan.priceInCents == cents);
      return plan.id;
    } catch (e) {
      throw Exception('Unknown price: ${cents / 100}');
    }
  }

  /// Get localized plan title
  static String getLocalizedTitle(AppLocalizations l10n, String planId) {
    switch (planId) {
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
        final plan = getPlanById(planId);
        return plan.title;
    }
  }

  /// Create pricing page offers for backward compatibility
  static List<Map<String, dynamic>> getPricingOffers() {
    return [
      // Free trial
      {
        'sectionId': 'subscriptions',
        'packId': 'free_trial',
        'price': r'$0',
        'credits': 50,
        'agents': 1,
        'isBestValue': false,
      },
      // Subscription plans
      {
        'sectionId': 'subscriptions',
        'packId': 'basic_plan',
        'price': r'$59',
        'credits': 250,
        'agents': 3,
        'isBestValue': false,
      },
      {
        'sectionId': 'subscriptions',
        'packId': 'premium_plan',
        'price': r'$99',
        'credits': 500,
        'agents': 5,
        'isBestValue': true,
      },
      // Energy top-ups
      {
        'sectionId': 'energyTopups',
        'packId': 'energy_eco',
        'price': r'$10',
        'credits': 100,
        'agents': 0,
        'isBestValue': false,
      },
      {
        'sectionId': 'energyTopups',
        'packId': 'energy_boost',
        'price': r'$35',
        'credits': 500,
        'agents': 0,
        'isBestValue': false,
      },
    ];
  }

  /// Get plan data for onboarding (backward compatibility)
  static Map<String, dynamic> getOnboardingPlanData(int agentCount) {
    final plan = getRecommendedPlanForAgents(agentCount);
    return {
      'packId': plan.id,
      'packTitle': plan.title,
      'energyCredits': plan.energyCredits,
      'price': plan.price,
      'agentsAllowed': plan.agentsAllowed,
    };
  }
}