import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:e_team/presentation/models/dexo/department_pulse_view_model.dart';
import 'package:e_team/presentation/widgets/dexo/organization_pulse/dexo_organization_pulse_helpers.dart';
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

class DexoDepartmentPulseCard extends StatelessWidget {
  const DexoDepartmentPulseCard({
    super.key,
    required this.department,
    required this.onTargetChanged,
  });

  final DepartmentPulseViewModel department;
  final ValueChanged<double> onTargetChanged;

  @override
  Widget build(BuildContext context) {
    final gap = (department.targetCount - department.currentCount).clamp(0, 99);
    final ratio = department.targetCount == 0
        ? 1.0
        : (department.currentCount / department.targetCount).clamp(0.0, 1.0);

    final statusColor = statusColorForRatio(ratio);
    final statusText = statusTextForRatio(ratio, gap);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: DexoOrganizationPulseColors.border,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.028),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _DexoDepartmentPulseHeader(
            department: department,
            statusColor: statusColor,
            statusText: statusText,
          ),
          const SizedBox(height: 18),
          _DexoDepartmentTargetSlider(
            targetCount: department.targetCount,
            onTargetChanged: onTargetChanged,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              gap == 0
                  ? 'Dexo Insight: this department is balanced.'
                  : 'Dexo Insight: ${department.name} needs +$gap hire(s).',
              style: GoogleFonts.plusJakartaSans(
                color: DexoOrganizationPulseColors.muted,
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DexoDepartmentPulseHeader extends StatelessWidget {
  const _DexoDepartmentPulseHeader({
    required this.department,
    required this.statusColor,
    required this.statusText,
  });

  final DepartmentPulseViewModel department;
  final Color statusColor;
  final String statusText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: DexoOrganizationPulseColors.surface,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            iconForDepartment(department.name),
            color: DexoOrganizationPulseColors.dark,
            size: 23,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                department.name,
                style: GoogleFonts.plusJakartaSans(
                  color: DexoOrganizationPulseColors.dark,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${department.currentCount} current / ${department.targetCount} target',
                style: GoogleFonts.plusJakartaSans(
                  color: DexoOrganizationPulseColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            statusText,
            style: GoogleFonts.plusJakartaSans(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _DexoDepartmentTargetSlider extends StatelessWidget {
  const _DexoDepartmentTargetSlider({
    required this.targetCount,
    required this.onTargetChanged,
  });

  final int targetCount;
  final ValueChanged<double> onTargetChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8,
            activeTrackColor: DexoOrganizationPulseColors.dark,
            inactiveTrackColor: DexoOrganizationPulseColors.border,
            thumbColor: DexoOrganizationPulseColors.volt,
            overlayColor: DexoOrganizationPulseColors.volt.withValues(
              alpha: 0.12,
            ),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
          ),
          child: Slider(
            min: 0,
            max: 30,
            divisions: 30,
            value: targetCount.clamp(0, 30).toDouble(),
            onChanged: onTargetChanged,
          ),
        ),
        Row(
          children: [
            Text(
              '0',
              style: GoogleFonts.plusJakartaSans(
                color: DexoOrganizationPulseColors.muted,
                fontSize: 10,
              ),
            ),
            const Spacer(),
            Text(
              'Drag to tune vision',
              style: GoogleFonts.plusJakartaSans(
                color: DexoOrganizationPulseColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '30',
              style: GoogleFonts.plusJakartaSans(
                color: DexoOrganizationPulseColors.muted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

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
