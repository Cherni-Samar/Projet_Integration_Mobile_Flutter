import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DexoDashboardColors {
  static const Color dexoBlue = Color(0xFF2563EB);
  static const Color dexoBlueDark = Color(0xFF1E40AF);
  static const Color dark = Color(0xFF0A0A0A);
  static const Color bg = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color blueSurface = Color(0xFFEFF6FF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color muted = Color(0xFF64748B);
  static const Color green = Color(0xFF22C55E);
}

class DexoDashboardHeader extends StatelessWidget {
  final VoidCallback onBackPressed;

  const DexoDashboardHeader({super.key, required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Row(
        children: [
          DexoDashboardRoundButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBackPressed,
          ),
          const SizedBox(width: 14),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: DexoDashboardColors.blueSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: DexoDashboardColors.dexoBlue.withValues(alpha: 0.18),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                'assets/images/dexo.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.psychology_rounded,
                  color: DexoDashboardColors.dexoBlue,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DEXO BRAIN',
                  style: GoogleFonts.plusJakartaSans(
                    color: DexoDashboardColors.dark,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: DexoDashboardColors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'STRATEGIC SUPERVISION ACTIVE',
                      style: GoogleFonts.plusJakartaSans(
                        color: DexoDashboardColors.muted,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DexoDashboardList extends StatelessWidget {
  final bool isLoading;
  final bool isAiThinking;
  final String dailyReport;
  final RefreshCallback onRefresh;
  final VoidCallback onRefreshBriefing;
  final VoidCallback onOrganizationPulsePressed;
  final VoidCallback onProductionHubPressed;

  const DexoDashboardList({
    super.key,
    required this.isLoading,
    required this.isAiThinking,
    required this.dailyReport,
    required this.onRefresh,
    required this.onRefreshBriefing,
    required this.onOrganizationPulsePressed,
    required this.onProductionHubPressed,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: DexoDashboardColors.dexoBlue,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 26),
        children: [
          const DexoBrainCard(),
          const SizedBox(height: 18),
          DexoExecutiveBriefingCard(
            isLoading: isLoading,
            isAiThinking: isAiThinking,
            dailyReport: dailyReport,
            onRefreshPressed: onRefreshBriefing,
          ),
          const SizedBox(height: 26),
          const DexoDashboardSectionTitle('DEXO COMMAND CENTER'),
          const SizedBox(height: 12),
          DexoDashboardMenuCard(
            title: 'Organization Pulse',
            subtitle: 'Adjust workforce targets and detect staffing gaps.',
            icon: Icons.account_tree_rounded,
            isPrimary: true,
            onTap: onOrganizationPulsePressed,
          ),
          DexoDashboardMenuCard(
            title: 'Production Hub',
            subtitle: 'Documents, generated outputs and execution logs.',
            icon: Icons.factory_rounded,
            onTap: onProductionHubPressed,
          ),
        ],
      ),
    );
  }
}

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
  final bool isLoading;
  final bool isAiThinking;
  final String dailyReport;
  final VoidCallback onRefreshPressed;

  const DexoExecutiveBriefingCard({
    super.key,
    required this.isLoading,
    required this.isAiThinking,
    required this.dailyReport,
    required this.onRefreshPressed,
  });

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
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const DexoDashboardMenuCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

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

class DexoDashboardSectionTitle extends StatelessWidget {
  final String text;

  const DexoDashboardSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        color: DexoDashboardColors.dark,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }
}

class DexoDashboardRoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const DexoDashboardRoundButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: DexoDashboardColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: DexoDashboardColors.dark, size: 18),
      ),
    );
  }
}
