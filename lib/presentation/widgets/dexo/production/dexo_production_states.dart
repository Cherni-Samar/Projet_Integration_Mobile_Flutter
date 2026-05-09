import 'package:e_team/presentation/widgets/dexo/production/dexo_production_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DexoProductionEmptyState extends StatelessWidget {
  const DexoProductionEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: DexoProductionTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DexoProductionTheme.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_rounded,
            size: 44,
            color: DexoProductionTheme.muted,
          ),
          const SizedBox(height: 12),
          Text(
            'No production logs found',
            style: GoogleFonts.plusJakartaSans(
              color: DexoProductionTheme.dark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try changing the filters or swipe down to refresh.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: DexoProductionTheme.muted,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
