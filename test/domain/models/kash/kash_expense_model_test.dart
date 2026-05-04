import 'package:flutter_test/flutter_test.dart';
import 'package:e_team/domain/models/kash/kash_expense_model.dart';

void main() {
  group('domain/models/kash/KashExpense', () {
    test('constructs correctly', () {
      final e = KashExpense(
        id: 'ex1',
        amount: 49.5,
        currency: 'USD',
        vendor: 'Amazon',
        category: 'materials',
        description: 'Laptop stand',
        date: DateTime(2026, 5, 1),
      );

      expect(e.id, 'ex1');
      expect(e.amount, 49.5);
      expect(e.currency, 'USD');
      expect(e.vendor, 'Amazon');
      expect(e.category, 'materials');
      expect(e.description, 'Laptop stand');
      expect(e.date, DateTime(2026, 5, 1));
    });
  });
}
