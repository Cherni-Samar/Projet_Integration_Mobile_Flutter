import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      primaryColor: AppColors.lightPrimary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimary,
        secondary: AppColors.volt,
        tertiary: AppColors.violet,
      ),
      inputDecorationTheme: _inputDecorationTheme(
        fillColor: AppColors.lightSurface,
        focusedColor: AppColors.volt,
      ),
      elevatedButtonTheme: _elevatedButtonTheme(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.volt,
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.darkPrimary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.volt,
        secondary: AppColors.volt,
        tertiary: AppColors.violet,
      ),
      cardColor: AppColors.darkSurface,
      inputDecorationTheme: _inputDecorationTheme(
        fillColor: AppColors.darkSurface,
        focusedColor: AppColors.volt,
      ),
      elevatedButtonTheme: _elevatedButtonTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightPrimary,
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme({
    required Color fillColor,
    required Color focusedColor,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      border: _inputBorder(),
      enabledBorder: _inputBorder(),
      focusedBorder: _inputBorder(color: focusedColor, width: 2),
      errorBorder: _inputBorder(color: AppColors.danger),
      focusedErrorBorder: _inputBorder(color: AppColors.danger, width: 2),
    );
  }

  static OutlineInputBorder _inputBorder({Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: color == null
          ? BorderSide.none
          : BorderSide(color: color, width: width),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme({
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
