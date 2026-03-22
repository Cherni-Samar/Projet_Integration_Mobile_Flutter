import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class StripeService {
  static final AuthService _authService = AuthService();
  static String? _lastPaymentIntentId;

  static String? get lastPaymentIntentId => _lastPaymentIntentId;

  /// Creates a PaymentIntent on the backend and presents the Stripe PaymentSheet.
  /// [packId] is a server-defined identifier (e.g. energy_eco, energy_boost, basic_plan).
  /// Returns true on success, false on cancel.
  /// Throws on error.
  static Future<bool> makePayment({
    required String packId,
  }) async {
    // 1. Get the auth token
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('You must be logged in to make a payment');
    }

    final response = await ApiService.post(
      endpoint: ApiConstants.createPaymentIntent,
      body: {
        'packId': packId,
      },
      token: token,
    );

    if (response['success'] != true || response['clientSecret'] == null) {
      throw Exception(response['message'] ?? 'Failed to create payment intent');
    }

    final clientSecret = response['clientSecret'] as String;
    final paymentIntentId = response['paymentIntentId'];
    if (paymentIntentId == null) {
      throw Exception('Missing paymentIntentId from backend response');
    }

    _lastPaymentIntentId = paymentIntentId.toString();

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
        _lastPaymentIntentId = null;
        return false; // User cancelled
      }
      rethrow;
    }
  }
}
