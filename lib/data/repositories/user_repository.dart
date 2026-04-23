import '../../data/models/user.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../../services/auth_service.dart';

class UserRepository implements IUserRepository {
  final AuthService _authService;

  UserRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

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
}
