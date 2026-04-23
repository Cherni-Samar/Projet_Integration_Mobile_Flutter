import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/i_user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final IUserRepository _userRepository;

  UserBloc({required IUserRepository userRepository})
      : _userRepository = userRepository,
        super(const UserInitial()) {
    on<UserRefreshRequested>(_onRefresh);
    on<UserUpdateRequested>(_onUpdate);
  }

  Future<void> _onRefresh(
    UserRefreshRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    try {
      final user = await _userRepository.getMe();
      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(const UserError('Unable to load user data'));
      }
    } catch (e) {
      emit(UserError(_extractMessage(e)));
    }
  }

  Future<void> _onUpdate(
    UserUpdateRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    try {
      final user = await _userRepository.updateProfile(
        name: event.name,
        email: event.email,
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(_extractMessage(e)));
    }
  }

  String _extractMessage(Object e) {
    final msg = e.toString();
    const prefix = 'Exception: ';
    if (msg.startsWith(prefix)) return msg.substring(prefix.length);
    return msg;
  }
}
