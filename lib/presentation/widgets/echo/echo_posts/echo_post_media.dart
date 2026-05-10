import 'package:e_team/presentation/widgets/common/app_loading.dart';
import 'package:e_team/core/config/api_config.dart';
import 'package:e_team/domain/models/echo_models.dart';
import 'package:e_team/presentation/widgets/echo/echo_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EchoPostImage extends StatelessWidget {
  const EchoPostImage({super.key, required this.post});

  final PostItem post;

  @override
  Widget build(BuildContext context) {
    if (post.image == null || post.image!.url.isEmpty) {
      return const SizedBox.shrink();
    }

    final imageUrl = '${ApiConfig.baseUrl}${post.image!.url}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  child: AppLoadingIndicator(
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
        if (post.image!.type == 'ai-generated') const _EchoAiImageBadge(),
      ],
    );
  }
}

class _EchoAiImageBadge extends StatelessWidget {
  const _EchoAiImageBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
