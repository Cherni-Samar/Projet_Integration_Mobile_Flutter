import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/i_auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository _authRepository;

  AuthBloc({required IAuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthLoginRequested>(_onLogin);
    on<AuthSignupRequested>(_onSignup);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthEmailVerified>(_onEmailVerified);
  }

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.getSavedUser();
      if (user != null) {
        final fresh = await _authRepository.getMe();
        emit(AuthAuthenticated(fresh ?? user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      if (event.rememberMe) {
        await _authRepository.saveCredentials(
          email: event.email,
          password: event.password,
        );
      }
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(_extractMessage(e)));
    }
  }

  Future<void> _onSignup(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signup(
        email: event.email,
        password: event.password,
        name: event.name,
      );
      emit(AuthEmailVerificationRequired(event.email));
    } catch (e) {
      emit(AuthError(_extractMessage(e)));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onEmailVerified(
    AuthEmailVerified event,
    Emitter<AuthState> emit,
  ) async {
    final user = await _authRepository.getSavedUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  String _extractMessage(Object e) {
    final msg = e.toString();
    final prefix = 'Exception: ';
    if (msg.startsWith(prefix)) return msg.substring(prefix.length);
    return msg;
  }
}
