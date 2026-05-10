import 'package:flutter/material.dart';

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
