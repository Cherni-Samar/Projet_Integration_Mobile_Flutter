import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:e_team/core/config/app_secrets.dart';
import 'package:e_team/data/services/api_service.dart';
import 'package:e_team/data/services/auth_service.dart';
import 'package:e_team/core/utils/constants.dart';

class StripeService {
  static final AuthService _authService = AuthService();

  static Future<void> _ensureStripeConfigured() async {
    final publishableKey = AppSecrets.stripePublishableKey.trim();
    if (publishableKey.isEmpty) {
      throw Exception(
        'Stripe publishable key is not configured. Pass it with --dart-define=STRIPE_PUBLISHABLE_KEY=your_value.',
      );
    }

    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }

  /// Creates a PaymentIntent, presents the Stripe PaymentSheet, and confirms
  /// the payment with the backend in a single call.
  ///
  /// Returns the backend confirmation response map on success.
  /// Returns null if the user cancelled.
  /// Throws on any other error.
  ///
  /// [packId] is a server-defined identifier (e.g. energy_eco, energy_boost, basic_plan).
  /// [suggestedAgents] is an optional list of agent names to auto-hire after payment.
  static Future<Map<String, dynamic>?> makePayment({
    required String packId,
    List<String>? suggestedAgents,
  }) async {
    await _ensureStripeConfigured();

    // 1. Get the auth token
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('You must be logged in to make a payment');
    }

    // 2. Create PaymentIntent on the backend
    final response = await ApiService.post(
      endpoint: ApiConstants.createPaymentIntent,
      body: {
        'packId': packId,
        if (suggestedAgents != null && suggestedAgents.isNotEmpty)
          'suggestedAgents': suggestedAgents,
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

    // 3. Initialize the PaymentSheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'E-Team',
      ),
    );

    // 4. Present the PaymentSheet
    try {
      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return null; // User cancelled — caller checks for null
      }
      rethrow;
    }

    // 5. Confirm payment with backend and return the full response
    final confirmRes = await ApiService.post(
      endpoint: ApiConstants.confirmPayment,
      body: {'paymentIntentId': paymentIntentId.toString()},
      token: token,
    );

    return confirmRes;
  }
}
