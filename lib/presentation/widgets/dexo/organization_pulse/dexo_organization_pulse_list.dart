import 'package:flutter/material.dart';

import 'package:e_team/presentation/models/dexo/department_pulse_view_model.dart';
import 'package:e_team/presentation/widgets/dexo/organization_pulse/dexo_department_pulse_card.dart';
import 'package:e_team/presentation/widgets/dexo/organization_pulse/dexo_organization_empty_state.dart';
import 'package:e_team/presentation/widgets/dexo/organization_pulse/dexo_organization_pulse_hero.dart';
import 'package:e_team/presentation/widgets/dexo/organization_pulse/dexo_organization_pulse_chrome.dart';
import 'package:e_team/presentation/widgets/dexo/organization_pulse/dexo_organization_pulse_helpers.dart';
import 'package:e_team/presentation/widgets/dexo/organization_pulse/dexo_organization_pulse_theme.dart';

class DexoOrganizationPulseList extends StatelessWidget {
  const DexoOrganizationPulseList({
    super.key,
    required this.departments,
    required this.totalCurrent,
    required this.totalTarget,
    required this.onRefresh,
    required this.onTargetChanged,
  });

  final List<DepartmentPulseViewModel> departments;
  final int totalCurrent;
  final int totalTarget;
  final RefreshCallback onRefresh;
  final ValueChanged<DepartmentPulseTargetChange> onTargetChanged;

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
