import 'package:flutter_test/flutter_test.dart';
import 'package:e_team/domain/models/kash/kash_reminder_model.dart';

void main() {
  group('domain/models/kash/KashReminder', () {
    test('isPaid true only when status == paid', () {
      final r1 = KashReminder(
        id: 'r1',
        title: 'Invoice',
        amount: 100,
        currency: 'USD',
        dueDate: DateTime.now(),
        status: 'paid',
        notes: '',
      );
      expect(r1.isPaid, true);

      final r2 = KashReminder(
        id: 'r2',
        title: 'Invoice',
        amount: 100,
        currency: 'USD',
        dueDate: DateTime.now(),
        status: 'unpaid',
        notes: '',
      );
      expect(r2.isPaid, false);
    });

    test('isOverdue true when not paid and dueDate is in the past', () {
      final r = KashReminder(
        id: 'r3',
        title: 'Invoice',
        amount: 100,
        currency: 'USD',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        status: 'unpaid',
        notes: '',
      );

      expect(r.isOverdue, true);
    });

    test('isOverdue false when paid even if dueDate is in the past', () {
      final r = KashReminder(
        id: 'r4',
        title: 'Invoice',
        amount: 100,
        currency: 'USD',
        dueDate: DateTime.now().subtract(const Duration(days: 10)),
        status: 'paid',
        notes: '',
      );

      expect(r.isOverdue, false);
    });
  });
}
