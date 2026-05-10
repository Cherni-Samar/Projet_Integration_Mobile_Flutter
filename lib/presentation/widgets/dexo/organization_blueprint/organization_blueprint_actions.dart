import 'package:e_team/presentation/widgets/common/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:e_team/presentation/widgets/dexo/organization_blueprint/organization_blueprint_theme.dart';

class OrganizationBlueprintConfirmButton extends StatelessWidget {
  const OrganizationBlueprintConfirmButton({
    super.key,
    required this.isSaving,
    required this.onPressed,
  });

  final bool isSaving;
  final Future<void> Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: OrganizationBlueprintTheme.dark,
          disabledBackgroundColor: OrganizationBlueprintTheme.dark.withValues(
            alpha: 0.45,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: AppLoadingIndicator(
                  strokeWidth: 2.2,
                  color: OrganizationBlueprintTheme.primary,
                ),
              )
            : Text(
                'ACTIVATE ORGANIZATION VISION',
                style: GoogleFonts.plusJakartaSans(
                  color: OrganizationBlueprintTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
      ),
    );
  }
}
