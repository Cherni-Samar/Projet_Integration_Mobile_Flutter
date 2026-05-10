import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:e_team/domain/models/echo/echo_models.dart';
import 'package:e_team/presentation/widgets/echo/echo_posts/echo_post_badges.dart';
import 'package:e_team/presentation/widgets/echo/echo_posts/echo_post_footer.dart';
import 'package:e_team/presentation/widgets/echo/echo_posts/echo_post_header.dart';
import 'package:e_team/presentation/widgets/echo/echo_posts/echo_post_media.dart';
import 'package:e_team/presentation/widgets/echo/echo_theme.dart';

class EchoPostCard extends StatelessWidget {
  const EchoPostCard({
    super.key,
    required this.post,
    required this.onLoadSocialPosts,
  });

  final PostItem post;
  final VoidCallback onLoadSocialPosts;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: EchoTheme.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: EchoTheme.border.withValues(alpha: 0.75),
          width: 0.7,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EchoPostCardHeader(post: post),
          if (post.image != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: EchoPostImage(post: post),
            ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              post.fullContent,
              style: GoogleFonts.inter(
                color: EchoTheme.textMain,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                height: 1.55,
              ),
            ),
          ),
          if (post.platforms.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: EchoPlatformBadges(post: post),
            ),
          const SizedBox(height: 16),
          EchoPostStatsFooter(post: post, onLoadSocialPosts: onLoadSocialPosts),
        ],
      ),
    );
  }
}
