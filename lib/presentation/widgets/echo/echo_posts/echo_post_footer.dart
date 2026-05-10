import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:e_team/domain/models/echo/echo_models.dart';
import 'package:e_team/presentation/widgets/echo/echo_theme.dart';

class EchoPostStatsFooter extends StatelessWidget {
  const EchoPostStatsFooter({
    super.key,
    required this.post,
    required this.onLoadSocialPosts,
  });

  final PostItem post;
  final VoidCallback onLoadSocialPosts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: EchoTheme.border.withValues(alpha: 0.7)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: EchoPostStatItem(label: 'Likes', count: post.stats.likes),
          ),
          Expanded(
            child: EchoPostStatItem(
              label: 'Comments',
              count: post.stats.comments,
            ),
          ),
          Expanded(
            child: EchoPostStatItem(label: 'Shares', count: post.stats.shares),
          ),
          GestureDetector(
            onTap: onLoadSocialPosts,
            child: Icon(
              Icons.refresh_rounded,
              color: EchoTheme.textMuted,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class EchoPostStatItem extends StatelessWidget {
  const EchoPostStatItem({super.key, required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: EchoTheme.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          count.toString(),
          style: GoogleFonts.inter(
            color: EchoTheme.textMain,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
