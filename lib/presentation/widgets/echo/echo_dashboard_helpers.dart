import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'echo_theme.dart';

String formatEchoRelativeTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inDays > 0) return '${diff.inDays}d ago';
  if (diff.inHours > 0) return '${diff.inHours}h ago';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
  return 'now';
}

class EchoDashboardEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EchoDashboardEmptyState({
    super.key,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(icon, size: 48, color: EchoTheme.textMuted),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.inter(
              color: EchoTheme.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
