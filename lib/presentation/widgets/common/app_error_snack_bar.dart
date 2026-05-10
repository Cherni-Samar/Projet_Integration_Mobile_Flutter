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
import 'package:e_team/presentation/widgets/common/app_snack_bar.dart';

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
    AppSnackBar.show(
      context,
      error.message,
      type: _snackBarTypeFor(error.type),
      duration: const Duration(seconds: 4),
      action: _shouldShowRetry(error.type) && onRetry != null
          ? SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static AppSnackBarType _snackBarTypeFor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return AppSnackBarType.error;
      case ErrorType.server:
        return AppSnackBarType.warning;
      case ErrorType.auth:
        return AppSnackBarType.info;
      case ErrorType.mutation:
        return AppSnackBarType.error;
      case ErrorType.unknown:
        return AppSnackBarType.info;
    }
  }

  static bool _shouldShowRetry(ErrorType type) {
    return type == ErrorType.network || type == ErrorType.server;
  }
}
