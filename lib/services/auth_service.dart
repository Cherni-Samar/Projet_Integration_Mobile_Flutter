import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user.dart';
import '../core/utils/constants.dart';
import 'api_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _credentialsEmailKey = 'saved_email';
  static const String _credentialsPasswordKey = 'saved_password';

  // SIGNUP
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await ApiService.post(
      endpoint: ApiConstants.signup,
      body: {'email': email, 'password': password, 'name': name},
    );

    if (response['success'] == true) {
      final token = response['data']['token'];
      final user = User.fromJson(response['data']['user'] as Map<String, dynamic>);
      await _saveToken(token as String);
      await _saveUser(user);
      return {'success': true, 'user': user};
    }

    throw Exception(response['message'] ?? 'Signup error');
  }

  // LOGIN
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      endpoint: ApiConstants.login,
      body: {'email': email, 'password': password},
    );

    if (response['success'] == true) {
      final token = response['data']['token'];
      final user = User.fromJson(response['data']['user'] as Map<String, dynamic>);
      await _saveToken(token as String);
      await _saveUser(user);
      return {'success': true, 'user': user};
    }

    throw Exception(response['message'] ?? 'Login error');
  }

  // GET ME
  Future<User?> getMe() async {
    final token = await getToken();
    if (token == null) return null;

    final response = await ApiService.get(
      endpoint: ApiConstants.getMe,
      token: token,
    );

    if (response['success'] == true) {
      final user = User.fromJson(response['data']['user'] as Map<String, dynamic>);
      await _saveUser(user);
      return user;
    }
    return null;
  }

  // Public helper to persist an updated user locally
  Future<void> saveUser(User user) async {
    await _saveUser(user);
  }

  // UPDATE USER PROFILE
  Future<User> updateUser({
    String? name,
    String? email,
    String? currentPassword,
    String? newPassword,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final Map<String, dynamic> body = {};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (currentPassword != null) body['currentPassword'] = currentPassword;
    if (newPassword != null) body['newPassword'] = newPassword;

    final response = await ApiService.patch(
      endpoint: ApiConstants.updateProfile,
      body: body,
      token: token,
    );

    if (response['success'] == true) {
      final user = User.fromJson(response['data']['user'] as Map<String, dynamic>);
      await _saveUser(user);
      return user;
    } else {
      throw Exception(response['message'] ?? 'Failed to update profile');
    }
  }

  // LOGOUT
  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        await ApiService.post(
          endpoint: ApiConstants.logout,
          body: {},
          token: token,
        );
      } catch (_) {
        // Proceed with local logout even if server call fails
      }
    }
    await _clearStorage();
  }

  // FORGOT PASSWORD
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await ApiService.post(
      endpoint: ApiConstants.forgotPassword,
      body: {'email': email},
    );
    return response;
  }

  // VERIFY RESET CODE
  Future<bool> verifyResetCode(String email, String code) async {
    final response = await ApiService.post(
      endpoint: ApiConstants.verifyResetCode,
      body: {'email': email, 'code': code},
    );
    return response['success'] == true;
  }

  // RESET PASSWORD
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final response = await ApiService.post(
      endpoint: ApiConstants.resetPassword,
      body: {'email': email, 'code': code, 'newPassword': newPassword},
    );
    return response['success'] == true;
  }

  // VERIFY EMAIL
  Future<bool> verifyEmail(String email, String code) async {
    final response = await ApiService.post(
      endpoint: ApiConstants.verifyEmail,
      body: {'email': email, 'code': code},
    );
    return response['success'] == true;
  }

  // RESEND VERIFICATION CODE
  Future<bool> resendVerificationCode(String email) async {
    final response = await ApiService.post(
      endpoint: ApiConstants.resendVerification,
      body: {'email': email},
    );
    return response['success'] == true;
  }

  // REMEMBER ME - SAVE CREDENTIALS
  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_credentialsEmailKey, email);
    await prefs.setString(_credentialsPasswordKey, password);
  }

  // REMEMBER ME - GET SAVED CREDENTIALS
  Future<Map<String, String>?> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_credentialsEmailKey);
    final password = prefs.getString(_credentialsPasswordKey);
    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  // REMEMBER ME - CLEAR SAVED CREDENTIALS
  Future<void> clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_credentialsEmailKey);
    await prefs.remove(_credentialsPasswordKey);
  }

  // STORAGE HELPERS
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData) as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
