import 'package:e_team/presentation/widgets/timo/timo_design_system.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimoStatsCard extends StatelessWidget {
  final int interviews;
  final int onboardings;
  final int offboardings;
  final int done;
  final int total;

  const TimoStatsCard({
    super.key,
    required this.interviews,
    required this.onboardings,
    required this.offboardings,
    required this.done,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : done / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TimoDesignSystem.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TimoDesignSystem.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: TimoDesignSystem.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TimoStatItem(
                  value: '$interviews',
                  label: 'INTERVIEWS',
                  color: TimoDesignSystem.interview,
                  icon: Icons.record_voice_over_rounded,
                ),
              ),
              Container(width: 1, height: 50, color: TimoDesignSystem.border),
              Expanded(
                child: TimoStatItem(
                  value: '$onboardings',
                  label: 'ONBOARDINGS',
                  color: TimoDesignSystem.onboarding,
                  icon: Icons.person_add_alt_1_rounded,
                ),
              ),
              Container(width: 1, height: 50, color: TimoDesignSystem.border),
              Expanded(
                child: TimoStatItem(
                  value: '$offboardings',
                  label: 'OFFBOARDINGS',
                  color: TimoDesignSystem.offboarding,
                  icon: Icons.exit_to_app_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Complétés',
                style: GoogleFonts.plusJakartaSans(
                  color: TimoDesignSystem.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '$done / $total',
                style: GoogleFonts.plusJakartaSans(
                  color: pct > 0.7
                      ? TimoDesignSystem.success
                      : TimoDesignSystem.other,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 7,
              backgroundColor: TimoDesignSystem.border,
              valueColor: AlwaysStoppedAnimation(
                pct > 0.7 ? TimoDesignSystem.success : TimoDesignSystem.other,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimoStatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const TimoStatItem({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: TimoDesignSystem.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            color: TimoDesignSystem.textMuted,
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}
