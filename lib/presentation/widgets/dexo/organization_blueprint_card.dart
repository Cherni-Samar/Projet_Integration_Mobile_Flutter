import 'package:flutter/material.dart';

import 'package:e_team/domain/models/dexo/dexo_onboarding_models.dart';
import 'package:e_team/presentation/widgets/dexo/organization_blueprint/organization_blueprint_content.dart';

class OrganizationBlueprintCard extends StatefulWidget {
  const OrganizationBlueprintCard({
    super.key,
    required this.initialPlan,
    required this.onConfirm,
  });

  final WorkforcePlan initialPlan;
  final Future<void> Function(WorkforcePlan plan) onConfirm;

  @override
  State<OrganizationBlueprintCard> createState() =>
      _OrganizationBlueprintCardState();
}

class _OrganizationBlueprintCardState extends State<OrganizationBlueprintCard> {
  late WorkforcePlan _plan;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _plan = WorkforcePlan(
      departments: widget.initialPlan.departments
          .map(
            (d) => WorkforceDepartment(
              name: d.name,
              targetCount: d.targetCount,
              reason: d.reason,
            ),
          )
          .toList(),
      explanation: widget.initialPlan.explanation,
      recommendedAgents: widget.initialPlan.recommendedAgents,
    );
  }

  int get _total => _plan.departments.fold(0, (sum, d) => sum + d.targetCount);

  @override
  Widget build(BuildContext context) {
    return OrganizationBlueprintContent(
      plan: _plan,
      total: _total,
      isSaving: _isSaving,
      onConfirm: _handleConfirm,
      onDepartmentChanged: _changeDepartment,
    );
  }

  Future<void> _handleConfirm() async {
    setState(() => _isSaving = true);
    await widget.onConfirm(_plan);
    if (mounted) setState(() => _isSaving = false);
  }

  void _changeDepartment(WorkforceDepartment department, int delta) {
    setState(() {
      department.targetCount = (department.targetCount + delta).clamp(0, 99);
    });
  }
}
