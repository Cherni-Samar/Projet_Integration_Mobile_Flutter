import 'package:flutter/material.dart';

import '/presentation/screens/agent/agent_details_page.dart';
import '/presentation/screens/agent/agent_marketplace_page.dart';
import '/presentation/screens/agent/my_agents_page.dart';
import '/presentation/screens/agent/onboarding_chatbot_screen.dart';
import '/presentation/screens/agent/onboarding_welcome_screen.dart';
import '/presentation/screens/auth/email_verification_screen.dart';
import '/presentation/screens/auth/forgot_password_screen.dart';
import '/presentation/screens/auth/login_screen.dart';
import '/presentation/screens/auth/signup_screen.dart';
import '/presentation/screens/cart/cart_page.dart';
import '/presentation/screens/settings/privacy_policy_screen.dart';
import '/presentation/screens/settings/terms_and_conditions_screen.dart';
import '/presentation/screens/splash_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String root = '/';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String verifyEmail = '/verify-email';
  static const String forgotPassword = '/forgot-password';
  static const String onboardingWelcome = '/onboarding-welcome';
  static const String onboardingChatbot = '/onboarding-chatbot';
  static const String agentMarketplace = '/agent-marketplace';
  static const String agentDetails = '/agent-details';
  static const String cart = '/cart';
  static const String myAgents = '/my-agents';
  static const String terms = '/terms';
  static const String privacy = '/privacy';

  static Map<String, WidgetBuilder> get routes => {
    root: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignUpScreen(),
    verifyEmail: (context) => const EmailVerificationScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    onboardingWelcome: (context) {
      final args = _arguments(context);
      return OnboardingWelcomeScreen(
        email: args?['email'] ?? 'user@example.com',
      );
    },
    onboardingChatbot: (context) {
      final args = _arguments(context);
      return OnboardingChatbotScreen(
        email: args?['email'] ?? 'user@example.com',
      );
    },
    agentMarketplace: (context) => const AgentMarketplacePage(),
    cart: (context) {
      final args = _arguments(context);
      final isOnboardingPayment = args?['isOnboardingPayment'] ?? false;
      return CartPage(isOnboardingPayment: isOnboardingPayment);
    },
    myAgents: (context) => const MyAgentsPage(),
    terms: (context) => const TermsAndConditionsScreen(),
    privacy: (context) => const PrivacyPolicyScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name != agentDetails) return null;

    final args = settings.arguments as Map<String, dynamic>?;
    if (args == null) return null;

    return MaterialPageRoute(
      builder: (context) => AgentDetailsPage(
        title: args['title'] ?? 'Agent',
        color: args['color'] ?? Colors.black,
        illustration: args['illustration'] ?? '',
        description: args['description'] ?? '',
        timesSaved: args['timesSaved'] ?? 0,
        price: args['price'] ?? 0.0,
      ),
    );
  }

  static Map<String, dynamic>? _arguments(BuildContext context) {
    return ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  }
}
