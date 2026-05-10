import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:e_team/presentation/widgets/dexo/organization_pulse/dexo_organization_pulse_theme.dart';

class DexoOrganizationPulseHeader extends StatelessWidget {
  const DexoOrganizationPulseHeader({
    super.key,
    required this.isSaving,
    required this.onBackPressed,
  });

  final bool isSaving;
  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Row(
        children: [
          DexoOrganizationRoundButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBackPressed,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Organization Pulse',
              style: GoogleFonts.plusJakartaSans(
                color: DexoOrganizationPulseColors.dark,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: isSaving
                ? Text(
                    'Saving...',
                    key: const ValueKey('saving'),
                    style: GoogleFonts.plusJakartaSans(
                      color: DexoOrganizationPulseColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : Text(
                    'Auto-saved',
                    key: const ValueKey('saved'),
                    style: GoogleFonts.plusJakartaSans(
                      color: DexoOrganizationPulseColors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class DexoOrganizationSectionTitle extends StatelessWidget {
  const DexoOrganizationSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        color: DexoOrganizationPulseColors.dark,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }
}

class DexoOrganizationRoundButton extends StatelessWidget {
  const DexoOrganizationRoundButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: DexoOrganizationPulseColors.border),
        ),
        child: Icon(icon, color: DexoOrganizationPulseColors.dark, size: 18),
      ),
    );
  }
}
