import 'package:e_team/presentation/widgets/common/app_loading.dart';
import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';

class SignUpSubmitButton extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isLoading;
  final bool acceptTerms;
  final VoidCallback onPressed;

  const SignUpSubmitButton({
    super.key,
    required this.l10n,
    required this.isLoading,
    required this.acceptTerms,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (isLoading || !acceptTerms) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: acceptTerms ? Colors.black : Colors.grey,
          foregroundColor: const Color(0xFFCDFF00),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          disabledBackgroundColor: Colors.grey.shade400,
          disabledForegroundColor: Colors.grey.shade600,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: AppLoadingIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCDFF00)),
                ),
              )
            : Text(
                l10n.authCreateAccountTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: acceptTerms
                      ? const Color(0xFFCDFF00)
                      : Colors.grey.shade600,
                ),
              ),
      ),
    );
  }
}

class SignUpSignInLink extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onPressed;

  const SignUpSignInLink({
    super.key,
    required this.l10n,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.authAlreadyHaveAccount,
          style: const TextStyle(color: Colors.black54),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            l10n.authSignIn,
            style: const TextStyle(
              color: Color(0xFFA855F7),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
