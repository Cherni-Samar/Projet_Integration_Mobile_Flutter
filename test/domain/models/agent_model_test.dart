import 'package:flutter_test/flutter_test.dart';
import 'package:e_team/domain/models/agent_model.dart';

void main() {
  group('domain/models/Agent', () {
    test('can be constructed with all required fields', () {
      final agent = Agent(
        title: 'Human Resources Agent',
        shortTitle: 'Hera',
        color: 0xFF000000,
        illustration: 'assets/images/hera.png',
        description: const ['Line 1', 'Line 2'],
        benefits: const ['Benefit 1'],
        detailedFeatures: const ['Feature 1', 'Feature 2'],
        timesSaved: '3h/week',
        stats: const {'accuracy': 0.95, 'responses': 'fast'},
        price: '\$9',
        name: 'hera',
        category: 'hr',
        isActive: true,
      );

      expect(agent.title, 'Human Resources Agent');
      expect(agent.shortTitle, 'Hera');
      expect(agent.color, 0xFF000000);
      expect(agent.illustration, 'assets/images/hera.png');
      expect(agent.description, ['Line 1', 'Line 2']);
      expect(agent.benefits, ['Benefit 1']);
      expect(agent.detailedFeatures, ['Feature 1', 'Feature 2']);
      expect(agent.timesSaved, '3h/week');
      expect(agent.stats['accuracy'], 0.95);
      expect(agent.price, '\$9');

      // champs “métier”
      expect(agent.name, 'hera');
      expect(agent.category, 'hr');
      expect(agent.isActive, true);
    });
  });
}
