import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:e_team/presentation/widgets/dexo/organization_pulse/dexo_organization_pulse_theme.dart';

class DexoOrganizationPulseHero extends StatelessWidget {
  const DexoOrganizationPulseHero({
    super.key,
    required this.totalCurrent,
    required this.totalTarget,
  });

  final int totalCurrent;
  final int totalTarget;

  @override
  Widget build(BuildContext context) {
    final gap = (totalTarget - totalCurrent).clamp(0, 999);
    final progress = totalTarget == 0
        ? 0.0
        : (totalCurrent / totalTarget).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: DexoOrganizationPulseColors.dark,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: DexoOrganizationPulseColors.volt,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.account_tree_rounded,
                  color: DexoOrganizationPulseColors.dark,
                  size: 29,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$totalCurrent / $totalTarget workforce',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      gap == 0
                          ? 'Your organization matches the current vision.'
                          : 'Dexo recommends $gap additional hire(s).',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withValues(alpha: 0.68),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(
                DexoOrganizationPulseColors.volt,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
