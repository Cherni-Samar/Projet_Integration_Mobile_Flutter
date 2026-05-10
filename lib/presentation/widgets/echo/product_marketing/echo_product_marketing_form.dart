import 'package:e_team/presentation/widgets/common/app_loading.dart';
import 'package:e_team/presentation/widgets/echo/product_marketing/echo_product_marketing_shared.dart';
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
    return EchoMarketingCard(
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
              border: echoMarketingInputBorder(
                EchoProductMarketingTheme.border,
              ),
              enabledBorder: echoMarketingInputBorder(
                EchoProductMarketingTheme.border,
              ),
              focusedBorder: echoMarketingInputBorder(
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
                      child: AppLoadingIndicator(
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
                child: AppLoadingIndicator(
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
