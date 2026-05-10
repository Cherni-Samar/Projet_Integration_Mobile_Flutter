import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/widgets/auth/forgot_password/forgot_password_actions.dart';
import 'package:e_team/presentation/widgets/auth/forgot_password/forgot_password_email_field.dart';
import 'package:e_team/presentation/widgets/auth/forgot_password/forgot_password_neural_icon.dart';

class ForgotPasswordFormView extends StatelessWidget {
  const ForgotPasswordFormView({
    super.key,
    required this.l10n,
    required this.formKey,
    required this.emailController,
    required this.animation,
    required this.isLoading,
    required this.isEmailFocused,
    required this.onEmailFocusChanged,
    required this.onSubmit,
    required this.onBackToLogin,
  });

  final AppLocalizations l10n;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final Animation<double> animation;
  final bool isLoading;
  final bool isEmailFocused;
  final ValueChanged<bool> onEmailFocusChanged;
  final VoidCallback onSubmit;
  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 100),
          ForgotPasswordNeuralIcon(animation: animation),
          const SizedBox(height: 50),
          Text(
            l10n.authForgotPasswordTitle,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.authForgotPasswordSubtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black.withValues(alpha: 0.5),
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 50),
          ForgotPasswordEmailField(
            l10n: l10n,
            controller: emailController,
            isFocused: isEmailFocused,
            onFocusChanged: onEmailFocusChanged,
          ),
          const SizedBox(height: 32),
          ForgotPasswordSubmitButton(
            l10n: l10n,
            isLoading: isLoading,
            onPressed: onSubmit,
          ),
          const SizedBox(height: 32),
          ForgotPasswordBackToLoginLink(l10n: l10n, onPressed: onBackToLogin),
        ],
      ),
    );
  }
}
