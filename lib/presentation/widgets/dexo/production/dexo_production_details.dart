import 'package:e_team/presentation/widgets/dexo/production/dexo_production_models.dart';
import 'package:e_team/presentation/widgets/dexo/production/dexo_production_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DexoProductionDetailsSheet extends StatelessWidget {
  const DexoProductionDetailsSheet({super.key, required this.action});

  final Map<String, dynamic> action;

  @override
  Widget build(BuildContext context) {
    final viewModel = DexoProductionActionViewModel.fromAction(action);

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: DexoProductionTheme.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: DexoProductionTheme.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: DexoProductionTheme.dark,
                    size: 28,
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
                          fontSize: 16,
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
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            DexoProductionDetailRow('Employee', viewModel.employeeName),
            DexoProductionDetailRow('Email', viewModel.employeeEmail),
            DexoProductionDetailRow('Role', viewModel.role),
            DexoProductionDetailRow('Department', viewModel.department),
            DexoProductionDetailRow('Reason', viewModel.reasonOrDash),
            DexoProductionDetailRow(
              'Created at',
              viewModel.date != null
                  ? formatDexoProductionDate(viewModel.date!)
                  : '-',
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: DexoProductionTheme.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Generated, archived and sent by Hera.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: DexoProductionTheme.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DexoProductionDetailRow extends StatelessWidget {
  const DexoProductionDetailRow(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DexoProductionTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DexoProductionTheme.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 94,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: DexoProductionTheme.muted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.plusJakartaSans(
                color: DexoProductionTheme.dark,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
