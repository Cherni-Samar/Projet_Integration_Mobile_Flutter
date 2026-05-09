import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';

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

class EmailVerificationIcon extends StatelessWidget {
  const EmailVerificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFCDFF00).withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.mark_email_unread_outlined,
        size: 50,
        color: Colors.black,
      ),
    );
  }
}

class EmailVerificationHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final String? email;

  const EmailVerificationHeader({
    super.key,
    required this.l10n,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          l10n.authVerifyYourEmailTitle,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.authWeSentCodeTo,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          email ?? l10n.authYourEmailPlaceholder,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFA855F7),
          ),
        ),
      ],
    );
  }
}

class EmailVerificationOtpRow extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int index, String value) onCodeChanged;

  const EmailVerificationOtpRow({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.onCodeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        6,
        (index) => EmailVerificationOtpBox(
          controller: controllers[index],
          focusNode: focusNodes[index],
          onChanged: (value) => onCodeChanged(index, value),
        ),
      ),
    );
  }
}

class EmailVerificationOtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const EmailVerificationOtpBox({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focusNode.hasFocus
              ? const Color(0xFFCDFF00)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

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
