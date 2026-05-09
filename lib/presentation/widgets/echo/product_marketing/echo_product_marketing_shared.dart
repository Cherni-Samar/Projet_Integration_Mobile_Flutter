import 'package:e_team/core/config/api_config.dart';
import 'package:e_team/presentation/widgets/echo/product_marketing/echo_product_marketing_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EchoMarketingCard extends StatelessWidget {
  const EchoMarketingCard({
    super.key,
    required this.child,
    this.margin,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: EchoProductMarketingTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EchoProductMarketingTheme.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class EchoProductImage extends StatelessWidget {
  const EchoProductImage({
    super.key,
    required this.imageUrl,
    required this.height,
    this.width = double.infinity,
    this.borderRadius = 12,
    this.errorIconSize = 48,
  });

  final String imageUrl;
  final double height;
  final double width;
  final double borderRadius;
  final double errorIconSize;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        '${ApiConfig.baseUrl}/api/echo/image-proxy?url=${Uri.encodeComponent(imageUrl)}',
        height: height,
        width: width,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: EchoProductMarketingTheme.border,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                color: EchoProductMarketingTheme.violet,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: EchoProductMarketingTheme.border,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: errorIconSize,
                  color: EchoProductMarketingTheme.textMuted,
                ),
                if (height > 80) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Image not available',
                    style: GoogleFonts.inter(
                      color: EchoProductMarketingTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class EchoInfoChip extends StatelessWidget {
  const EchoInfoChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.fontSize,
    required this.fontWeight,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: textColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}

OutlineInputBorder echoMarketingInputBorder(Color color, {double width = 0.5}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: width),
  );
}
