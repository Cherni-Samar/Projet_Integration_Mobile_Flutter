/// Centralized error model used across all providers.
///
/// [ErrorType] classifies the failure so the UI can react appropriately
/// (e.g. show a retry button for network errors, a different icon for auth).
///
/// [AppError] is immutable and carries a human-readable [message] plus the
/// raw [source] exception for debugging.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Icons, IconData;

/// Classifies the origin of a failure.
enum ErrorType {
  /// No network connection or request timed out.
  network,

  /// Server returned a 4xx / 5xx status.
  server,

  /// The user's session has expired or is invalid.
  auth,

  /// A mutation (delete, update, create) failed.
  mutation,

  /// Catch-all for unexpected failures.
  unknown,
}

/// Immutable error value object.
@immutable
class AppError {
  /// Human-readable message shown in the UI.
  final String message;

  /// Classifies the failure for UI branching.
  final ErrorType type;

  /// The raw exception, kept for logging / debugging.
  final Object? source;

  const AppError({
    required this.message,
    required this.type,
    this.source,
  });

  // ─── Named constructors ───────────────────────────────────────────────────

  /// Network / connectivity failure.
  const AppError.network({Object? source})
      : message = 'Connexion impossible. Vérifiez votre réseau.',
        type = ErrorType.network,
        source = source;

  /// Generic server-side failure with an optional backend message.
  AppError.server(String? detail, {Object? source})
      : message = (detail != null && detail.isNotEmpty)
            ? detail
            : 'Une erreur serveur est survenue.',
        type = ErrorType.server,
        source = source;

  /// Auth / session failure.
  const AppError.auth({Object? source})
      : message = 'Session expirée. Veuillez vous reconnecter.',
        type = ErrorType.auth,
        source = source;

  /// Mutation failure (delete, update, create).
  AppError.mutation(String? detail, {Object? source})
      : message = (detail != null && detail.isNotEmpty)
            ? detail
            : "L'opération a échoué. Réessayez.",
        type = ErrorType.mutation,
        source = source;

  /// Unknown / unexpected failure.
  AppError.unknown(Object? source)
      : message = 'Une erreur inattendue est survenue.',
        type = ErrorType.unknown,
        source = source;

  /// Inspect [e] and return the most appropriate [AppError].
  factory AppError.from(Object e) {
    final msg = e.toString().toLowerCase();

    // HTTP status codes surfaced by ApiService as "HTTP 4xx / 5xx: ..."
    if (msg.contains('http 401') || msg.contains('http 403')) {
      return AppError.auth(source: e);
    }
    if (msg.contains('http ')) {
      final detail = _extractDetail(e.toString());
      return AppError.server(detail, source: e);
    }

    // Network / socket errors
    if (msg.contains('socketexception') ||
        msg.contains('connection refused') ||
        msg.contains('network') ||
        msg.contains('timeout') ||
        msg.contains('host lookup')) {
      return AppError.network(source: e);
    }

    return AppError.unknown(e);
  }

  static String? _extractDetail(String raw) {
    final idx = raw.indexOf(':');
    if (idx == -1 || idx == raw.length - 1) return null;
    final detail = raw.substring(idx + 1).trim();
    return detail.isEmpty ? null : detail;
  }

  // ─── Icon helper for UI ───────────────────────────────────────────────────

  /// Returns a Material icon that matches the error type.
  IconData get icon {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off_rounded;
      case ErrorType.server:
        return Icons.cloud_off_rounded;
      case ErrorType.auth:
        return Icons.lock_outline_rounded;
      case ErrorType.mutation:
        return Icons.error_outline_rounded;
      case ErrorType.unknown:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  String toString() => 'AppError($type): $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppError && type == other.type && message == other.message;

  @override
  int get hashCode => Object.hash(type, message);
}
