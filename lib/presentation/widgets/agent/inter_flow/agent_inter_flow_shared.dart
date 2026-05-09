import 'package:e_team/domain/models/agent_interaction_model.dart';
import 'package:e_team/presentation/widgets/agent/inter_flow/agent_inter_flow_design.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InterFlowCard extends StatelessWidget {
  const InterFlowCard({
    super.key,
    required this.child,
    this.margin,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AgentInterFlowDesignSystem.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AgentInterFlowDesignSystem.border,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AgentInterFlowDesignSystem.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class InterFlowMetricDivider extends StatelessWidget {
  const InterFlowMetricDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AgentInterFlowDesignSystem.border,
    );
  }
}

class InterFlowStatMetric extends StatelessWidget {
  const InterFlowStatMetric({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: AgentInterFlowDesignSystem.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: AgentInterFlowDesignSystem.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class InterFlowAgentAvatar extends StatelessWidget {
  const InterFlowAgentAvatar({
    super.key,
    required this.name,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });

  final String name;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: iconColor.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: GoogleFonts.plusJakartaSans(
            color: AgentInterFlowDesignSystem.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class InterFlowAnimatedArrow extends StatelessWidget {
  const InterFlowAnimatedArrow({super.key, required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Row(
          children: [
            Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AgentInterFlowDesignSystem.encrypted.withValues(
                        alpha: 0.3,
                      ),
                      AgentInterFlowDesignSystem.encrypted.withValues(
                        alpha: 0.8,
                      ),
                      AgentInterFlowDesignSystem.encrypted.withValues(
                        alpha: 0.3,
                      ),
                    ],
                    stops: [0.0, controller.value, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_rounded,
              color: AgentInterFlowDesignSystem.encrypted.withValues(
                alpha: 0.6 + 0.4 * controller.value,
              ),
              size: 16,
            ),
          ],
        );
      },
    );
  }
}

class InterFlowStatusBadge extends StatelessWidget {
  const InterFlowStatusBadge({super.key, required this.interaction});

  final AgentInteraction interaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: interaction.statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: interaction.statusColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        interaction.statusLabel,
        style: GoogleFonts.plusJakartaSans(
          color: interaction.statusColor,
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
