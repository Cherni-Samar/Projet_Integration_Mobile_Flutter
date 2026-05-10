import 'package:flutter/material.dart';

import 'package:e_team/domain/models/user_model.dart';

InputDecoration editProfileInputDecoration({
  required String hintText,
  required IconData icon,
  required bool isDark,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(
      color: isDark
          ? Colors.white.withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.3),
    ),
    filled: true,
    fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    prefixIcon: Icon(
      icon,
      color: isDark
          ? Colors.white.withValues(alpha: 0.5)
          : Colors.black.withValues(alpha: 0.5),
    ),
    suffixIcon: suffixIcon,
  );
}

String editProfileInitial(User user) {
  final name = user.name;
  if (name != null && name.isNotEmpty) {
    return name.substring(0, 1).toUpperCase();
  }

  return user.email.substring(0, 1).toUpperCase();
}
