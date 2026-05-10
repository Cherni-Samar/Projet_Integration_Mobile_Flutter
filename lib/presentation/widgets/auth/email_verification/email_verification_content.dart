import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/widgets/auth/email_verification/email_verification_actions.dart';
import 'package:e_team/presentation/widgets/auth/email_verification/email_verification_header.dart';
import 'package:e_team/presentation/widgets/auth/email_verification/email_verification_otp.dart';

class EmailVerificationContent extends StatelessWidget {
  final AppLocalizations l10n;
  final String? email;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool isLoading;
  final bool isResending;
  final int resendTimer;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final void Function(int index, String value) onCodeChanged;

  const EmailVerificationContent({
    super.key,
    required this.l10n,
    required this.email,
    required this.controllers,
    required this.focusNodes,
    required this.isLoading,
    required this.isResending,
    required this.resendTimer,
    required this.onVerify,
    required this.onResend,
    required this.onCodeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const EmailVerificationIcon(),
          const SizedBox(height: 30),
          EmailVerificationHeader(l10n: l10n, email: email),
          const SizedBox(height: 40),
          EmailVerificationOtpRow(
            controllers: controllers,
            focusNodes: focusNodes,
            onCodeChanged: onCodeChanged,
          ),
          const SizedBox(height: 40),
          EmailVerificationButton(
            l10n: l10n,
            isLoading: isLoading,
            onPressed: onVerify,
          ),
          const SizedBox(height: 30),
          EmailVerificationResendRow(
            l10n: l10n,
            resendTimer: resendTimer,
            isResending: isResending,
            onResend: onResend,
          ),
        ],
      ),
    );
  }
}
