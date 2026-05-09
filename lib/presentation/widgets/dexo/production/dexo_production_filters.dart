import 'package:e_team/presentation/widgets/dexo/production/dexo_production_models.dart';
import 'package:e_team/presentation/widgets/dexo/production/dexo_production_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DexoProductionFilterBar extends StatelessWidget {
  const DexoProductionFilterBar({
    super.key,
    required this.selectedDocType,
    required this.selectedDateRange,
    required this.onSelectDocType,
    required this.onPickDate,
    required this.onClear,
  });

  final String selectedDocType;
  final DateTimeRange? selectedDateRange;
  final ValueChanged<String> onSelectDocType;
  final VoidCallback onPickDate;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final dateLabel = selectedDateRange == null
        ? 'Date'
        : '${formatDexoProductionShortDate(selectedDateRange!.start)} -> ${formatDexoProductionShortDate(selectedDateRange!.end)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter outputs',
          style: GoogleFonts.plusJakartaSans(
            color: DexoProductionTheme.muted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              DexoProductionFilterChip(
                label: 'All',
                selected: selectedDocType == 'all',
                onTap: () => onSelectDocType('all'),
              ),
              DexoProductionFilterChip(
                label: 'Attestation',
                selected: selectedDocType == 'attestation',
                onTap: () => onSelectDocType('attestation'),
              ),
              DexoProductionFilterChip(
                label: 'Bulletin',
                selected: selectedDocType == 'bulletin',
                onTap: () => onSelectDocType('bulletin'),
              ),
              DexoProductionFilterChip(
                label: dateLabel,
                icon: Icons.calendar_month_rounded,
                selected: selectedDateRange != null,
                onTap: onPickDate,
              ),
              if (selectedDateRange != null || selectedDocType != 'all')
                DexoProductionFilterChip(
                  label: 'Clear',
                  icon: Icons.close_rounded,
                  selected: false,
                  onTap: onClear,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class DexoProductionFilterChip extends StatelessWidget {
  const DexoProductionFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? DexoProductionTheme.dark : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? DexoProductionTheme.dark
                  : DexoProductionTheme.border,
            ),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 15,
                  color: selected ? Colors.white : DexoProductionTheme.dark,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: selected ? Colors.white : DexoProductionTheme.dark,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
