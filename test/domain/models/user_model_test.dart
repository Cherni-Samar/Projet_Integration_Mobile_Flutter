import 'package:flutter_test/flutter_test.dart';
import 'package:e_team/domain/models/user_model.dart';

void main() {
  group('domain/models/User', () {
    test('copyWith updates only selected fields and keeps others', () {
      final user = User(
        id: '1',
        name: 'Samar',
        email: 'samar@mail.com',
        isEmailVerified: true,
        onboardingCompleted: false,
        subscriptionPlan: 'free',
        subscriptionStatus: null,
        maxAgentsAllowed: 1,
        activeAgents: const ['hera'],
        energyBalance: 10,
        workforceSettings: [
          WorkforceSetting(department: 'IT', targetCount: 5, currentCount: 2),
        ],
        companyVision: 'Grow fast',
      );

      final updated = user.copyWith(
        onboardingCompleted: true,
        energyBalance: 50,
        activeAgents: ['hera', 'kash'],
      );

      expect(updated.onboardingCompleted, true);
      expect(updated.energyBalance, 50);
      expect(updated.activeAgents, ['hera', 'kash']);

      // unchanged
      expect(updated.id, '1');
      expect(updated.email, 'samar@mail.com');
      expect(updated.subscriptionPlan, 'free');
      expect(updated.workforceSettings.first.department, 'IT');
      expect(updated.companyVision, 'Grow fast');
    });
  });
}
