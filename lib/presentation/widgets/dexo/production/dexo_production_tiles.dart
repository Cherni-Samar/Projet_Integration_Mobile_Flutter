import 'package:e_team/presentation/widgets/dexo/production/dexo_production_models.dart';
import 'package:e_team/presentation/widgets/dexo/production/dexo_production_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DexoProductionTile extends StatelessWidget {
  const DexoProductionTile({
    super.key,
    required this.action,
    required this.onTap,
  });

  final Map<String, dynamic> action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final viewModel = DexoProductionActionViewModel.fromAction(action);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: DexoProductionTheme.border, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.028),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: DexoProductionTheme.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.picture_as_pdf_rounded,
                color: DexoProductionTheme.dark,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    viewModel.docType.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      color: DexoProductionTheme.dark,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    viewModel.filename,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: DexoProductionTheme.blue,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Requested by ${viewModel.employeeName}',
                    style: GoogleFonts.plusJakartaSans(
                      color: DexoProductionTheme.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (viewModel.reason.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      'Reason: ${viewModel.reason}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: DexoProductionTheme.muted.withValues(
                          alpha: 0.85,
                        ),
                        fontSize: 10,
                      ),
                    ),
                  ],
                  if (viewModel.date != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      formatDexoProductionDate(viewModel.date!),
                      style: GoogleFonts.plusJakartaSans(
                        color: DexoProductionTheme.muted.withValues(alpha: 0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: DexoProductionTheme.muted,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
