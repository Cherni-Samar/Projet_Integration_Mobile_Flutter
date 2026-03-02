class ApiConstants {
  // Change the IP here to switch between emulator and physical device
  static const String _host = '10.0.2.2:3000';
  // static const String _host = '192.168.100.15:3000'; // ✅ Adresse IP pour le telephone physique

  static const String baseUrl = 'http://$_host/api/auth';

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

  // Payment (Stripe)
  static const String paymentBaseUrl = 'http://$_host/api/payment';
  static const String createPaymentIntent = '$paymentBaseUrl/create-payment-intent';
  static const String confirmPayment = '$paymentBaseUrl/confirm-payment';

  // Agents
  static const String agentsBaseUrl = 'http://$_host/api/agents';
  static const String hireAgent = '$agentsBaseUrl/hire';
}
