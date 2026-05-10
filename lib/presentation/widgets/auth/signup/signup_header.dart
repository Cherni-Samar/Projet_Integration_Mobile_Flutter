import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';

class SignUpHeader extends StatelessWidget {
  final AppLocalizations l10n;

  const SignUpHeader({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.authCreateAccountTitle,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.authSignupSubtitle,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }
}
