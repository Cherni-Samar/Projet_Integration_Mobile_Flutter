import 'package:flutter/material.dart';

import 'package:e_team/presentation/models/dexo/department_pulse_view_model.dart';
import 'package:e_team/presentation/widgets/dexo/organization_pulse/dexo_organization_pulse_theme.dart';

class DepartmentPulseTargetChange {
  const DepartmentPulseTargetChange({
    required this.department,
    required this.value,
  });

  final DepartmentPulseViewModel department;
  final double value;
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
