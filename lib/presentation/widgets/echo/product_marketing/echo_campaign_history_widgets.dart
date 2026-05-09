import 'package:e_team/presentation/widgets/echo/product_marketing/echo_product_marketing_helpers.dart';
import 'package:e_team/presentation/widgets/echo/product_marketing/echo_product_marketing_shared.dart';
import 'package:e_team/presentation/widgets/echo/product_marketing/echo_product_marketing_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

    return EchoMarketingCard(
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
                EchoProductImage(
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
