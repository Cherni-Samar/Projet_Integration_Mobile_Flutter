import 'package:e_team/domain/models/dexo/dexo_onboarding_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatMessage', () {
    test('bot/user factories set correct type and text', () {
      final bot = ChatMessage.bot('hello');
      expect(bot.type, ChatMessageType.bot);
      expect(bot.text, 'hello');
      expect(bot.widget, isNull);

      final user = ChatMessage.user('hi');
      expect(user.type, ChatMessageType.user);
      expect(user.text, 'hi');
      expect(user.widget, isNull);
    });

    test('blueprint factory sets widget and type', () {
      final w = Container();
      final m = ChatMessage.blueprint(w);

      expect(m.type, ChatMessageType.blueprint);
      expect(m.widget, same(w));
      expect(m.text, ''); // default value
    });
  });

  group('RecommendedAgent', () {
    test('fromJson lowercases id and handles missing fields', () {
      final a = RecommendedAgent.fromJson({
        'id': 'HERA',
        'name': 'Hera',
        'reason': 'HR',
      });

      expect(a.id, 'hera');
      expect(a.name, 'Hera');
      expect(a.reason, 'HR');

      final empty = RecommendedAgent.fromJson({});
      expect(empty.id, '');
      expect(empty.name, '');
      expect(empty.reason, '');
    });

    test('toJson outputs expected map', () {
      final a = RecommendedAgent(id: 'kash', name: 'Kash', reason: 'Finance');
      expect(a.toJson(), {'id': 'kash', 'name': 'Kash', 'reason': 'Finance'});
    });
  });

  group('WorkforceDepartment', () {
    test('fromJson supports name/department and parses targetCount', () {
      final d1 = WorkforceDepartment.fromJson({
        'name': 'Marketing',
        'targetCount': '3',
        'reason': 'Grow',
      });
      expect(d1.name, 'Marketing');
      expect(d1.targetCount, 3);
      expect(d1.reason, 'Grow');

      final d2 = WorkforceDepartment.fromJson({
        'department': 'IT',
        'count': 2,
        'reason': 'Build',
      });
      expect(d2.name, 'IT');
      expect(d2.targetCount, 2);

      final d3 = WorkforceDepartment.fromJson({
        'department': 'Ops',
        // missing targetCount/count/employees => fallback(1)
      });
      expect(d3.targetCount, 1);
    });

    test('toJson uses department + currentCount=0', () {
      final d = WorkforceDepartment(name: 'Ops', targetCount: 5, reason: 'Run');
      expect(d.toJson(), {
        'department': 'Ops',
        'targetCount': 5,
        'currentCount': 0,
        'reason': 'Run',
      });
    });
  });

  group('WorkforcePlan', () {
    test('fromJson reads proposal.departments and filters empty names', () {
      final plan = WorkforcePlan.fromJson({
        'proposal': {
          'departments': [
            {'name': 'Sales', 'targetCount': 2, 'reason': 'Sell'},
            {'name': '   ', 'targetCount': 99, 'reason': 'Should be removed'},
          ],
          'explanation': 'Custom explanation',
          'recommendedAgents': [
            {'id': 'DEXO', 'name': 'Dexo', 'reason': 'Docs'},
          ],
        },
      });

      expect(plan.departments.length, 1);
      expect(plan.departments.first.name, 'Sales');
      expect(plan.explanation, 'Custom explanation');
      expect(plan.recommendedAgents.length, 1);
      expect(plan.recommendedAgents.first.id, 'dexo');
    });

    test(
      'fromJson uses default departments when departments list missing/empty',
      () {
        final plan = WorkforcePlan.fromJson({});
        expect(plan.departments.length, 3);
        expect(plan.departments.map((d) => d.name), contains('Operations'));
        expect(plan.explanation.isNotEmpty, true);
      },
    );

    test('toApiList outputs list of departments json', () {
      final plan = WorkforcePlan(
        departments: [
          WorkforceDepartment(name: 'IT', targetCount: 2, reason: 'Build'),
        ],
        explanation: 'x',
        recommendedAgents: const [],
      );

      expect(plan.toApiList(), [
        {
          'department': 'IT',
          'targetCount': 2,
          'currentCount': 0,
          'reason': 'Build',
        },
      ]);
    });
  });

  group('StrategicAdviceResult', () {
    test('fromJson maps fields and builds WorkforcePlan', () {
      final r = StrategicAdviceResult.fromJson({
        'isFinished': true,
        'nextQuestion': 'Budget?',
        'proposal': {
          'departments': [
            {'name': 'Ops', 'targetCount': 2, 'reason': 'Run ops'},
          ],
          'recommendedAgents': [
            {'id': 'ECHO', 'name': 'Echo', 'reason': 'Comms'},
          ],
        },
      });

      expect(r.isFinished, true);
      expect(r.nextQuestion, 'Budget?');
      expect(r.plan.departments.length, 1);
      expect(r.plan.departments.first.name, 'Ops');
      expect(r.plan.recommendedAgents.first.id, 'echo');
    });
  });
}
