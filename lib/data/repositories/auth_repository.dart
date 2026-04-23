import '../../data/mappers/user_mapper.dart';
import '../../data/models/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../services/auth_service.dart';

class AuthRepository implements IAuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  @override
  Future<User> login({required String email, required String password}) async {
    final result = await _authService.login(email: email, password: password);
    return result['user'] as User;
  }

  @override
  Future<User> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    final result = await _authService.signup(
      email: email,
      password: password,
      name: name,
    );
    return result['user'] as User;
  }

  @override
  Future<void> logout() => _authService.logout();

  @override
  Future<User?> getMe() => _authService.getMe();

  @override
  Future<User> updateProfile({
    String? name,
    String? email,
    String? currentPassword,
    String? newPassword,
  }) =>
      _authService.updateUser(
        name: name,
        email: email,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

  @override
  Future<void> forgotPassword(String email) =>
      _authService.forgotPassword(email);

  @override
  Future<bool> verifyResetCode(String email, String code) =>
      _authService.verifyResetCode(email, code);

  @override
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) =>
      _authService.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );

  @override
  Future<bool> verifyEmail(String email, String code) =>
      _authService.verifyEmail(email, code);

  @override
  Future<bool> resendVerificationCode(String email) =>
      _authService.resendVerificationCode(email);

  @override
  Future<String?> getToken() => _authService.getToken();

  @override
  Future<User?> getSavedUser() => _authService.getSavedUser();

  @override
  Future<bool> isLoggedIn() => _authService.isLoggedIn();

  @override
  Future<void> saveCredentials({
    required String email,
    required String password,
  }) =>
      _authService.saveCredentials(email: email, password: password);

  @override
  Future<Map<String, String>?> getSavedCredentials() =>
      _authService.getSavedCredentials();

  @override
  Future<void> clearSavedCredentials() =>
      _authService.clearSavedCredentials();
}
