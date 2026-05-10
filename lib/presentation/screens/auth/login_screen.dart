import 'package:e_team/data/dtos/user_dto.dart';
import 'package:e_team/data/services/auth_service.dart';
import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/providers/theme_provider.dart';
import 'package:e_team/presentation/widgets/auth/login/login_actions.dart';
import 'package:e_team/presentation/widgets/auth/login/login_background.dart';
import 'package:e_team/presentation/widgets/auth/login/login_fields.dart';
import 'package:e_team/presentation/widgets/common/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _rememberMe = false;

  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    final credentials = await _authService.getSavedCredentials();
    if (credentials != null && mounted) {
      setState(() {
        _emailController.text = credentials['email'] ?? '';
        _passwordController.text = credentials['password'] ?? '';
        _rememberMe = true;
      });
    }
  }

  Future<void> _handleLogin() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final UserDTO? user = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (_rememberMe) {
        await _authService.saveCredentials(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await _authService.clearSavedCredentials();
      }

      if (user != null && mounted) {
        AppSnackBar.show(
          context,
          l10n.authWelcomeBackSnack,
          type: AppSnackBarType.success,
          duration: const Duration(seconds: 2),
        );

        if (!user.onboardingCompleted) {
          Navigator.pushReplacementNamed(
            context,
            '/onboarding-welcome',
            arguments: {'email': _emailController.text.trim()},
          );
        } else {
          Navigator.pushReplacementNamed(context, '/agent-marketplace');
        }
      }
    } catch (e) {
      if (mounted) {
        _showLoginErrorSnackBar(_loginErrorMessage(e, l10n));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _loginErrorMessage(Object error, AppLocalizations l10n) {
    final errorMessage = error.toString();

    if (errorMessage.contains('Utilisateur non trouvé') ||
        errorMessage.contains('not found')) {
      return l10n.authLoginNoAccount;
    } else if (errorMessage.contains('Mot de passe incorrect') ||
        errorMessage.contains('incorrect')) {
      return l10n.authLoginIncorrectPassword;
    } else if (errorMessage.contains('SocketException')) {
      return l10n.authUnableToConnect;
    }

    return l10n.authLoginFailedTryAgain;
  }

  void _showLoginErrorSnackBar(String errorMessage) {
    AppSnackBar.show(
      context,
      errorMessage,
      type: AppSnackBarType.error,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          LoginGlowBackground(glowController: _glowController, isDark: isDark),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    LoginLogo(isDark: isDark, progress: _glowController.value),
                    const SizedBox(height: 50),
                    Text(
                      l10n.authWelcomeBackTitle,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black,
                        height: 1.1,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 62),
                    LoginTextField(
                      controller: _emailController,
                      label: l10n.authEmailLabel,
                      hint: l10n.authEmailHint,
                      icon: Icons.alternate_email,
                      isFocused: _isEmailFocused,
                      onFocusChange: (focused) =>
                          setState(() => _isEmailFocused = focused),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      isDark: isDark,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.authEmailRequired;
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return l10n.authEmailInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    LoginTextField(
                      controller: _passwordController,
                      label: l10n.authPasswordLabel,
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      isFocused: _isPasswordFocused,
                      onFocusChange: (focused) =>
                          setState(() => _isPasswordFocused = focused),
                      isPassword: true,
                      obscurePassword: _obscurePassword,
                      onTogglePassword: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleLogin(),
                      isDark: isDark,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.authPasswordRequired;
                        }
                        if (value.length < 6) return l10n.authPasswordMin6Short;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    LoginRememberForgotRow(
                      rememberMe: _rememberMe,
                      onRememberChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                      onForgotPassword: () =>
                          Navigator.pushNamed(context, '/forgot-password'),
                      isDark: isDark,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 32),
                    LoginSubmitButton(
                      isDark: isDark,
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 40),
                    LoginSignupPrompt(
                      isDark: isDark,
                      onSignup: () => Navigator.pushNamed(context, '/signup'),
                      l10n: l10n,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
