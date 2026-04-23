import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/agent/agent_marketplace_page.dart';
import 'screens/agent/agent_details_page.dart';
import 'screens/agent/onboarding_chatbot_screen.dart';
import 'screens/agent/onboarding_welcome_screen.dart';
import 'screens/cart/cart_page.dart';
import 'providers/owned_agents_provider.dart';
import 'providers/user_provider.dart';
import 'providers/cart_provider.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/cart/cart_bloc.dart';
import 'blocs/agent/agent_bloc.dart';
import 'blocs/user/user_bloc.dart';
import 'blocs/theme/theme_cubit.dart';
import 'blocs/locale/locale_cubit.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/cart_repository.dart';
import 'data/repositories/agent_repository.dart';
import 'data/repositories/user_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = const String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_placeholder',
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(
          create: (_) => AuthBloc(authRepository: AuthRepository())
            ..add(const AuthCheckStatus()),
        ),
        BlocProvider(create: (_) => CartBloc()),
        BlocProvider(
          create: (_) => AgentBloc(agentRepository: AgentRepository()),
        ),
        BlocProvider(
          create: (_) => UserBloc(userRepository: UserRepository())
            ..add(const UserRefreshRequested()),
        ),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProxyProvider<UserProvider, OwnedAgentsProvider>(
            create: (_) => OwnedAgentsProvider(),
            update: (_, userProvider, owned) {
              owned ??= OwnedAgentsProvider();
              owned.syncFromActiveAgents(userProvider.activeAgents);
              return owned;
            },
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, isDarkMode) {
        return BlocBuilder<LocaleCubit, Locale?>(
          builder: (context, locale) {
            return MaterialApp(
              title: 'E-Team - Department as a Service',
              debugShowCheckedModeBanner: false,

              locale: locale,
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
                    borderSide: const BorderSide(
                      color: Color(0xFFCDFF00),
                      width: 2,
                    ),
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
                    borderSide: const BorderSide(
                      color: Color(0xFFCDFF00),
                      width: 2,
                    ),
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

              themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

              routes: {
                '/': (context) => const SplashScreen(),
                '/splash': (context) => const SplashScreen(),
                '/login': (context) => const LoginScreen(),
                '/signup': (context) => const SignUpScreen(),
                '/verify-email': (context) => const EmailVerificationScreen(),
                '/forgot-password': (context) => const ForgotPasswordScreen(),
                '/onboarding-welcome': (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  return OnboardingWelcomeScreen(
                    email: args?['email'] ?? 'user@example.com',
                  );
                },
                '/onboarding-chatbot': (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  return OnboardingChatbotScreen(
                    email: args?['email'] ?? 'user@example.com',
                  );
                },
                '/agent-marketplace': (context) =>
                    const AgentMarketplacePage(),
                '/cart': (context) => const CartPage(),
              },

              onGenerateRoute: (settings) {
                if (settings.name == '/agent-details') {
                  final args =
                      settings.arguments as Map<String, dynamic>?;
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
      },
    );
  }
}