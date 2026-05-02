import 'package:flutter/material.dart';

/// Single source of truth for the E-Team design system colors.
///
/// Usage: import 'package:e_team/core/theme/app_colors.dart';
///
/// Phase 2: Base app colors only (from main.dart ThemeData).
/// Phase 3+: Agent palette classes will be migrated here one by one.
class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────
  static const Color volt = Color(0xFFCDFF00);
  static const Color voltDark = Color(0xFFAADD00);
  static const Color violet = Color(0xFFA855F7);

  // ── Light theme ────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Colors.white;
  static const Color lightPrimary = Colors.black;

  // ── Dark theme ─────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF1A1A1A);
  static const Color darkPrimary = Color(0xFFCDFF00);

  // ── Semantic ───────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
}
