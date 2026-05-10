import 'dart:math';

import 'package:e_team/domain/models/agent_interaction_model.dart';
import 'package:e_team/presentation/widgets/agent/inter_flow/agent_inter_flow_design.dart';
import 'package:e_team/presentation/widgets/agent/inter_flow/agent_inter_flow_shared.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AgentInterFlowHeader extends StatelessWidget {
  const AgentInterFlowHeader({
    super.key,
    required this.refreshController,
    required this.onBack,
    required this.onRefresh,
  });

  final AnimationController refreshController;
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return InterFlowCard(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          _HeaderBackButton(onPressed: onBack),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AgentInterFlowDesignSystem.encrypted.withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.hub_outlined,
              color: AgentInterFlowDesignSystem.encrypted,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SYSTEM ACTIVITY',
                  style: GoogleFonts.plusJakartaSans(
                    color: AgentInterFlowDesignSystem.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Live Inter-Agent Exchange Logs',
                  style: GoogleFonts.plusJakartaSans(
                    color: AgentInterFlowDesignSystem.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRefresh,
            child: AnimatedBuilder(
              animation: refreshController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: refreshController.value * 2 * pi,
                  child: const _RefreshIcon(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AgentInterFlowStats extends StatelessWidget {
  const AgentInterFlowStats({
    super.key,
    required this.stats,
    required this.interactions,
  });

  final Map<String, int> stats;
  final List<AgentInteraction> interactions;

  @override
  Widget build(BuildContext context) {
    final totalInteractions = stats['total'] ?? interactions.length;
    final successfulInteractions =
        stats['successful'] ??
        interactions.where((i) => i.status == InteractionStatus.success).length;
    final encryptedInteractions =
        stats['encrypted'] ??
        interactions
            .where((i) => i.status == InteractionStatus.encrypted)
            .length;

    return InterFlowCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: InterFlowStatMetric(
              label: 'TOTAL EXCHANGES',
              value: totalInteractions.toString(),
              icon: Icons.swap_horiz_rounded,
              color: AgentInterFlowDesignSystem.textPrimary,
            ),
          ),
          const InterFlowMetricDivider(),
          Expanded(
            child: InterFlowStatMetric(
              label: 'SUCCESSFUL',
              value: successfulInteractions.toString(),
              icon: Icons.check_circle_outline,
              color: AgentInterFlowDesignSystem.success,
            ),
          ),
          const InterFlowMetricDivider(),
          Expanded(
            child: InterFlowStatMetric(
              label: 'ENCRYPTED',
              value: encryptedInteractions.toString(),
              icon: Icons.security_outlined,
              color: AgentInterFlowDesignSystem.encrypted,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBackButton extends StatelessWidget {
  const _HeaderBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AgentInterFlowDesignSystem.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AgentInterFlowDesignSystem.border,
          width: 0.5,
        ),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
        color: AgentInterFlowDesignSystem.textPrimary,
        onPressed: onPressed,
      ),
    );
  }
}

class _RefreshIcon extends StatelessWidget {
  const _RefreshIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AgentInterFlowDesignSystem.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AgentInterFlowDesignSystem.success.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: const Icon(
        Icons.refresh_rounded,
        color: AgentInterFlowDesignSystem.success,
        size: 18,
      ),
    );
  }
}
