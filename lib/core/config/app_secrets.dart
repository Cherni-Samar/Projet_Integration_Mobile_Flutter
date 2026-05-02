/// All secrets are injected at build time via --dart-define.
/// Never hardcode values here.
///
/// Usage:
///   flutter run \
///     --dart-define=STRIPE_KEY=pk_test_... \
///     --dart-define=VAPI_PUBLIC_KEY=6c5ea938-... \
///     --dart-define=VAPI_ASSISTANT_ID=7c6ac6cf-...
///
/// For CI/CD, pass these as environment variables.
class AppSecrets {
  /// Stripe publishable key.
  /// Falls back to the test key so dev builds still work without --dart-define.
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_KEY',
    defaultValue:
        'pk_test_51RIdV7QLtPq7s5k7xiLNgDPFR81G2fA4H8JxNWEK9Adrlm29M0FfWbBytw6astsugguURilr6OYtxzis36aTPhKc00b5eVc6Cm',
  );

  /// VAPI public key for voice AI.
  static const String vapiPublicKey = String.fromEnvironment(
    'VAPI_PUBLIC_KEY',
    defaultValue: '6c5ea938-c1c0-4a59-826e-143cbaa8de53',
  );

  /// VAPI assistant ID.
  static const String vapiAssistantId = String.fromEnvironment(
    'VAPI_ASSISTANT_ID',
    defaultValue: '7c6ac6cf-c5b1-45a8-9b7b-9655735e78f4',
  );
}
