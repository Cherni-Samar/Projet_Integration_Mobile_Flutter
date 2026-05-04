import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_team/domain/models/agent_metadata_model.dart';

void main() {
  group('domain/models/AgentMetadata', () {
    test('getEnergyRangeDisplay uses min/max energy', () {
      const meta = AgentMetadata(
        id: '1',
        name: 'Hera',
        roleKey: 'agentRoleHrSpecialist',
        descriptionKey: 'agentDescAlpha',
        iconPath: 'assets/images/hera.png',
        color: Colors.black,
        stats: AgentStats(
          response: 'Fast',
          accuracy: '95%',
          languages: 'EN/FR',
        ),
        rating: 4.8,
        hires: '1.2k',
        priceLabel: '\$9',
        versionKey: 'v1',
        skillKeys: ['skill1', 'skill2'],
        energyTasks: [AgentEnergyTask(task: 'Reply', cost: 2)],
        multiScenarios: [
          AgentMultiScenario(scenario: 'HR', agents: 'Hera', cost: 3),
        ],
        energyPacks: [
          AgentEnergyPack(
            title: 'Pack',
            energy: 100,
            price: 9.9,
            color: 0xFF000000,
          ),
        ],
        minEnergy: 1,
        maxEnergy: 5,
      );

      expect(meta.getEnergyRangeDisplay(), '1–5 ⚡ per task');
    });

    test('toMap contains backward-compatibility keys', () {
      const meta = AgentMetadata(
        id: '1',
        name: 'Hera',
        roleKey: 'role',
        descriptionKey: 'desc',
        iconPath: 'icon',
        color: Colors.red,
        stats: AgentStats(response: 'Fast', accuracy: '95%', languages: 'EN'),
        rating: 4.2,
        hires: '200',
        priceLabel: '\$0',
        versionKey: 'v1',
        skillKeys: [],
        energyTasks: [],
        multiScenarios: [],
        energyPacks: [],
      );

      final map = meta.toMap();
      expect(map['name'], 'Hera');
      expect(map['icon'], 'icon');
      expect(map['stats'], {
        'response': 'Fast',
        'accuracy': '95%',
        'languages': 'EN',
      });
      expect(map['rating'], 4.2);
      expect(map['hires'], '200');
      expect(map['price'], '\$0');
    });

    test('toLocalizedMap includes role and description', () {
      const meta = AgentMetadata(
        id: '1',
        name: 'Hera',
        roleKey: 'roleKey',
        descriptionKey: 'descKey',
        iconPath: 'icon',
        color: Colors.blue,
        stats: AgentStats(response: 'Fast', accuracy: '95%', languages: 'EN'),
        rating: 4.2,
        hires: '200',
        priceLabel: '\$0',
        versionKey: 'v1',
        skillKeys: [],
        energyTasks: [],
        multiScenarios: [],
        energyPacks: [],
      );

      final map = meta.toLocalizedMap(
        role: 'HR Agent',
        description: 'Helps HR',
      );
      expect(map['role'], 'HR Agent');
      expect(map['description'], 'Helps HR');
    });
  });
}
