import 'package:flutter_test/flutter_test.dart';
import 'package:e_team/domain/models/payment_plan_model.dart';

void main() {
  group('domain/models/PaymentPlan', () {
    test('priceInCents rounds correctly', () {
      const plan = PaymentPlan(
        id: 'p1',
        title: 'Pro',
        price: 9.99,
        agentsAllowed: 3,
        energyCredits: 100,
        description: 'desc',
        displayLabel: 'PRO',
      );

      expect(plan.priceInCents, 999); // 9.99 * 100
    });

    test('formattedPrice formats with 0 decimals', () {
      const plan = PaymentPlan(
        id: 'p1',
        title: 'Pro',
        price: 9.99,
        agentsAllowed: 3,
        energyCredits: 100,
        description: 'desc',
        displayLabel: 'PRO',
      );

      expect(plan.formattedPrice, r'$10'); // toStringAsFixed(0) => 10
    });

    test('toMap contains expected keys and values', () {
      const plan = PaymentPlan(
        id: 'p2',
        title: 'Free',
        price: 0,
        agentsAllowed: 1,
        energyCredits: 10,
        description: 'free plan',
        displayLabel: 'FREE',
        isRecommended: true,
        isBestValue: false,
      );

      final map = plan.toMap();

      expect(map['id'], 'p2');
      expect(map['title'], 'Free');
      expect(map['price'], 0);
      expect(map['agentsAllowed'], 1);
      expect(map['energyCredits'], 10);
      expect(map['description'], 'free plan');
      expect(map['displayLabel'], 'FREE');
      expect(map['isRecommended'], true);
      expect(map['isBestValue'], false);

      // computed fields
      expect(map['priceInCents'], 0);
      expect(map['formattedPrice'], r'$0');
    });
  });
}
