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

class SignUpTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData icon;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;

  const SignUpTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.icon,
    required this.textInputAction,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onFieldSubmitted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      decoration: signUpInputDecoration(
        labelText: labelText,
        hintText: hintText,
        icon: icon,
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}

class SignUpPasswordVisibilityButton extends StatelessWidget {
  final bool isObscured;
  final VoidCallback onPressed;

  const SignUpPasswordVisibilityButton({
    super.key,
    required this.isObscured,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
      onPressed: onPressed,
    );
  }
}

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
                child: CircularProgressIndicator(
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

InputDecoration signUpInputDecoration({
  required String labelText,
  required String hintText,
  required IconData icon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    prefixIcon: Icon(icon),
    suffixIcon: suffixIcon,
  );
}
