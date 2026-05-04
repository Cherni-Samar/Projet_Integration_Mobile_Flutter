import 'package:e_team/core/config/api_config.dart';

class ApiConstants {
  static String get baseUrl => '${ApiConfig.baseUrl}/api/auth';

  // Auth
  static String get signup => '$baseUrl/signup';
  static String get login => '$baseUrl/login';
  static String get logout => '$baseUrl/logout';
  static String get getMe => '$baseUrl/me';
  static String get updateProfile => '$baseUrl/update'; // ✅ Nouveau

  // Email
  static String get verifyEmail => '$baseUrl/verify-email';
  static String get resendVerification => '$baseUrl/resend-verification';

  // Password
  static String get forgotPassword => '$baseUrl/forgot-password';
  static String get verifyResetCode => '$baseUrl/verify-reset-code';
  static String get resetPassword => '$baseUrl/reset-password';

  // Payment (Stripe)
  static String get paymentBaseUrl => '${ApiConfig.baseUrl}/api/payment';
  static String get createPaymentIntent =>
      '$paymentBaseUrl/create-payment-intent';
  static String get confirmPayment => '$paymentBaseUrl/confirm-payment';

  // Agents
  static String get agentsBaseUrl => '${ApiConfig.baseUrl}/api/agents';
  static String get hireAgent => '$agentsBaseUrl/hire';

  // Kash (Finance)
  static String get kashBaseUrl => '${ApiConfig.baseUrl}/api/kash';
  static String get kashAnalyze => '$kashBaseUrl/analyze';
  static String get kashAddExpense => '$kashBaseUrl/add';

  //Predictions (Daily Challenge)
  static String get predictionsBaseUrl =>
      '${ApiConfig.baseUrl}/api/predictions';
  static String get predictionsDaily => '$predictionsBaseUrl/daily';
  static String get predictionsHistory => '$predictionsBaseUrl/history';
  static String predictionsAnswer(String id) =>
      '$predictionsBaseUrl/$id/answer';
  static String get predictionsResetToday => '$predictionsBaseUrl/reset-today';
}
