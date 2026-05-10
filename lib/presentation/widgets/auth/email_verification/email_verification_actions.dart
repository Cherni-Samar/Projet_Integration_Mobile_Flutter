import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';

class EmailVerificationButton extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isLoading;
  final VoidCallback onPressed;

  const EmailVerificationButton({
    super.key,
    required this.l10n,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: const Color(0xFFCDFF00),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCDFF00)),
                ),
              )
            : Text(
                l10n.authVerifyEmailButton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class EmailVerificationResendRow extends StatelessWidget {
  final AppLocalizations l10n;
  final int resendTimer;
  final bool isResending;
  final VoidCallback onResend;

  const EmailVerificationResendRow({
    super.key,
    required this.l10n,
    required this.resendTimer,
    required this.isResending,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.authDidntReceiveCode,
          style: const TextStyle(color: Colors.black54),
        ),
        if (resendTimer > 0)
          Text(
            l10n.authResendInSeconds(resendTimer),
            style: const TextStyle(
              color: Colors.black38,
              fontWeight: FontWeight.w600,
            ),
          )
        else
          TextButton(
            onPressed: isResending ? null : onResend,
            child: isResending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    l10n.authResendCode,
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
