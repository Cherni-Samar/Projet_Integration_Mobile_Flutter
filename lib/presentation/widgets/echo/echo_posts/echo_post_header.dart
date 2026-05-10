import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:e_team/domain/models/echo_models.dart';
import 'package:e_team/presentation/widgets/echo/echo_dashboard_helpers.dart';
import 'package:e_team/presentation/widgets/echo/echo_theme.dart';

class EchoPostCardHeader extends StatelessWidget {
  const EchoPostCardHeader({super.key, required this.post});

  final PostItem post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Echo Agent',
                  style: GoogleFonts.inter(
                    color: EchoTheme.textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  formatEchoRelativeTime(post.createdAt),
                  style: GoogleFonts.inter(
                    color: EchoTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: EchoTheme.violet.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'AI POST',
              style: GoogleFonts.inter(
                color: EchoTheme.violet,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
