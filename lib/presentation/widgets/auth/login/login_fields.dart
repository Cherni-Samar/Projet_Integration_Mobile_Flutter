import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  const LoginTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.isFocused,
    required this.onFocusChange,
    required this.isDark,
    this.isPassword = false,
    this.obscurePassword = false,
    this.onTogglePassword,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isFocused;
  final Function(bool) onFocusChange;
  final bool isDark;
  final bool isPassword;
  final bool obscurePassword;
  final VoidCallback? onTogglePassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: onFocusChange,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isFocused
                ? (isDark
                      ? const Color(0xFFCDFF00)
                      : Colors.black.withValues(alpha: 0.3))
                : (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.transparent),
            width: isFocused ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isFocused
                  ? (isDark
                        ? const Color(0xFFCDFF00).withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.06))
                  : (isDark
                        ? Colors.transparent
                        : Colors.black.withValues(alpha: 0.03)),
              blurRadius: isFocused ? 15 : 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          obscureText: isPassword ? obscurePassword : false,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.3),
              fontWeight: FontWeight.w400,
            ),
            labelStyle: TextStyle(
              color: isFocused
                  ? (isDark
                        ? const Color(0xFFCDFF00)
                        : Colors.black.withValues(alpha: 0.7))
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.4)),
              fontWeight: FontWeight.w500,
            ),
            floatingLabelStyle: TextStyle(
              color: isDark ? const Color(0xFFCDFF00) : Colors.black,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(
              icon,
              color: isFocused
                  ? (isDark
                        ? const Color(0xFFCDFF00)
                        : Colors.black.withValues(alpha: 0.6))
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.3)),
              size: 22,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.4)
                          : Colors.black.withValues(alpha: 0.3),
                      size: 22,
                    ),
                    onPressed: onTogglePassword,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
          ),
          validator: validator,
        ),
      ),
    );
  }
}
