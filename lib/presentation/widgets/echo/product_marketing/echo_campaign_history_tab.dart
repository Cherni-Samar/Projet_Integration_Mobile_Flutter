import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:e_team/presentation/widgets/echo/product_marketing/echo_campaign_history_card.dart';
import 'package:e_team/presentation/widgets/echo/product_marketing/echo_product_marketing_theme.dart';

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
