import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';

class ForgotPasswordEmailField extends StatelessWidget {
  const ForgotPasswordEmailField({
    super.key,
    required this.l10n,
    required this.controller,
    required this.isFocused,
    required this.onFocusChanged,
  });

  final AppLocalizations l10n;
  final TextEditingController controller;
  final bool isFocused;
  final ValueChanged<bool> onFocusChanged;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: onFocusChanged,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isFocused
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isFocused
                  ? Colors.black.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: isFocused ? 15 : 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            labelText: l10n.authEmailLabel,
            hintText: l10n.authEmailHint,
            hintStyle: TextStyle(
              color: Colors.black.withValues(alpha: 0.3),
              fontWeight: FontWeight.w400,
            ),
            labelStyle: TextStyle(
              color: isFocused
                  ? Colors.black.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.4),
              fontWeight: FontWeight.w500,
            ),
            floatingLabelStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(
              Icons.alternate_email,
              color: isFocused
                  ? Colors.black.withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.3),
              size: 22,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.authEmailRequired;
            }
            if (!value.contains('@')) {
              return l10n.authEmailInvalid;
            }
            return null;
          },
        ),
      ),
    );
  }
}
