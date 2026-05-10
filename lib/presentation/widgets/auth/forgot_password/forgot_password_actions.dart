import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';

class ForgotPasswordSubmitButton extends StatelessWidget {
  const ForgotPasswordSubmitButton({
    super.key,
    required this.l10n,
    required this.isLoading,
    required this.onPressed,
  });

  final AppLocalizations l10n;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: const Color(0xFFCCFF00),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCCFF00)),
                ),
              )
            : Text(
                l10n.authSendResetLink,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}

class ForgotPasswordBackToLoginLink extends StatelessWidget {
  const ForgotPasswordBackToLoginLink({
    super.key,
    required this.l10n,
    required this.onPressed,
  });

  final AppLocalizations l10n;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.arrow_back,
          size: 16,
          color: Colors.black.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onPressed,
          child: Text(
            l10n.authBackToLogin,
            style: const TextStyle(
              color: Color(0xFF8B5CF6),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
