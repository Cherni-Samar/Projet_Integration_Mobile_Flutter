import 'package:e_team/domain/models/echo/echo_models.dart';
import 'package:e_team/presentation/widgets/echo/echo_posts/echo_posts_header.dart';
import 'package:e_team/presentation/widgets/echo/echo_posts/echo_posts_list.dart';
import 'package:flutter/material.dart';

class EchoPostsTab extends StatelessWidget {
  const EchoPostsTab({
    super.key,
    required this.loadingSocial,
    required this.posts,
    this.token,
    required this.onLoadSocialPosts,
    required this.onLaunchCampaign,
  });

  final bool loadingSocial;
  final List<PostItem> posts;
  final String? token;
  final VoidCallback onLoadSocialPosts;
  final VoidCallback onLaunchCampaign;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFFFF),
      child: Column(
        children: [
          EchoPostsHeader(
            postCount: posts.length,
            token: token,
            onLaunchCampaign: onLaunchCampaign,
          ),
          Expanded(
            child: EchoPostsList(
              loadingSocial: loadingSocial,
              posts: posts,
              onLoadSocialPosts: onLoadSocialPosts,
            ),
          ),
        ],
      ),
    );
  }
}
