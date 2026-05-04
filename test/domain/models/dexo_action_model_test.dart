import 'package:flutter_test/flutter_test.dart';
import 'package:e_team/domain/models/dexo_action_model.dart';

void main() {
  group('domain/models/DexoAction', () {
    test('can be constructed and exposes fields', () {
      final action = DexoAction(
        id: 'a1',
        title: 'Classify document',
        subtitle: 'Invoice.pdf',
        time: '10:30',
        type: 'classification',
      );

      expect(action.id, 'a1');
      expect(action.title, 'Classify document');
      expect(action.subtitle, 'Invoice.pdf');
      expect(action.time, '10:30');
      expect(action.type, 'classification');
    });
  });
}
