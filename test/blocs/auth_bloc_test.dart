import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:e_team/blocs/auth/auth_bloc.dart';
import 'package:e_team/blocs/auth/auth_event.dart';
import 'package:e_team/blocs/auth/auth_state.dart';
import 'package:e_team/data/models/user.dart';
import 'package:e_team/domain/repositories/i_auth_repository.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

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
  late MockAuthRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(
      const User(
        id: '',
        email: '',
        isEmailVerified: false,
        subscriptionPlan: 'free',
        maxAgentsAllowed: 1,
        activeAgents: [],
        energyBalance: 0,
      ),
    );
  });

  setUp(() {
    mockRepo = MockAuthRepository();
  });

  group('AuthBloc — AuthCheckStatus', () {
    blocTest<AuthBloc, AuthState>(
      'emits AuthAuthenticated when saved user and fresh getMe succeed',
      build: () {
        when(() => mockRepo.getSavedUser()).thenAnswer((_) async => _testUser);
        when(() => mockRepo.getMe()).thenAnswer((_) async => _testUser);
        return AuthBloc(authRepository: mockRepo);
      },
      act: (bloc) => bloc.add(const AuthCheckStatus()),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(_testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthUnauthenticated when no saved user',
      build: () {
        when(() => mockRepo.getSavedUser()).thenAnswer((_) async => null);
        return AuthBloc(authRepository: mockRepo);
      },
      act: (bloc) => bloc.add(const AuthCheckStatus()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });

  group('AuthBloc — AuthLoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits AuthAuthenticated on successful login',
      build: () {
        when(() => mockRepo.login(email: any(named: 'email'), password: any(named: 'password')))
            .thenAnswer((_) async => _testUser);
        return AuthBloc(authRepository: mockRepo);
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(email: 'test@example.com', password: 'pass123'),
      ),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(_testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthError on login failure',
      build: () {
        when(() => mockRepo.login(email: any(named: 'email'), password: any(named: 'password')))
            .thenThrow(Exception('Invalid credentials'));
        return AuthBloc(authRepository: mockRepo);
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(email: 'bad@example.com', password: 'wrong'),
      ),
      expect: () => [
        const AuthLoading(),
        isA<AuthError>().having((e) => e.message, 'message', contains('Invalid credentials')),
      ],
    );
  });

  group('AuthBloc — AuthSignupRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits AuthEmailVerificationRequired on successful signup',
      build: () {
        when(() => mockRepo.signup(
              email: any(named: 'email'),
              password: any(named: 'password'),
              name: any(named: 'name'),
            )).thenAnswer((_) async => _testUser);
        return AuthBloc(authRepository: mockRepo);
      },
      act: (bloc) => bloc.add(
        const AuthSignupRequested(
          email: 'new@example.com',
          password: 'pass123',
          name: 'New User',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthEmailVerificationRequired('new@example.com'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthError on signup failure',
      build: () {
        when(() => mockRepo.signup(
              email: any(named: 'email'),
              password: any(named: 'password'),
              name: any(named: 'name'),
            )).thenThrow(Exception('Email already exists'));
        return AuthBloc(authRepository: mockRepo);
      },
      act: (bloc) => bloc.add(
        const AuthSignupRequested(
          email: 'existing@example.com',
          password: 'pass',
          name: 'User',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        isA<AuthError>().having((e) => e.message, 'message', contains('Email already exists')),
      ],
    );
  });

  group('AuthBloc — AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits AuthUnauthenticated after logout',
      build: () {
        when(() => mockRepo.logout()).thenAnswer((_) async {});
        return AuthBloc(authRepository: mockRepo);
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });
}
