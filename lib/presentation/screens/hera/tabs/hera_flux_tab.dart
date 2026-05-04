import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:e_team/domain/models/hera_models.dart';
import '../hera_history_page.dart';
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
    final hasTimoAction = recentActions.isNotEmpty &&
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
                builder: (_) => HeraHistoryPage(
                  actions: recentActions,
                  isDark: true,
                ),
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
            ...recentActions.take(5).toList().asMap().entries.map(
                  (entry) => _ActionCard(
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

// ─── Private widgets used only by this tab ──────────────────────────────────

class _ActionCard extends StatelessWidget {
  final Map<String, dynamic> action;
  final int index;
  final void Function(Map<String, dynamic>, int) onDelete;
  final void Function(Map<String, dynamic>) onTap;

  const _ActionCard({
    required this.action,
    required this.index,
    required this.onDelete,
    required this.onTap,
  });

  String? _extractId(dynamic id) {
    if (id == null) return null;
    if (id is String) return id;
    if (id is Map) return id[r'$oid']?.toString() ?? id['_id']?.toString();
    return id.toString();
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays}j';
    return DateFormat('d MMM', 'fr_FR').format(date);
  }

  Map<String, dynamic> _actionConfig() {
    final type = action['action_type']?.toString() ?? '';
    final details = action['details'] is Map<String, dynamic>
        ? action['details'] as Map<String, dynamic>
        : <String, dynamic>{};

    switch (type) {
      case 'planning_confirmed':
        if (details['agent'] == 'Timo') {
          return {
            'icon': Icons.event_available_rounded,
            'color': HeraPalette.timo,
            'label': 'Logistique · Planning validé',
            'badge': 'TIMO IA',
          };
        }
        return {
          'icon': Icons.campaign_rounded,
          'color': HeraPalette.warning,
          'label': 'Alerte staffing · ${details['department'] ?? 'équipe'}',
          'badge': 'AUTONOME',
        };
      case 'leave_approved':
        return {
          'icon': Icons.check_circle_outline_rounded,
          'color': HeraPalette.success,
          'label': 'Congé approuvé',
          'badge': 'RH IA',
        };
      case 'leave_refused':
        return {
          'icon': Icons.event_busy_rounded,
          'color': HeraPalette.danger,
          'label': 'Congé refusé',
          'badge': 'REFUSÉ',
        };
      case 'contract_renewal':
        return {
          'icon': Icons.description_rounded,
          'color': Colors.blue,
          'label': 'Contrat édité',
          'badge': 'DOCS',
        };
      default:
        return {
          'icon': Icons.auto_awesome_rounded,
          'color': HeraPalette.mauve,
          'label': 'Action système IA',
          'badge': 'INFO',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _actionConfig();
    final color = cfg['color'] as Color;
    final name = action['employee_name'] as String? ?? 'Employé';
    final createdAt = action['created_at'] != null
        ? DateTime.tryParse(action['created_at'].toString())
        : null;

    return Dismissible(
      key: Key('act_${_extractId(action['_id'])}_$index'),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => onDelete(action, index),
      background: const HeraDismissBackground(),
      child: GestureDetector(
        onTap: () => onTap(action),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: HeraPalette.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: HeraPalette.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(cfg['icon'] as IconData, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: HeraPalette.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cfg['label'] as String,
                      style: const TextStyle(
                        color: HeraPalette.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  HeraBadge(label: cfg['badge'] as String, color: color),
                  if (createdAt != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      _timeAgo(createdAt),
                      style: const TextStyle(
                        color: HeraPalette.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
