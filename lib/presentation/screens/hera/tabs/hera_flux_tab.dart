import 'package:flutter/material.dart';

import 'package:e_team/domain/models/hera/hera_models.dart';
import 'package:e_team/presentation/screens/hera/hera_history_page.dart';
import 'package:e_team/presentation/widgets/hera/flux/hera_flux_widgets.dart';
import 'package:e_team/presentation/widgets/hera/hera_shared_widgets.dart';

/// Flux tab — recent activity feed and workforce pulse.
/// All state lives in [_HeraDashboardPageState]; this widget is pure UI.
class HeraFluxTab extends StatelessWidget {
  final List<Map<String, dynamic>> recentActions;
  final bool loadingStats;
  final bool loadingActions;
  final HeraStats? stats;
  final AnimationController pulseCtrl;
  final Future<void> Function() onRefresh;
  final void Function(Map<String, dynamic> action, int index) onDeleteAction;
  final void Function(Map<String, dynamic> action) onShowDetail;

  const HeraFluxTab({
    super.key,
    required this.recentActions,
    required this.loadingStats,
    required this.loadingActions,
    required this.stats,
    required this.pulseCtrl,
    required this.onRefresh,
    required this.onDeleteAction,
    required this.onShowDetail,
  });

  @override
  Widget build(BuildContext context) {
    final hasTimoAction =
        recentActions.isNotEmpty &&
        recentActions.first['details']?['agent'] == 'Timo';

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: HeraPalette.mauve,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          if (loadingStats)
            const HeraShimmerBox(height: 200)
          else
            HeraWorkforcePulse(stats: stats, pulseCtrl: pulseCtrl),
          const SizedBox(height: 14),
          if (hasTimoAction) ...[
            const HeraTimoBanner(),
            const SizedBox(height: 14),
          ],
          HeraSectionHeader(
            label: 'Activité récente',
            action: 'Voir tout',
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    HeraHistoryPage(actions: recentActions, isDark: true),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (loadingActions) ...[
            const HeraShimmerBox(height: 72),
            const SizedBox(height: 8),
            const HeraShimmerBox(height: 72),
          ] else if (recentActions.isEmpty)
            const HeraEmptyState(
              icon: Icons.history_rounded,
              title: 'Aucune activité',
              sub: '...',
            )
          else
            ...recentActions
                .take(5)
                .toList()
                .asMap()
                .entries
                .map(
                  (entry) => HeraFluxActionCard(
                    action: entry.value,
                    index: entry.key,
                    onDelete: onDeleteAction,
                    onTap: onShowDetail,
                  ),
                ),
        ],
      ),
    );
  }
}
