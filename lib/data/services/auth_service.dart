// lib/data/services/auth_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_team/data/dtos/user_dto.dart'; // ✅ Import du DTO
import 'package:e_team/core/utils/constants.dart';
import 'api_service.dart';
import 'package:e_team/domain/models/user_model.dart';
import 'package:e_team/data/mappers/user_mapper.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
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
      // ✅ FIX: Save the JWT token (matching login() pattern)
      await _saveToken(response['data']['token']);

      // ✅ FIX: Save user data to SharedPreferences (matching login() pattern)
      final dto = UserDTO.fromJson(response['data']['user']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(dto.toJson()));

      return response;
    }

    throw Exception(response['message'] ?? 'Signup error');
  }

  Future<void> logout() async {
    final token = await getToken();

    if (token != null) {
      try {
        await ApiService.post(
          endpoint: ApiConstants.logout,
          body: {},
          token: token,
        );
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email', email);
    await prefs.setString('saved_password', password);
  }

  Future<Map<String, String>?> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('saved_email');
    final password = prefs.getString('saved_password');

    if (email == null || password == null) return null;

    return {'email': email, 'password': password};
  }

  Future<void> clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email');
    await prefs.remove('saved_password');
  }

  // LOGIN (Exemple)
  Future<UserDTO?> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      endpoint: ApiConstants.login,
      body: {'email': email, 'password': password},
    );

    if (response['success'] == true) {
      await _saveToken(response['data']['token']);
      final dto = UserDTO.fromJson(response['data']['user']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(dto.toJson()));
      return dto;
    }
    throw Exception(response['message'] ?? 'Login error');
  }

  // GET ME
  Future<UserDTO?> getMe() async {
    final token = await getToken();
    if (token == null) return null;
    final response = await ApiService.get(
      endpoint: ApiConstants.getMe,
      token: token,
    );
    if (response['success'] == true) {
      return UserDTO.fromJson(response['data']['user']);
    }
    return null;
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

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<UserDTO?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) return UserDTO.fromJson(jsonDecode(userData));
    return null;
  }

  Future<void> clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<Map<String, dynamic>> updateUser({
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

    if (name != null && name.isNotEmpty) body['name'] = name;
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (currentPassword != null && currentPassword.isNotEmpty) {
      body['currentPassword'] = currentPassword;
    }
    if (newPassword != null && newPassword.isNotEmpty) {
      body['newPassword'] = newPassword;
    }

    final response = await ApiService.patch(
      endpoint: ApiConstants.updateProfile,
      body: body,
      token: token,
    );

    if (response['success'] == true) {
      return response;
    }

    throw Exception(response['message'] ?? 'Failed to update profile');
  }

  Future<bool> verifyResetCode(String email, String code) async {
    final response = await ApiService.post(
      endpoint: ApiConstants.verifyResetCode,
      body: {'email': email, 'code': code},
    );

    return response['success'] == true;
  }

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

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await ApiService.post(
      endpoint: ApiConstants.forgotPassword,
      body: {'email': email},
    );

    return response;
  }

  Future<User?> getSavedUserModel() async {
    final dto = await getSavedUser();
    if (dto == null) return null;

    return UserMapper.fromDTO(dto);
  }
}
