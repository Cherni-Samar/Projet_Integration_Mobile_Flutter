import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:e_team/presentation/widgets/dexo/organization_blueprint/organization_blueprint_theme.dart';

class OrganizationBlueprintHeader extends StatelessWidget {
  const OrganizationBlueprintHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: OrganizationBlueprintTheme.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.account_tree_rounded,
            color: OrganizationBlueprintTheme.dark,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ORGANIZATION BLUEPRINT',
                style: GoogleFonts.plusJakartaSans(
                  color: OrganizationBlueprintTheme.dark,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Adjust Dexo\u2019s dynamic company structure.',
                style: GoogleFonts.plusJakartaSans(
                  color: OrganizationBlueprintTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
