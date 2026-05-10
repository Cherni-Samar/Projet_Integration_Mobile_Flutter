import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';

class SignUpTermsCheckbox extends StatelessWidget {
  final AppLocalizations l10n;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTermsPressed;
  final VoidCallback onPrivacyPressed;

  const SignUpTermsCheckbox({
    super.key,
    required this.l10n,
    required this.value,
    required this.onChanged,
    required this.onTermsPressed,
    required this.onPrivacyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFFA855F7);
              }
              return null;
            }),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Wrap(
              children: [
                Text(
                  l10n.authAgreeToPrefix,
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
                SignUpInlineLink(
                  text: l10n.authTermsAndConditions,
                  onPressed: onTermsPressed,
                ),
                Text(
                  l10n.authAnd,
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
                SignUpInlineLink(
                  text: l10n.authPrivacyPolicy,
                  onPressed: onPrivacyPressed,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SignUpInlineLink extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const SignUpInlineLink({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFA855F7),
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          fontSize: 14,
        ),
      ),
    );
  }
}
