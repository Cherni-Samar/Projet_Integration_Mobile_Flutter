import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:e_team/presentation/models/dexo/department_pulse_view_model.dart';

class DexoOrganizationPulseColors {
  static const Color volt = Color(0xFFCDFF00);
  static const Color dark = Color(0xFF0A0A0A);
  static const Color bg = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE5E7EB);
  static const Color muted = Color(0xFF64748B);
  static const Color green = Color(0xFF22C55E);
  static const Color orange = Color(0xFFF59E0B);
  static const Color red = Color(0xFFEF4444);
}

class DexoOrganizationPulseHeader extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onBackPressed;

  const DexoOrganizationPulseHeader({
    super.key,
    required this.isSaving,
    required this.onBackPressed,
  });

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

class DexoOrganizationPulseList extends StatelessWidget {
  final List<DepartmentPulseViewModel> departments;
  final int totalCurrent;
  final int totalTarget;
  final RefreshCallback onRefresh;
  final ValueChanged<DepartmentPulseTargetChange> onTargetChanged;

  const DexoOrganizationPulseList({
    super.key,
    required this.departments,
    required this.totalCurrent,
    required this.totalTarget,
    required this.onRefresh,
    required this.onTargetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: DexoOrganizationPulseColors.dark,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        children: [
          DexoOrganizationPulseHero(
            totalCurrent: totalCurrent,
            totalTarget: totalTarget,
          ),
          const SizedBox(height: 22),
          const DexoOrganizationSectionTitle('DEPARTMENT TARGETS'),
          const SizedBox(height: 12),
          if (departments.isEmpty)
            const DexoOrganizationEmptyState()
          else
            ...departments.map(
              (department) => DexoDepartmentPulseCard(
                department: department,
                onTargetChanged: (value) => onTargetChanged(
                  DepartmentPulseTargetChange(
                    department: department,
                    value: value,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DexoOrganizationPulseHero extends StatelessWidget {
  final int totalCurrent;
  final int totalTarget;

  const DexoOrganizationPulseHero({
    super.key,
    required this.totalCurrent,
    required this.totalTarget,
  });

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
  final DepartmentPulseViewModel department;
  final ValueChanged<double> onTargetChanged;

  const DexoDepartmentPulseCard({
    super.key,
    required this.department,
    required this.onTargetChanged,
  });

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
          Row(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
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
          ),
          const SizedBox(height: 18),
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
              value: department.targetCount.clamp(0, 30).toDouble(),
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

class DexoOrganizationSectionTitle extends StatelessWidget {
  final String text;

  const DexoOrganizationSectionTitle(this.text, {super.key});

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
  final IconData icon;
  final VoidCallback onTap;

  const DexoOrganizationRoundButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

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

class DepartmentPulseTargetChange {
  final DepartmentPulseViewModel department;
  final double value;

  const DepartmentPulseTargetChange({
    required this.department,
    required this.value,
  });
}

Color statusColorForRatio(double ratio) {
  if (ratio >= 1) return DexoOrganizationPulseColors.green;
  if (ratio >= 0.5) return DexoOrganizationPulseColors.orange;
  return DexoOrganizationPulseColors.red;
}

String statusTextForRatio(double ratio, int gap) {
  if (ratio >= 1) return 'BALANCED';
  if (gap >= 5) return 'CRITICAL';
  return 'UNDERSTAFFED';
}

IconData iconForDepartment(String name) {
  final n = name.toLowerCase();

  if (n.contains('tech') || n.contains('software') || n.contains('it')) {
    return Icons.code_rounded;
  }
  if (n.contains('design') || n.contains('ux') || n.contains('brand')) {
    return Icons.palette_rounded;
  }
  if (n.contains('marketing') || n.contains('growth') || n.contains('sales')) {
    return Icons.campaign_rounded;
  }
  if (n.contains('finance') ||
      n.contains('accounting') ||
      n.contains('budget')) {
    return Icons.account_balance_wallet_rounded;
  }
  if (n.contains('operation') || n.contains('logistic')) {
    return Icons.settings_suggest_rounded;
  }
  if (n.contains('support') || n.contains('client') || n.contains('customer')) {
    return Icons.support_agent_rounded;
  }
  if (n.contains('rh') || n.contains('hr') || n.contains('human')) {
    return Icons.groups_rounded;
  }
  if (n.contains('admin')) {
    return Icons.admin_panel_settings_rounded;
  }

  return Icons.business_center_rounded;
}
