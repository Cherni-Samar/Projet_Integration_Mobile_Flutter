import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:e_team/data/models/user.dart';
import 'package:e_team/data/repositories/auth_repository.dart';
import 'package:e_team/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

const _testUser = User(
  id: 'u-1',
  email: 'test@example.com',
  isEmailVerified: true,
  subscriptionPlan: 'free',
  maxAgentsAllowed: 1,
  activeAgents: [],
  energyBalance: 0,
);

void main() {
  late MockAuthService mockService;
  late AuthRepository repository;

  setUp(() {
    mockService = MockAuthService();
    repository = AuthRepository(authService: mockService);
  });

  group('AuthRepository.login', () {
    test('returns User on successful login', () async {
      when(() => mockService.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => {'success': true, 'user': _testUser});

      final result = await repository.login(
        email: 'test@example.com',
        password: 'password',
      );

      expect(result, _testUser);
    });

    test('throws when service throws', () async {
      when(() => mockService.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Invalid credentials'));

      expect(
        () => repository.login(email: 'x', password: 'y'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('AuthRepository.isLoggedIn', () {
    test('returns true when token exists', () async {
      when(() => mockService.isLoggedIn()).thenAnswer((_) async => true);
      final result = await repository.isLoggedIn();
      expect(result, true);
    });

    test('returns false when no token', () async {
      when(() => mockService.isLoggedIn()).thenAnswer((_) async => false);
      final result = await repository.isLoggedIn();
      expect(result, false);
    });
  });

  group('AuthRepository.logout', () {
    test('calls service logout', () async {
      when(() => mockService.logout()).thenAnswer((_) async {});
      await repository.logout();
      verify(() => mockService.logout()).called(1);
    });
  });

  group('AuthRepository.getSavedUser', () {
    test('returns saved user', () async {
      when(() => mockService.getSavedUser()).thenAnswer((_) async => _testUser);
      final result = await repository.getSavedUser();
      expect(result, _testUser);
    });

    test('returns null when no saved user', () async {
      when(() => mockService.getSavedUser()).thenAnswer((_) async => null);
      final result = await repository.getSavedUser();
      expect(result, isNull);
    });
  });
}
