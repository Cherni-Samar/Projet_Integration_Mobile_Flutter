import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:e_team/blocs/user/user_bloc.dart';
import 'package:e_team/blocs/user/user_event.dart';
import 'package:e_team/blocs/user/user_state.dart';
import 'package:e_team/data/models/user.dart';
import 'package:e_team/domain/repositories/i_user_repository.dart';

class MockUserRepository extends Mock implements IUserRepository {}

const _testUser = User(
  id: 'u-42',
  name: 'Jane',
  email: 'jane@example.com',
  isEmailVerified: true,
  subscriptionPlan: 'premium',
  maxAgentsAllowed: 5,
  activeAgents: ['hera'],
  energyBalance: 500,
);

const _updatedUser = User(
  id: 'u-42',
  name: 'Jane Updated',
  email: 'jane@example.com',
  isEmailVerified: true,
  subscriptionPlan: 'premium',
  maxAgentsAllowed: 5,
  activeAgents: ['hera'],
  energyBalance: 500,
);

void main() {
  late MockUserRepository mockRepo;

  setUp(() {
    mockRepo = MockUserRepository();
  });

  group('UserBloc — UserRefreshRequested', () {
    blocTest<UserBloc, UserState>(
      'emits UserLoaded when getMe returns user',
      build: () {
        when(() => mockRepo.getMe()).thenAnswer((_) async => _testUser);
        return UserBloc(userRepository: mockRepo);
      },
      act: (bloc) => bloc.add(const UserRefreshRequested()),
      expect: () => [
        const UserLoading(),
        const UserLoaded(_testUser),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits UserError when getMe returns null',
      build: () {
        when(() => mockRepo.getMe()).thenAnswer((_) async => null);
        return UserBloc(userRepository: mockRepo);
      },
      act: (bloc) => bloc.add(const UserRefreshRequested()),
      expect: () => [
        const UserLoading(),
        isA<UserError>(),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits UserError on exception',
      build: () {
        when(() => mockRepo.getMe()).thenThrow(Exception('Network error'));
        return UserBloc(userRepository: mockRepo);
      },
      act: (bloc) => bloc.add(const UserRefreshRequested()),
      expect: () => [
        const UserLoading(),
        isA<UserError>().having((e) => e.message, 'message', contains('Network error')),
      ],
    );
  });

  group('UserBloc — UserUpdateRequested', () {
    blocTest<UserBloc, UserState>(
      'emits UserLoaded with updated user on success',
      build: () {
        when(() => mockRepo.updateProfile(
              name: any(named: 'name'),
              email: any(named: 'email'),
              currentPassword: any(named: 'currentPassword'),
              newPassword: any(named: 'newPassword'),
            )).thenAnswer((_) async => _updatedUser);
        return UserBloc(userRepository: mockRepo);
      },
      act: (bloc) => bloc.add(
        const UserUpdateRequested(name: 'Jane Updated'),
      ),
      expect: () => [
        const UserLoading(),
        const UserLoaded(_updatedUser),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits UserError when updateProfile throws',
      build: () {
        when(() => mockRepo.updateProfile(
              name: any(named: 'name'),
              email: any(named: 'email'),
              currentPassword: any(named: 'currentPassword'),
              newPassword: any(named: 'newPassword'),
            )).thenThrow(Exception('Failed to update profile'));
        return UserBloc(userRepository: mockRepo);
      },
      act: (bloc) => bloc.add(
        const UserUpdateRequested(name: 'Bad Name'),
      ),
      expect: () => [
        const UserLoading(),
        isA<UserError>(),
      ],
    );
  });
}
