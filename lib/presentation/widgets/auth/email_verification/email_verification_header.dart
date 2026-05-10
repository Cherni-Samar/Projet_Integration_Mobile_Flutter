import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';

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
