import 'package:flutter_test/flutter_test.dart';

import 'package:e_team/data/dtos/agent_dto.dart';
import 'package:e_team/data/mappers/agent_mapper.dart';
import 'package:e_team/data/models/agent.dart';

void main() {
  group('AgentMapper', () {
    final testDto = AgentDto(
      id: 'agent-1',
      name: 'hera',
      displayName: 'Hera',
      description: 'HR agent',
      avatar: 'assets/images/hera.png',
      energy: 150,
      maxEnergy: 200,
      energyPercentage: 75,
      status: 'active',
      readyStatus: 'ready',
      specialties: const ['hr', 'onboarding'],
      isReady: true,
      stats: const AgentStatsDto(
        tasksCompleted: 10,
        energyUsed: 50,
        uptime: 99.5,
      ),
      lastActivity: '2024-06-01T12:00:00.000Z',
    );

    test('fromDto maps all fields correctly', () {
      final agent = AgentMapper.fromDto(testDto);

      expect(agent.id, 'agent-1');
      expect(agent.name, 'hera');
      expect(agent.displayName, 'Hera');
      expect(agent.description, 'HR agent');
      expect(agent.avatar, 'assets/images/hera.png');
      expect(agent.energy, 150);
      expect(agent.maxEnergy, 200);
      expect(agent.energyPercentage, 75);
      expect(agent.status, 'active');
      expect(agent.readyStatus, 'ready');
      expect(agent.specialties, ['hr', 'onboarding']);
      expect(agent.isReady, true);
      expect(agent.stats, isNotNull);
      expect(agent.stats!.tasksCompleted, 10);
      expect(agent.stats!.uptime, 99.5);
      expect(agent.lastActivity, DateTime.parse('2024-06-01T12:00:00.000Z'));
    });

    test('computed properties are correct', () {
      final agent = AgentMapper.fromDto(testDto);
      expect(agent.isActive, true);
      expect(agent.isOnline, true);
      expect(agent.hasEnergy, true);
      expect(agent.hasLowEnergy, false);
      expect(agent.statusColor, 'green');
    });

    test('toDto round-trip preserves data', () {
      final agent = AgentMapper.fromDto(testDto);
      final dto = AgentMapper.toDto(agent);
      final backToAgent = AgentMapper.fromDto(dto);

      expect(backToAgent, agent);
    });

    test('fromJson convenience factory works', () {
      final json = <String, dynamic>{
        'id': 'a-2',
        'name': 'kash',
        'displayName': 'Kash',
        'description': 'Finance agent',
        'energy': 0,
        'maxEnergy': 200,
        'energyPercentage': 0,
        'status': 'inactive',
        'readyStatus': 'offline',
        'specialties': <String>[],
        'isReady': false,
      };
      final agent = AgentMapper.fromJson(json);
      expect(agent.id, 'a-2');
      expect(agent.isActive, false);
      expect(agent.hasEnergy, false);
      expect(agent.statusColor, 'grey');
    });

    test('handles null stats', () {
      final dto = AgentDto(
        id: 'a-3',
        name: 'echo',
        displayName: 'Echo',
        description: 'Voice agent',
        energy: 10,
        maxEnergy: 200,
        energyPercentage: 5,
        status: 'active',
        readyStatus: 'ready',
        specialties: const [],
        isReady: true,
      );
      final agent = AgentMapper.fromDto(dto);
      expect(agent.stats, isNull);
      expect(agent.lastActivity, isNull);
      expect(agent.hasLowEnergy, true); // 10 < 20 (10% of 200)
      expect(agent.statusColor, 'orange');
    });
  });
}
