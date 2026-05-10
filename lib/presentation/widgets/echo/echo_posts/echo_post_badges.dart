import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:e_team/domain/models/echo_models.dart';

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
