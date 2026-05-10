import 'package:flutter/material.dart';

import 'package:e_team/data/services/auth_service.dart';
import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/widgets/auth/forgot_password/forgot_password_background.dart';
import 'package:e_team/presentation/widgets/auth/forgot_password/forgot_password_form_view.dart';
import 'package:e_team/presentation/widgets/auth/forgot_password/forgot_password_success.dart';
import 'package:e_team/presentation/widgets/common/app_snack_bar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _emailSent = false;
  bool _isEmailFocused = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.forgotPassword(_emailController.text.trim());
        if (mounted) {
          setState(() {
            _isLoading = false;
            _emailSent = true;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          AppSnackBar.error(
            context,
            e.toString().replaceAll('Exception: ', ''),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          ForgotPasswordGlow(animation: _animationController),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: _emailSent ? _buildSuccessView() : _buildFormView(),
            ),
          ),
          ForgotPasswordBackButton(onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    final l10n = AppLocalizations.of(context)!;
    return ForgotPasswordFormView(
      l10n: l10n,
      formKey: _formKey,
      emailController: _emailController,
      animation: _animationController,
      isLoading: _isLoading,
      isEmailFocused: _isEmailFocused,
      onEmailFocusChanged: (focused) =>
          setState(() => _isEmailFocused = focused),
      onSubmit: _handleResetPassword,
      onBackToLogin: () => Navigator.pop(context),
    );
  }

  Widget _buildSuccessView() {
    final l10n = AppLocalizations.of(context)!;
    return ForgotPasswordSuccessView(
      l10n: l10n,
      email: _emailController.text,
      onBackToLogin: () => Navigator.pop(context),
      onResend: _handleResetPassword,
    );
  }
}

class ForgotPasswordScreenPreview extends StatelessWidget {
  const ForgotPasswordScreenPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      ),
      home: const ForgotPasswordScreen(),
    );
  }
}
