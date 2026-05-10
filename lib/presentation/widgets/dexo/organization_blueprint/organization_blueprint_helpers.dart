import 'package:flutter/material.dart';

IconData iconForBlueprintDepartment(String name) {
  final n = name.toLowerCase();

  if (n.contains('tech') || n.contains('software') || n.contains('it')) {
    return Icons.code_rounded;
  }
  if (n.contains('design') || n.contains('brand') || n.contains('ux')) {
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
  if (n.contains('legal') || n.contains('juridique')) {
    return Icons.gavel_rounded;
  }

  return Icons.business_center_rounded;
}
