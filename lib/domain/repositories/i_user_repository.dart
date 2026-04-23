import '../../data/models/user.dart';

abstract class IUserRepository {
  Future<User?> getMe();
  Future<User> updateProfile({
    String? name,
    String? email,
    String? currentPassword,
    String? newPassword,
  });
}
