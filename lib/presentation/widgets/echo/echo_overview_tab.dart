import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:e_team/domain/models/echo_models.dart';
import 'package:e_team/presentation/widgets/common/app_loading.dart';
import 'echo_dashboard_helpers.dart';
import 'echo_theme.dart';

/// Overview tab for Echo dashboard showing recent communications
class EchoOverviewTab extends StatelessWidget {
  final bool loadingEmails;
  final List<EmailItem> recentEmails;

  const EchoOverviewTab({
    super.key,
    required this.loadingEmails,
    required this.recentEmails,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildSectionTitle('LATEST COMMUNICATIONS'),
          const SizedBox(height: 16),
          _buildRecentActivityCards(),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCards() {
    if (loadingEmails) {
      return const AppLoadingState(color: EchoTheme.violet);
    }

    final recent = recentEmails.take(3).toList();

    if (recent.isEmpty) {
      return const EchoDashboardEmptyState(
        message: 'No recent communications',
        icon: Icons.inbox_outlined,
      );
    }

    return Column(
      children: recent.map((email) => _buildActivityCard(email)).toList(),
    );
  }

  Widget _buildActivityCard(EmailItem email) {
    final bool isRecruitment = email.subject.toLowerCase().contains(
      'recrutement',
    );
    final bool isApproved = email.subject.toLowerCase().contains('validé');
    final bool isFromHera = email.sender.contains('hera@e-team.com');

    final Color accentColor = isApproved
        ? Colors.green
        : isRecruitment
        ? Colors.orange
        : EchoTheme.violet;

    final IconData icon = isApproved
        ? Icons.check_circle_rounded
        : isRecruitment
        ? Icons.campaign_rounded
        : Icons.mail_rounded;

    final String badge = isApproved
        ? 'APPROVED'
        : email.isUrgent
        ? 'URGENT'
        : 'INFO';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: EchoTheme.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.22),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
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
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFromHera ? 'Hera → Echo' : 'Incoming communication',
                  style: GoogleFonts.inter(
                    color: EchoTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email.subject,
                  style: GoogleFonts.inter(
                    color: EchoTheme.textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  email.summary.isNotEmpty
                      ? email.summary
                      : 'Echo processed this communication automatically.',
                  style: GoogleFonts.inter(
                    color: EchoTheme.textMuted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.inter(
                    color: accentColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                formatEchoRelativeTime(email.receivedAt),
                style: GoogleFonts.inter(
                  color: EchoTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        color: EchoTheme.violet,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }
}
