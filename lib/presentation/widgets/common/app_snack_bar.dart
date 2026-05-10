import 'package:flutter/material.dart';

enum AppSnackBarType { success, error, info, warning }

class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    AppSnackBarType type = AppSnackBarType.info,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _colorFor(type),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: duration,
        content: Row(
          children: [
            Icon(_iconFor(type), color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        action: action,
      ),
    );
  }

  static void success(BuildContext context, String message) {
    show(context, message, type: AppSnackBarType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message, type: AppSnackBarType.error);
  }

  static void info(BuildContext context, String message) {
    show(context, message);
  }

  static void warning(BuildContext context, String message) {
    show(context, message, type: AppSnackBarType.warning);
  }

  static Color _colorFor(AppSnackBarType type) {
    switch (type) {
      case AppSnackBarType.success:
        return const Color(0xFF10B981);
      case AppSnackBarType.error:
        return const Color(0xFFEF4444);
      case AppSnackBarType.warning:
        return const Color(0xFFF59E0B);
      case AppSnackBarType.info:
        return const Color(0xFF6B7280);
    }
  }

  static IconData _iconFor(AppSnackBarType type) {
    switch (type) {
      case AppSnackBarType.success:
        return Icons.check_circle_rounded;
      case AppSnackBarType.error:
        return Icons.error_outline_rounded;
      case AppSnackBarType.warning:
        return Icons.warning_amber_rounded;
      case AppSnackBarType.info:
        return Icons.info_outline_rounded;
    }
  }
}
