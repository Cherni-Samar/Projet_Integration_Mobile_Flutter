import 'package:flutter/material.dart';

import 'package:e_team/presentation/widgets/auth/signup/signup_helpers.dart';

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
