class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:3000/api/auth';

  // Auth
  static const String signup = '$baseUrl/signup';
  static const String login = '$baseUrl/login';
  static const String logout = '$baseUrl/logout';
  static const String getMe = '$baseUrl/me';
  static const String updateProfile = '$baseUrl/update'; // ✅ Nouveau

  // Email
  static const String verifyEmail = '$baseUrl/verify-email';
  static const String resendVerification = '$baseUrl/resend-verification';

  // Password
  static const String forgotPassword = '$baseUrl/forgot-password';
  static const String verifyResetCode = '$baseUrl/verify-reset-code';
  static const String resetPassword = '$baseUrl/reset-password';
}