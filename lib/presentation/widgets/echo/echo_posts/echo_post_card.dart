import 'package:e_team/domain/models/echo_models.dart';
import 'package:e_team/presentation/widgets/echo/echo_dashboard_helpers.dart';
import 'package:e_team/presentation/widgets/echo/echo_posts/echo_post_media.dart';
import 'package:e_team/presentation/widgets/echo/echo_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

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
          _EchoPostCardHeader(post: post),
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
          _EchoPostStatsFooter(
            post: post,
            onLoadSocialPosts: onLoadSocialPosts,
          ),
        ],
      ),
    );
  }
}

class _EchoPostCardHeader extends StatelessWidget {
  const _EchoPostCardHeader({required this.post});

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

class _EchoPostStatsFooter extends StatelessWidget {
  const _EchoPostStatsFooter({
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
            child: _EchoPostStatItem(label: 'Likes', count: post.stats.likes),
          ),
          Expanded(
            child: _EchoPostStatItem(
              label: 'Comments',
              count: post.stats.comments,
            ),
          ),
          Expanded(
            child: _EchoPostStatItem(label: 'Shares', count: post.stats.shares),
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

class _EchoPostStatItem extends StatelessWidget {
  const _EchoPostStatItem({required this.label, required this.count});

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

class EchoPlatformBadges extends StatelessWidget {
  const EchoPlatformBadges({super.key, required this.post});

  final PostItem post;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: post.platforms.map((platform) {
        final platformColor = platform.name == 'mastodon'
            ? Colors.purple
            : Colors.blue;

        return InkWell(
          onTap: () => _openPostUrl(context, platform.url),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: platformColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: platformColor, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(platform.icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  platform.name.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: platformColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.open_in_new, size: 14, color: platformColor),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _openPostUrl(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Post URL not available')));
      return;
    }

    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open post URL')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening URL: $e')));
    }
  }
}
