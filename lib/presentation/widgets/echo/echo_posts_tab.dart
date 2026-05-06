import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:e_team/domain/models/echo_models.dart';
import 'package:e_team/core/config/api_config.dart';
import 'echo_theme.dart';
import 'package:e_team/presentation/screens/agent/echo/product_marketing_screen.dart';

/// Posts tab for Echo dashboard showing AI-generated social media posts
class EchoPostsTab extends StatelessWidget {
  final bool loadingSocial;
  final List<PostItem> posts;
  final String? token;
  final String Function(DateTime time) formatTime;
  final VoidCallback onLoadSocialPosts;
  final VoidCallback onLaunchCampaign;

  const EchoPostsTab({
    super.key,
    required this.loadingSocial,
    required this.posts,
    this.token,
    required this.formatTime,
    required this.onLoadSocialPosts,
    required this.onLaunchCampaign,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFFFF),
      child: Column(
        children: [
          _buildPostsHeader(context),
          Expanded(child: _buildPostsList()),
        ],
      ),
    );
  }

  Widget _buildPostsHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Social Media Studio',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AI-generated posts, campaigns and engagement tracking',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  '${posts.length} POSTS',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductMarketingScreen(token: token),
                  ),
                );
                if (result == true) {
                  onLaunchCampaign();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: EchoTheme.violet,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.campaign_rounded, size: 19),
                  const SizedBox(width: 8),
                  Text(
                    'Launch Product Campaign',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    if (loadingSocial) {
      return const Center(
        child: CircularProgressIndicator(color: EchoTheme.violet),
      );
    }

    if (posts.isEmpty) {
      return _buildEmptyPostsState();
    }

    return RefreshIndicator(
      onRefresh: () async => onLoadSocialPosts(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: posts.length,
        itemBuilder: (context, index) => _buildPostCard(context, posts[index]),
      ),
    );
  }

  Widget _buildEmptyPostsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  EchoTheme.violet.withValues(alpha: 0.14),
                  EchoTheme.violet.withValues(alpha: 0.06),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 44,
              color: EchoTheme.violet.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'No social posts yet',
            style: GoogleFonts.inter(
              color: EchoTheme.textMain,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a product campaign and Echo will generate posts automatically.',
            style: GoogleFonts.inter(
              color: EchoTheme.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, PostItem post) {
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
          Padding(
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
                        formatTime(post.createdAt),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
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
          ),

          if (post.image != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _buildPostImage(post),
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
              child: _buildPlatformBadges(context, post),
            ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(color: EchoTheme.border.withValues(alpha: 0.7)),
              ),
            ),
            child: Row(
              children: [
                Expanded(child: _buildStatItem('👍', post.stats.likes)),
                Expanded(child: _buildStatItem('💬', post.stats.comments)),
                Expanded(child: _buildStatItem('🔄', post.stats.shares)),
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
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage(PostItem post) {
    if (post.image == null || post.image!.url.isEmpty) {
      return const SizedBox.shrink();
    }

    // Construct full image URL
    final String imageUrl = '${ApiConfig.baseUrl}${post.image!.url}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    color: EchoTheme.violet,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Image badge (AI-generated or Original)
        if (post.image!.type == 'ai-generated')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, size: 14, color: Colors.purple),
                const SizedBox(width: 4),
                Text(
                  'AI Generated',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.purple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPlatformBadges(BuildContext context, PostItem post) {
    return Wrap(
      spacing: 8,
      children: post.platforms.map((platform) {
        return InkWell(
          onTap: () => _openPostUrl(context, platform.url),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: platform.name == 'mastodon'
                  ? Colors.purple.withValues(alpha: 0.1)
                  : Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: platform.name == 'mastodon'
                    ? Colors.purple
                    : Colors.blue,
                width: 1,
              ),
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
                    color: platform.name == 'mastodon'
                        ? Colors.purple
                        : Colors.blue,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.open_in_new,
                  size: 14,
                  color: platform.name == 'mastodon'
                      ? Colors.purple
                      : Colors.blue,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Method to open URL
  Future<void> _openPostUrl(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Post URL not available')));
      return;
    }

    final Uri uri = Uri.parse(url);
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

  Widget _buildStatItem(String emoji, int count) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
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
