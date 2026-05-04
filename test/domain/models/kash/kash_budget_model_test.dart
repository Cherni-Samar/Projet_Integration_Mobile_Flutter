import 'package:flutter_test/flutter_test.dart';
import 'package:e_team/domain/models/kash/kash_budget_model.dart';

void main() {
  group('domain/models/kash/KashBudget', () {
    test('remaining = limit - spent', () {
      final b = KashBudget(
        id: 'b1',
        category: 'travel',
        limit: 1000,
        spent: 250,
        currency: 'USD',
      );

      expect(b.remaining, 750);
    });

    test('usagePercent is 0 when limit is 0', () {
      final b = KashBudget(
        id: 'b2',
        category: 'travel',
        limit: 0,
        spent: 250,
        currency: 'USD',
      );

      expect(b.usagePercent, 0);
    });

    test('usagePercent clamps between 0 and 1', () {
      final over = KashBudget(
        id: 'b3',
        category: 'travel',
        limit: 100,
        spent: 250,
        currency: 'USD',
      );
      expect(over.usagePercent, 1);

      final under = KashBudget(
        id: 'b4',
        category: 'travel',
        limit: 100,
        spent: -50,
        currency: 'USD',
      );
      expect(under.usagePercent, 0);
    });
  });
}
