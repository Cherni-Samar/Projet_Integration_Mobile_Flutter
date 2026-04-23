import 'package:flutter_test/flutter_test.dart';

import 'package:e_team/data/dtos/user_dto.dart';
import 'package:e_team/data/mappers/user_mapper.dart';
import 'package:e_team/data/models/user.dart';

void main() {
  group('UserMapper', () {
    final testDto = UserDto(
      id: 'user-123',
      name: 'Alice Dupont',
      email: 'alice@example.com',
      isEmailVerified: true,
      subscriptionPlan: 'premium',
      subscriptionStatus: 'active',
      maxAgentsAllowed: 5,
      activeAgents: const ['hera', 'kash'],
      energyBalance: 1000,
      createdAt: '2024-01-01T00:00:00.000Z',
      updatedAt: '2024-06-01T00:00:00.000Z',
    );

    test('fromDto maps all fields correctly', () {
      final user = UserMapper.fromDto(testDto);

      expect(user.id, 'user-123');
      expect(user.name, 'Alice Dupont');
      expect(user.email, 'alice@example.com');
      expect(user.isEmailVerified, true);
      expect(user.subscriptionPlan, 'premium');
      expect(user.subscriptionStatus, 'active');
      expect(user.maxAgentsAllowed, 5);
      expect(user.activeAgents, ['hera', 'kash']);
      expect(user.energyBalance, 1000);
      expect(user.createdAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
      expect(user.updatedAt, DateTime.parse('2024-06-01T00:00:00.000Z'));
    });

    test('toDto maps all fields correctly', () {
      final user = UserMapper.fromDto(testDto);
      final dto = UserMapper.toDto(user);

      expect(dto.id, testDto.id);
      expect(dto.name, testDto.name);
      expect(dto.email, testDto.email);
      expect(dto.isEmailVerified, testDto.isEmailVerified);
      expect(dto.subscriptionPlan, testDto.subscriptionPlan);
      expect(dto.subscriptionStatus, testDto.subscriptionStatus);
      expect(dto.maxAgentsAllowed, testDto.maxAgentsAllowed);
      expect(dto.activeAgents, testDto.activeAgents);
      expect(dto.energyBalance, testDto.energyBalance);
    });

    test('fromJson parses raw JSON correctly', () {
      final json = <String, dynamic>{
        'id': 'u-99',
        'name': 'Bob',
        'email': 'bob@example.com',
        'isEmailVerified': false,
        'subscriptionPlan': 'free',
        'maxAgentsAllowed': 1,
        'activeAgents': <String>[],
        'energyBalance': 0,
      };
      final user = UserMapper.fromJson(json);

      expect(user.id, 'u-99');
      expect(user.email, 'bob@example.com');
      expect(user.isEmailVerified, false);
      expect(user.subscriptionPlan, 'free');
      expect(user.activeAgents, isEmpty);
    });

    test('round-trip fromDto → toDto preserves data', () {
      final originalUser = UserMapper.fromDto(testDto);
      final backToDto = UserMapper.toDto(originalUser);
      final backToUser = UserMapper.fromDto(backToDto);

      expect(backToUser, originalUser);
    });

    test('User.fromJson convenience factory works', () {
      final json = <String, dynamic>{
        '_id': 'mongo-id',
        'email': 'test@test.com',
        'isEmailVerified': true,
        'subscriptionPlan': 'basic',
        'maxAgentsAllowed': 2,
        'activeAgents': ['dexo'],
        'energyBalance': 500,
      };
      final user = User.fromJson(json);
      expect(user.id, 'mongo-id');
      expect(user.email, 'test@test.com');
    });

    test('handles null optional fields gracefully', () {
      final dto = UserDto(
        id: 'u-1',
        email: 'x@x.com',
        isEmailVerified: false,
        subscriptionPlan: 'free',
        maxAgentsAllowed: 1,
        activeAgents: const [],
        energyBalance: 0,
      );
      final user = UserMapper.fromDto(dto);
      expect(user.name, isNull);
      expect(user.subscriptionStatus, isNull);
      expect(user.createdAt, isNull);
      expect(user.updatedAt, isNull);
    });
  });
}
