import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:e_team/presentation/widgets/dexo/organization_pulse/dexo_organization_pulse_theme.dart';

class DexoOrganizationEmptyState extends StatelessWidget {
  const DexoOrganizationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: DexoOrganizationPulseColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DexoOrganizationPulseColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_tree_rounded,
            size: 44,
            color: DexoOrganizationPulseColors.muted,
          ),
          const SizedBox(height: 12),
          Text(
            'No organization vision yet',
            style: GoogleFonts.plusJakartaSans(
              color: DexoOrganizationPulseColors.dark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Complete Dexo onboarding to generate your company departments.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: DexoOrganizationPulseColors.muted,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
