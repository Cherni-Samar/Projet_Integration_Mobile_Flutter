import '../../data/models/user.dart';

abstract class IAuthRepository {
  Future<User> login({required String email, required String password});
  Future<User> signup({
    required String email,
    required String password,
    required String name,
  });
  Future<void> logout();
  Future<User?> getMe();
  Future<User> updateProfile({
    String? name,
    String? email,
    String? currentPassword,
    String? newPassword,
  });
  Future<void> forgotPassword(String email);
  Future<bool> verifyResetCode(String email, String code);
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
  Future<bool> verifyEmail(String email, String code);
  Future<bool> resendVerificationCode(String email);
  Future<String?> getToken();
  Future<User?> getSavedUser();
  Future<bool> isLoggedIn();
  Future<void> saveCredentials({
    required String email,
    required String password,
  });
  Future<Map<String, String>?> getSavedCredentials();
  Future<void> clearSavedCredentials();
}
