import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/agent/Agent Marketplace Page.dart';
import 'screens/agent/AgentDetails Page.dart';
import 'screens/agent/onboarding_chatbot_screen.dart';
import 'screens/agent/onboarding_welcome_screen.dart';
import 'screens/cart/cart_page.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';

import 'providers/cart_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp(
          title: 'E-Team - Department as a Service',
          debugShowCheckedModeBanner: false,

          locale: localeProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,

          theme: ThemeData(
            primaryColor: Colors.black,
            scaffoldBackgroundColor: const Color(0xFFFAFAFA),
            fontFamily: 'Inter',
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              secondary: Color(0xFFCDFF00),
              tertiary: Color(0xFFA855F7),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFCDFF00), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: const Color(0xFFCDFF00),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFFCDFF00),
            scaffoldBackgroundColor: const Color(0xFF0A0A0A),
            fontFamily: 'Inter',
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFCDFF00),
              secondary: Color(0xFFCDFF00),
              tertiary: Color(0xFFA855F7),
            ),
            cardColor: const Color(0xFF1E1E1E),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFCDFF00), width: 2),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          // ✅ MODE PRODUCTION : Démarrer sur splash
          // initialRoute: '/',

          // ✅ MODE TEST : Tester directement l'onboarding
          home: const OnboardingWelcomeScreen(email: 'test@example.com'),

          routes: {
            // NOTE: La route '/' est commentée car on utilise 'home' au lieu de 'initialRoute'
            // '/': (context) => const SplashScreen(),
            '/splash': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/verify-email': (context) => const EmailVerificationScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),

            // ✅ Route onboarding welcome
            '/onboarding-welcome': (context) {
              final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
              return OnboardingWelcomeScreen(
                email: args?['email'] ?? 'user@example.com',
              );
            },

            // ✅ Route onboarding chatbot
            '/onboarding-chatbot': (context) {
              final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
              return OnboardingChatbotScreen(
                email: args?['email'] ?? 'user@example.com',
              );
            },

            '/agent-marketplace': (context) => const AgentMarketplacePage(),
            '/cart': (context) => const CartPage(),
          },

          onGenerateRoute: (settings) {
            if (settings.name == '/agent-details') {
              final args = settings.arguments as Map<String, dynamic>?;
              if (args != null) {
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
            }
            return null;
          },
        );
      },
    );
  }
}