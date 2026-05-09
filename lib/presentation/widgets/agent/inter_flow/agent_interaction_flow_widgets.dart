import 'package:e_team/domain/models/agent_interaction_model.dart';
import 'package:e_team/presentation/widgets/agent/inter_flow/agent_inter_flow_design.dart';
import 'package:e_team/presentation/widgets/agent/inter_flow/agent_inter_flow_shared.dart';
import 'package:e_team/presentation/widgets/agent/inter_flow/agent_inter_flow_states.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AgentInteractionFlow extends StatelessWidget {
  const AgentInteractionFlow({
    super.key,
    required this.interactions,
    required this.arrowController,
    required this.onRefresh,
  });

  final List<AgentInteraction> interactions;
  final AnimationController arrowController;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (interactions.isEmpty) {
      return const AgentInterFlowEmptyState();
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AgentInterFlowDesignSystem.encrypted,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: interactions.length,
        itemBuilder: (context, index) {
          return AgentInteractionCard(
            interaction: interactions[index],
            index: index,
            arrowController: arrowController,
          );
        },
      ),
    );
  }
}

class AgentInteractionCard extends StatelessWidget {
  const AgentInteractionCard({
    super.key,
    required this.interaction,
    required this.index,
    required this.arrowController,
  });

  final AgentInteraction interaction;
  final int index;
  final AnimationController arrowController;

  @override
  Widget build(BuildContext context) {
    final senderConfig = AgentInteractionUi.agentConfig[interaction.sender]!;
    final receiverConfig =
        AgentInteractionUi.agentConfig[interaction.receiver]!;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: InterFlowCard(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InterFlowAgentAvatar(
                  name: senderConfig['name'],
                  icon: senderConfig['icon'],
                  bgColor: senderConfig['bgColor'],
                  iconColor: senderConfig['iconColor'],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InterFlowAnimatedArrow(controller: arrowController),
                ),
                const SizedBox(width: 16),
                InterFlowAgentAvatar(
                  name: receiverConfig['name'],
                  icon: receiverConfig['icon'],
                  bgColor: receiverConfig['bgColor'],
                  iconColor: receiverConfig['iconColor'],
                ),
                const SizedBox(width: 16),
                InterFlowStatusBadge(interaction: interaction),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              interaction.actionType.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                color: AgentInterFlowDesignSystem.encrypted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              interaction.summary,
              style: GoogleFonts.plusJakartaSans(
                color: AgentInterFlowDesignSystem.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 12,
                  color: AgentInterFlowDesignSystem.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  interaction.timeAgo,
                  style: GoogleFonts.plusJakartaSans(
                    color: AgentInterFlowDesignSystem.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
