import 'package:flutter/material.dart';

import 'package:e_team/data/services/auth_service.dart';
import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/screens/settings/privacy_policy_screen.dart';
import 'package:e_team/presentation/screens/settings/terms_and_conditions_screen.dart';
import 'package:e_team/presentation/widgets/auth/signup/signup_actions.dart';
import 'package:e_team/presentation/widgets/auth/signup/signup_fields.dart';
import 'package:e_team/presentation/widgets/auth/signup/signup_header.dart';
import 'package:e_team/presentation/widgets/auth/signup/signup_terms.dart';
import 'package:e_team/presentation/widgets/common/app_snack_bar.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      _showSnackBar(l10n.authAcceptTermsError, Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.signup(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );

      if (result['success'] == true && mounted) {
        _showSnackBar(
          l10n.authAccountCreatedCheckEmail,
          Colors.green,
          duration: const Duration(seconds: 3),
        );

        Navigator.pushReplacementNamed(
          context,
          '/verify-email',
          arguments: {'email': _emailController.text.trim()},
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          '❌ ${_localizedError(e, l10n)}',
          Colors.red,
          duration: const Duration(seconds: 4),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _localizedError(Object error, AppLocalizations l10n) {
    final errorMessage = error.toString();

    if (errorMessage.contains('Email already exists') ||
        errorMessage.contains('déjà utilisé')) {
      return l10n.authEmailAlreadyRegistered;
    }
    if (errorMessage.contains('SocketException')) {
      return l10n.authUnableToConnect;
    }
    if (errorMessage.contains('TimeoutException')) {
      return l10n.authConnectionTimeout;
    }

    return errorMessage;
  }

  void _showSnackBar(
    String message,
    Color backgroundColor, {
    Duration? duration,
  }) {
    AppSnackBar.show(
      context,
      message,
      type: _snackBarTypeFor(backgroundColor),
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  AppSnackBarType _snackBarTypeFor(Color color) {
    if (color == Colors.green) return AppSnackBarType.success;
    if (color == Colors.red) return AppSnackBarType.error;
    return AppSnackBarType.info;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SignUpHeader(l10n: l10n),
                const SizedBox(height: 40),
                SignUpTextField(
                  controller: _nameController,
                  labelText: l10n.authFullNameLabel,
                  hintText: l10n.authFullNameHint,
                  icon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.authNameRequired;
                    }
                    if (value.length < 2) {
                      return l10n.authNameMin2;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SignUpTextField(
                  controller: _emailController,
                  labelText: l10n.authEmailLabel,
                  hintText: l10n.authEmailHint,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
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
                SignUpTextField(
                  controller: _passwordController,
                  labelText: l10n.authPasswordLabel,
                  hintText: '••••••••',
                  icon: Icons.lock_outlined,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  suffixIcon: SignUpPasswordVisibilityButton(
                    isObscured: _obscurePassword,
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.authPasswordRequired;
                    }
                    if (value.length < 6) {
                      return l10n.authPasswordMin6;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SignUpTextField(
                  controller: _confirmPasswordController,
                  labelText: l10n.authConfirmPasswordLabel,
                  hintText: '••••••••',
                  icon: Icons.lock_outlined,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) =>
                      _acceptTerms ? _handleSignUp() : null,
                  suffixIcon: SignUpPasswordVisibilityButton(
                    isObscured: _obscureConfirmPassword,
                    onPressed: () {
                      setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      );
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.authConfirmPasswordRequired;
                    }
                    if (value != _passwordController.text) {
                      return l10n.authPasswordsDoNotMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SignUpTermsCheckbox(
                  l10n: l10n,
                  value: _acceptTerms,
                  onChanged: (value) {
                    setState(() => _acceptTerms = value ?? false);
                  },
                  onTermsPressed: () =>
                      _pushPage(const TermsAndConditionsScreen()),
                  onPrivacyPressed: () =>
                      _pushPage(const PrivacyPolicyScreen()),
                ),
                const SizedBox(height: 30),
                SignUpSubmitButton(
                  l10n: l10n,
                  isLoading: _isLoading,
                  acceptTerms: _acceptTerms,
                  onPressed: _handleSignUp,
                ),
                const SizedBox(height: 30),
                SignUpSignInLink(
                  l10n: l10n,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _pushPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
