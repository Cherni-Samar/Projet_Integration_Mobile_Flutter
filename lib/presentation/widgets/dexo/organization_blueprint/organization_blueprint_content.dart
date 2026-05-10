import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:e_team/domain/models/dexo/dexo_onboarding_models.dart';
import 'package:e_team/presentation/widgets/dexo/organization_blueprint/organization_blueprint_helpers.dart';
import 'package:e_team/presentation/widgets/dexo/organization_blueprint/organization_blueprint_sections.dart';
import 'package:e_team/presentation/widgets/dexo/organization_blueprint/organization_blueprint_theme.dart';

class OrganizationBlueprintContent extends StatelessWidget {
  const OrganizationBlueprintContent({
    super.key,
    required this.plan,
    required this.total,
    required this.isSaving,
    required this.onConfirm,
    required this.onDepartmentChanged,
  });

  final WorkforcePlan plan;
  final int total;
  final bool isSaving;
  final Future<void> Function() onConfirm;
  final void Function(WorkforceDepartment department, int delta)
  onDepartmentChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.92,
      ),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: OrganizationBlueprintTheme.border,
          width: 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OrganizationBlueprintHeader(),
          const SizedBox(height: 14),
          Text(
            plan.explanation,
            style: GoogleFonts.plusJakartaSans(
              color: OrganizationBlueprintTheme.textMuted,
              fontSize: 12,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          ...plan.departments.map(
            (dept) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: OrganizationBlueprintDepartmentRow(
                icon: iconForBlueprintDepartment(dept.name),
                label: dept.name,
                subtitle: dept.reason.isNotEmpty
                    ? dept.reason
                    : 'Required function for this company',
                value: dept.targetCount,
                onMinus: () => onDepartmentChanged(dept, -1),
                onPlus: () => onDepartmentChanged(dept, 1),
              ),
            ),
          ),
          const SizedBox(height: 6),
          OrganizationBlueprintTotalBox(total: total),
          if (plan.recommendedAgents.isNotEmpty) ...[
            const SizedBox(height: 20),
            OrganizationBlueprintAgentsSection(agents: plan.recommendedAgents),
          ],
          const SizedBox(height: 20),
          OrganizationBlueprintConfirmButton(
            isSaving: isSaving,
            onPressed: isSaving ? null : onConfirm,
          ),
        ],
      ),
    );
  }
}
