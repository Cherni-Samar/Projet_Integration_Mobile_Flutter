import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:e_team/presentation/widgets/dexo/dashboard/dexo_dashboard_theme.dart';

class DexoDashboardHeader extends StatelessWidget {
  const DexoDashboardHeader({super.key, required this.onBackPressed});

  final VoidCallback onBackPressed;

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
          const Expanded(child: DexoDashboardTitleBlock()),
        ],
      ),
    );
  }
}

class DexoDashboardTitleBlock extends StatelessWidget {
  const DexoDashboardTitleBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

class DexoDashboardSectionTitle extends StatelessWidget {
  const DexoDashboardSectionTitle(this.text, {super.key});

  final String text;

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
  const DexoDashboardRoundButton({
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
