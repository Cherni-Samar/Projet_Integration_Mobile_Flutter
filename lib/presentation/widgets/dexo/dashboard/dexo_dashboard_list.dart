import 'package:flutter/material.dart';

import 'package:e_team/presentation/widgets/dexo/dashboard/dexo_dashboard_cards.dart';
import 'package:e_team/presentation/widgets/dexo/dashboard/dexo_dashboard_chrome.dart';
import 'package:e_team/presentation/widgets/dexo/dashboard/dexo_dashboard_theme.dart';

class DexoDashboardList extends StatelessWidget {
  const DexoDashboardList({
    super.key,
    required this.isLoading,
    required this.isAiThinking,
    required this.dailyReport,
    required this.onRefresh,
    required this.onRefreshBriefing,
    required this.onOrganizationPulsePressed,
    required this.onProductionHubPressed,
  });

  final bool isLoading;
  final bool isAiThinking;
  final String dailyReport;
  final RefreshCallback onRefresh;
  final VoidCallback onRefreshBriefing;
  final VoidCallback onOrganizationPulsePressed;
  final VoidCallback onProductionHubPressed;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: DexoDashboardColors.dexoBlue,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 26),
        children: [
          const DexoBrainCard(),
          const SizedBox(height: 18),
          DexoExecutiveBriefingCard(
            isLoading: isLoading,
            isAiThinking: isAiThinking,
            dailyReport: dailyReport,
            onRefreshPressed: onRefreshBriefing,
          ),
          const SizedBox(height: 26),
          const DexoDashboardSectionTitle('DEXO COMMAND CENTER'),
          const SizedBox(height: 12),
          DexoDashboardMenuCard(
            title: 'Organization Pulse',
            subtitle: 'Adjust workforce targets and detect staffing gaps.',
            icon: Icons.account_tree_rounded,
            isPrimary: true,
            onTap: onOrganizationPulsePressed,
          ),
          DexoDashboardMenuCard(
            title: 'Production Hub',
            subtitle: 'Documents, generated outputs and execution logs.',
            icon: Icons.factory_rounded,
            onTap: onProductionHubPressed,
          ),
        ],
      ),
    );
  }
}
