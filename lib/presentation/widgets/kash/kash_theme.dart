import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
//  PALETTE KASH - Teal/Green scheme matching Timo's design
// ─────────────────────────────────────────────────────────────
class KP {
  static const primary   = Color(0xFF008B8B);  // Deep teal
  static const primaryD  = Color(0xFF006666);  // Darker teal
  static const accent    = Color(0xFF20B2AA);  // Light sea green
  static const success   = Color(0xFF10B981);
  static const danger    = Color(0xFFEF4444);
  static const warning   = Color(0xFFFB923C);

  static Color bg(bool d)        => d ? const Color(0xFF0A0A0A) : const Color(0xFFF5F3F0);
  static Color card(bool d)      => d ? const Color(0xFF141414) : Colors.white;
  static Color cardSoft(bool d)  => d ? const Color(0xFF1C1C1C) : const Color(0xFFEEEBE7);
  static Color border(bool d)    => d ? const Color(0xFF252525) : const Color(0xFFE0DBD4);
  static Color text(bool d)      => d ? Colors.white            : const Color(0xFF1A1008);
  static Color textMuted(bool d) => d ? const Color(0xFF777777) : const Color(0xFF8B7D6E);
  static Color textSoft(bool d)  => d ? const Color(0xFF444444) : const Color(0xFFB5A99A);
}
