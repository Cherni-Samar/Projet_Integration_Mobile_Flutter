import 'package:e_team/presentation/widgets/echo/product_marketing/echo_product_marketing_shared.dart';
import 'package:e_team/presentation/widgets/echo/product_marketing/echo_product_marketing_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EchoProductPreview extends StatelessWidget {
  const EchoProductPreview({super.key, required this.productData});

  final Map<String, dynamic>? productData;

  @override
  Widget build(BuildContext context) {
    final product = productData;
    if (product == null) return const SizedBox.shrink();

    final title = product['title'] ?? 'Unknown Product';
    final description = product['description'] ?? '';
    final price = product['price'] ?? 'N/A';
    final category = product['category'] ?? 'N/A';
    final images = product['images'] as List? ?? [];
    final features = product['features'] as List? ?? [];

    return EchoMarketingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Product Preview',
                style: GoogleFonts.inter(
                  color: EchoProductMarketingTheme.textMain,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (images.isNotEmpty)
            EchoProductImage(imageUrl: images.first.toString(), height: 200),
          const SizedBox(height: 16),
          Text(
            title.toString(),
            style: GoogleFonts.inter(
              color: EchoProductMarketingTheme.textMain,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              EchoInfoChip(
                label: price.toString(),
                backgroundColor: EchoProductMarketingTheme.violet.withValues(
                  alpha: 0.1,
                ),
                textColor: EchoProductMarketingTheme.violet,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(width: 8),
              EchoInfoChip(
                label: category.toString(),
                backgroundColor: EchoProductMarketingTheme.border,
                textColor: EchoProductMarketingTheme.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          if (description.toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              description.toString(),
              style: GoogleFonts.inter(
                color: EchoProductMarketingTheme.textMuted,
                fontSize: 12,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (features.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Features:',
              style: GoogleFonts.inter(
                color: EchoProductMarketingTheme.textMain,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...features
                .take(3)
                .map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '* ',
                          style: TextStyle(
                            color: EchoProductMarketingTheme.violet,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            feature.toString(),
                            style: GoogleFonts.inter(
                              color: EchoProductMarketingTheme.textMuted,
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}
