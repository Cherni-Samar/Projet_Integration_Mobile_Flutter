import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class StripeService {
  static final AuthService _authService = AuthService();

  /// Creates a PaymentIntent on the backend and presents the Stripe PaymentSheet.
  /// [amount] is the total price in EUR (e.g. 29.99).
  /// Returns true on success, false on cancel.
  /// Throws on error.
  static Future<bool> makePayment({
    required double amount,
    String currency = 'eur',
  }) async {
    // 1. Get the auth token
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('You must be logged in to make a payment');
    }

    // 2. Create PaymentIntent on our backend (amount in cents)
    final amountInCents = (amount * 100).round();
    final response = await ApiService.post(
      endpoint: ApiConstants.createPaymentIntent,
      body: {
        'amount': amountInCents,
        'currency': currency,
      },
      token: token,
    );

    if (response['success'] != true || response['clientSecret'] == null) {
      throw Exception(response['message'] ?? 'Failed to create payment intent');
    }

    final clientSecret = response['clientSecret'] as String;

    // 3. Initialize the PaymentSheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'E-Team',
        style: ThemeMode.system,
      ),
    );

    // 4. Present the PaymentSheet
    try {
      await Stripe.instance.presentPaymentSheet();
      return true; // Payment succeeded
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return false; // User cancelled
      }
      rethrow;
    }
  }
}
