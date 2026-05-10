/// All secrets are injected at build time via --dart-define.
/// Never hardcode values here.
///
/// For CI/CD, pass these as environment variables.
class AppSecrets {
  /// Stripe publishable key.
  /// Required only when opening the Stripe payment sheet.
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
  );

  /// VAPI public key for voice AI.
  static const String vapiPublicKey = String.fromEnvironment('VAPI_PUBLIC_KEY');

  /// VAPI assistant ID.
  static const String vapiAssistantId = String.fromEnvironment(
    'VAPI_ASSISTANT_ID',
  );
}