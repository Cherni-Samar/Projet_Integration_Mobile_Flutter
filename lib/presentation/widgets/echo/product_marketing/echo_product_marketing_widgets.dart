import 'package:e_team/core/config/api_config.dart';
import 'package:e_team/presentation/widgets/echo/product_marketing/echo_product_marketing_helpers.dart';
import 'package:e_team/presentation/widgets/echo/product_marketing/echo_product_marketing_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EchoProductMarketingHeader extends StatelessWidget {
  const EchoProductMarketingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            EchoProductMarketingTheme.violet,
            EchoProductMarketingTheme.violet.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Automated Marketing',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Generate posts every 3 days automatically',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EchoProductUrlInput extends StatelessWidget {
  const EchoProductUrlInput({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onAnalyze,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    return _MarketingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.link,
                color: EchoProductMarketingTheme.violet,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Product URL',
                style: GoogleFonts.inter(
                  color: EchoProductMarketingTheme.textMain,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'https://www.amazon.com/product...',
              hintStyle: GoogleFonts.inter(
                color: EchoProductMarketingTheme.textMuted,
                fontSize: 13,
              ),
              filled: true,
              fillColor: EchoProductMarketingTheme.bg,
              border: _inputBorder(EchoProductMarketingTheme.border),
              enabledBorder: _inputBorder(EchoProductMarketingTheme.border),
              focusedBorder: _inputBorder(
                EchoProductMarketingTheme.violet,
                width: 1,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: GoogleFonts.inter(
              color: EchoProductMarketingTheme.textMain,
              fontSize: 13,
            ),
            maxLines: 3,
            minLines: 1,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onAnalyze,
              style: ElevatedButton.styleFrom(
                backgroundColor: EchoProductMarketingTheme.violet,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Analyze Product',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
}

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

    return _MarketingCard(
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
            _ProductImage(imageUrl: images.first.toString(), height: 200),
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
              _InfoChip(
                label: price.toString(),
                backgroundColor: EchoProductMarketingTheme.violet.withValues(
                  alpha: 0.1,
                ),
                textColor: EchoProductMarketingTheme.violet,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(width: 8),
              _InfoChip(
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

class EchoStartCampaignButton extends StatelessWidget {
  const EchoStartCampaignButton({
    super.key,
    required this.isStartingCampaign,
    required this.onStart,
  });

  final bool isStartingCampaign;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isStartingCampaign ? null : onStart,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isStartingCampaign
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.rocket_launch, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Start Marketing Campaign',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class EchoCampaignHistoryTab extends StatelessWidget {
  const EchoCampaignHistoryTab({
    super.key,
    required this.isLoading,
    required this.campaigns,
    required this.onRefresh,
    required this.onManageCampaign,
  });

  final bool isLoading;
  final List<Map<String, dynamic>> campaigns;
  final Future<void> Function() onRefresh;
  final VoidCallback onManageCampaign;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: EchoProductMarketingTheme.violet,
        ),
      );
    }

    if (campaigns.isEmpty) {
      return const _EmptyCampaignHistory();
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: campaigns.length,
        itemBuilder: (context, index) {
          return EchoCampaignHistoryCard(
            campaign: campaigns[index],
            onManage: onManageCampaign,
          );
        },
      ),
    );
  }
}

class EchoCampaignHistoryCard extends StatelessWidget {
  const EchoCampaignHistoryCard({
    super.key,
    required this.campaign,
    required this.onManage,
  });

  final Map<String, dynamic> campaign;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final productTitle = campaign['productTitle'] ?? 'Unknown Product';
    final productImage = campaign['productImage'];
    final productPrice = campaign['productPrice'] ?? 'N/A';
    final status = campaign['status'] ?? 'unknown';
    final frequency = campaign['frequency'] ?? 'N/A';
    final postsGenerated = campaign['postsGenerated'] ?? 0;
    final createdAt = campaign['createdAt'] != null
        ? DateTime.tryParse(campaign['createdAt'].toString())
        : null;
    final statusStyle = _CampaignStatusStyle.fromStatus(status.toString());

    return _MarketingCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  productTitle.toString(),
                  style: GoogleFonts.inter(
                    color: EchoProductMarketingTheme.textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _StatusChip(style: statusStyle),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (productImage != null)
                _ProductImage(
                  imageUrl: productImage.toString(),
                  height: 60,
                  width: 60,
                  borderRadius: 8,
                  errorIconSize: 24,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CampaignMetricRow(
                      icon: Icons.attach_money,
                      iconColor: EchoProductMarketingTheme.violet,
                      text: productPrice.toString(),
                      textColor: EchoProductMarketingTheme.textMain,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 4),
                    _CampaignMetricRow(
                      icon: Icons.schedule,
                      text: formatCampaignFrequency(frequency.toString()),
                    ),
                    const SizedBox(height: 4),
                    _CampaignMetricRow(
                      icon: Icons.article,
                      text: '$postsGenerated posts',
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (createdAt != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: EchoProductMarketingTheme.border),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: EchoProductMarketingTheme.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  'Created ${formatCampaignDate(createdAt)}',
                  style: GoogleFonts.inter(
                    color: EchoProductMarketingTheme.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
          if (status == 'active') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onManage,
                style: OutlinedButton.styleFrom(
                  foregroundColor: EchoProductMarketingTheme.violet,
                  side: const BorderSide(
                    color: EchoProductMarketingTheme.violet,
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Manage Campaign',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyCampaignHistory extends StatelessWidget {
  const _EmptyCampaignHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: EchoProductMarketingTheme.violet.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history,
                size: 48,
                color: EchoProductMarketingTheme.violet.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Campaign History',
              style: GoogleFonts.inter(
                color: EchoProductMarketingTheme.textMuted,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your campaign history will appear here',
              style: GoogleFonts.inter(
                color: EchoProductMarketingTheme.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
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

class _MarketingCard extends StatelessWidget {
  const _MarketingCard({
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.style});

  final _CampaignStatusStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        style.label,
        style: GoogleFonts.inter(
          color: style.color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CampaignMetricRow extends StatelessWidget {
  const _CampaignMetricRow({
    required this.icon,
    required this.text,
    this.iconColor = EchoProductMarketingTheme.textMuted,
    this.textColor = EchoProductMarketingTheme.textMuted,
    this.fontWeight,
  });

  final IconData icon;
  final String text;
  final Color iconColor;
  final Color textColor;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: fontWeight == null ? 11 : 12,
            fontWeight: fontWeight,
          ),
        ),
      ],
    );
  }
}

class _CampaignStatusStyle {
  const _CampaignStatusStyle({required this.color, required this.label});

  factory _CampaignStatusStyle.fromStatus(String status) {
    switch (status) {
      case 'active':
        return const _CampaignStatusStyle(color: Colors.green, label: 'ACTIVE');
      case 'paused':
        return const _CampaignStatusStyle(
          color: Colors.orange,
          label: 'PAUSED',
        );
      case 'stopped':
        return const _CampaignStatusStyle(color: Colors.red, label: 'STOPPED');
      default:
        return const _CampaignStatusStyle(color: Colors.grey, label: 'UNKNOWN');
    }
  }

  final Color color;
  final String label;
}

OutlineInputBorder _inputBorder(Color color, {double width = 0.5}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: width),
  );
}
