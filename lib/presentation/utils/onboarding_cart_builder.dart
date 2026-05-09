import 'package:flutter/material.dart';

import 'package:e_team/data/services/payment_plan_metadata_service.dart';
import 'package:e_team/domain/models/dexo/dexo_onboarding_models.dart';
import 'package:e_team/presentation/providers/cart_provider.dart';
import 'package:e_team/presentation/utils/domain_model_color_extensions.dart';

class OnboardingCartBuilder {
  static final Map<String, Map<String, dynamic>> _agentCatalog = {
    'hera': {
      'title': 'Hera',
      'illustration': 'assets/images/hera.png',
      'color': const Color(0xFF8B5CF6),
    },
    'echo': {
      'title': 'Echo',
      'illustration': 'assets/images/voxi.png',
      'color': const Color(0xFFA855F7),
    },
    'timo': {
      'title': 'Timo',
      'illustration': 'assets/images/krono.png',
      'color': const Color(0xFFEC4899),
    },
    'dexo': {
      'title': 'Dexo',
      'illustration': 'assets/images/dexo.png',
      'color': const Color(0xFF10B981),
    },
    'kash': {
      'title': 'Kash',
      'illustration': 'assets/images/kash.png',
      'color': const Color(0xFFF59E0B),
    },
  };

  const OnboardingCartBuilder._();

  static void addRecommendedAgentsToCart({
    required CartProvider cart,
    required List<RecommendedAgent> agents,
  }) {
    final planData = PaymentPlanMetadataService.getOnboardingPlanData(
      agents.length,
    );

    final packId = planData['packId'] as String;
    final packTitle = planData['packTitle'] as String;
    final energyCredits = planData['energyCredits'] as int;
    final price = planData['price'] as double;
    final agentsAllowed = planData['agentsAllowed'] as int;

    cart.setPaymentPack(packId);

    cart.addToCart(
      CartItem(
        id: 'plan-$packId',
        agentName: packTitle,
        agentIllustration: 'assets/images/plan_icon.png',
        agentColorValue: 0xFF6366F1,
        packTitle: 'Pack $agentsAllowed agents',
        energy: energyCredits,
        price: price,
        isPlan: true,
      ),
    );

    for (final agent in agents) {
      final key = agent.id.toLowerCase().trim();
      final data = _agentCatalog[key];

      if (data == null) continue;

      final agentName = data['title'] as String;

      cart.addToCart(
        CartItem(
          id: 'agent-$agentName',
          agentName: agentName,
          agentIllustration: data['illustration'] as String,
          agentColorValue: colorToValue(data['color'] as Color),
          packTitle: 'Included',
          energy: 0,
          price: 0.0,
          isPlan: false,
        ),
      );
    }
  }
}
