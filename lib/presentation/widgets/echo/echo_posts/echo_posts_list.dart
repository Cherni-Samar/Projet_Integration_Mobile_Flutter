import 'package:e_team/domain/models/echo_models.dart';
import 'package:e_team/presentation/widgets/common/app_loading.dart';
import 'package:e_team/presentation/widgets/echo/echo_posts/echo_post_card_view.dart';
import 'package:e_team/presentation/widgets/echo/echo_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EchoPostsList extends StatelessWidget {
  const EchoPostsList({
    super.key,
    required this.loadingSocial,
    required this.posts,
    required this.onLoadSocialPosts,
  });

  final bool loadingSocial;
  final List<PostItem> posts;
  final VoidCallback onLoadSocialPosts;

  @override
  Widget build(BuildContext context) {
    if (loadingSocial) {
      return const AppLoadingState(color: EchoTheme.violet);
    }

    if (posts.isEmpty) {
      return const _EchoEmptyPostsState();
    }

    return RefreshIndicator(
      onRefresh: () async => onLoadSocialPosts(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: posts.length,
        itemBuilder: (context, index) => EchoPostCard(
          post: posts[index],
          onLoadSocialPosts: onLoadSocialPosts,
        ),
      ),
    );
  }
}

class _EchoEmptyPostsState extends StatelessWidget {
  const _EchoEmptyPostsState();

  @override
  Widget build(BuildContext context) {
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
}
