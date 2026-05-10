import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:e_team/presentation/widgets/dexo/dashboard/dexo_dashboard_theme.dart';

class DexoBrainCard extends StatelessWidget {
  const DexoBrainCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            DexoDashboardColors.dexoBlue,
            DexoDashboardColors.dexoBlueDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: DexoDashboardColors.dexoBlue.withValues(alpha: 0.24),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: const Icon(
              Icons.psychology_alt_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Strategic layer online',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Dexo monitors your organization, detects workforce drift and supervises execution.',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 12,
                    height: 1.45,
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

class DexoExecutiveBriefingCard extends StatelessWidget {
  const DexoExecutiveBriefingCard({
    super.key,
    required this.isLoading,
    required this.isAiThinking,
    required this.dailyReport,
    required this.onRefreshPressed,
  });

  final bool isLoading;
  final bool isAiThinking;
  final String dailyReport;
  final VoidCallback onRefreshPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DexoDashboardColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: DexoDashboardColors.blueSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: DexoDashboardColors.dexoBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Executive Briefing',
                  style: GoogleFonts.plusJakartaSans(
                    color: DexoDashboardColors.dark,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: onRefreshPressed,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                color: DexoDashboardColors.dexoBlue,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading || isAiThinking)
            const LinearProgressIndicator(color: DexoDashboardColors.dexoBlue)
          else
            Text(
              dailyReport.replaceAll('*', '').trim(),
              style: GoogleFonts.plusJakartaSans(
                color: DexoDashboardColors.muted,
                fontSize: 13,
                height: 1.65,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class DexoDashboardMenuCard extends StatelessWidget {
  const DexoDashboardMenuCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isPrimary ? DexoDashboardColors.blueSurface : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isPrimary
                    ? DexoDashboardColors.dexoBlue
                    : DexoDashboardColors.border,
                width: isPrimary ? 1.4 : 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      (isPrimary ? DexoDashboardColors.dexoBlue : Colors.black)
                          .withValues(alpha: isPrimary ? 0.08 : 0.035),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? DexoDashboardColors.dexoBlue
                        : DexoDashboardColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: isPrimary ? Colors.white : DexoDashboardColors.dark,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          color: DexoDashboardColors.dark,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          color: DexoDashboardColors.muted,
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isPrimary
                      ? DexoDashboardColors.dexoBlue
                      : DexoDashboardColors.dark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
