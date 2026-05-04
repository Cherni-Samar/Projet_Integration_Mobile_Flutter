/// Centralized SnackBar factory for [AppError] display.
///
/// Usage:
///   AppErrorSnackBar.show(context, error);
///
/// Rules:
///   - One place to change error UX for the whole app
///   - Adapts icon and color to [ErrorType]
///   - Provides a retry action for network errors
library;

import 'package:flutter/material.dart';

import 'package:e_team/core/errors/app_error.dart';

class AppErrorSnackBar {
  AppErrorSnackBar._();

  /// Show a styled SnackBar for [error].
  ///
  /// [onRetry] is shown as an action button for [ErrorType.network] and
  /// [ErrorType.server] errors. Pass null to suppress the action.
  static void show(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
  }) {
    // Dismiss any existing SnackBar before showing the new one
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final color = _colorFor(error.type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Icon(error.icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                error.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        action: _shouldShowRetry(error.type) && onRetry != null
            ? SnackBarAction(
                label: 'Réessayer',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static Color _colorFor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return const Color(0xFFEF4444); // red
      case ErrorType.server:
        return const Color(0xFFF97316); // orange
      case ErrorType.auth:
        return const Color(0xFF7C3AED); // purple
      case ErrorType.mutation:
        return const Color(0xFFEF4444); // red
      case ErrorType.unknown:
        return const Color(0xFF6B7280); // grey
    }
  }

  static bool _shouldShowRetry(ErrorType type) {
    return type == ErrorType.network || type == ErrorType.server;
  }
}
