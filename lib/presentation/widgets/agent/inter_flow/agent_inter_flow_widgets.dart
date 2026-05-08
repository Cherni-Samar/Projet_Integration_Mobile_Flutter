import 'dart:math';

import 'package:e_team/domain/models/agent_interaction_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AgentInterFlowDesignSystem {
  const AgentInterFlowDesignSystem._();

  static const Color bg = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFF1F5F9);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Color heraGreen = Color(0xFFE8F5E8);
  static const Color echoViolet = Color(0xFFF3E8FF);
  static const Color timoOrange = Color(0xFFFFF4E6);
  static const Color dexoBlue = Color(0xFFE6F3FF);
  static const Color kashTeal = Color(0xFFE6FFFA);

  static const Color heraGreenIcon = Color(0xFF10B981);
  static const Color echoVioletIcon = Color(0xFF8B5CF6);
  static const Color timoOrangeIcon = Color(0xFFFF9800);
  static const Color dexoBlueIcon = Color(0xFF3B82F6);
  static const Color kashTealIcon = Color(0xFF06B6D4);

  static const Color success = Color(0xFF10B981);
  static const Color encrypted = Color(0xFF8B5CF6);
  static const Color shadowLight = Color(0x08000000);
}

class AgentInteractionUi {
  const AgentInteractionUi._();

  static Map<AgentType, Map<String, dynamic>> get agentConfig => {
    AgentType.hera: {
      'name': 'HERA',
      'icon': Icons.people_outline,
      'bgColor': AgentInterFlowDesignSystem.heraGreen,
      'iconColor': AgentInterFlowDesignSystem.heraGreenIcon,
    },
    AgentType.echo: {
      'name': 'ECHO',
      'icon': Icons.campaign_outlined,
      'bgColor': AgentInterFlowDesignSystem.echoViolet,
      'iconColor': AgentInterFlowDesignSystem.echoVioletIcon,
    },
    AgentType.timo: {
      'name': 'TIMO',
      'icon': Icons.schedule_outlined,
      'bgColor': AgentInterFlowDesignSystem.timoOrange,
      'iconColor': AgentInterFlowDesignSystem.timoOrangeIcon,
    },
    AgentType.dexo: {
      'name': 'DEXO',
      'icon': Icons.admin_panel_settings_outlined,
      'bgColor': AgentInterFlowDesignSystem.dexoBlue,
      'iconColor': AgentInterFlowDesignSystem.dexoBlueIcon,
    },
    AgentType.kash: {
      'name': 'KASH',
      'icon': Icons.account_balance_outlined,
      'bgColor': AgentInterFlowDesignSystem.kashTeal,
      'iconColor': AgentInterFlowDesignSystem.kashTealIcon,
    },
  };
}

extension AgentInteractionUiX on AgentInteraction {
  Color get statusColor {
    switch (status) {
      case InteractionStatus.success:
        return AgentInterFlowDesignSystem.success;
      case InteractionStatus.encrypted:
        return AgentInterFlowDesignSystem.encrypted;
      case InteractionStatus.pending:
        return AgentInterFlowDesignSystem.textMuted;
      case InteractionStatus.failed:
        return Colors.red;
    }
  }
}

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
    return _InterFlowCard(
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

    return _InterFlowCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatMetric(
              label: 'TOTAL EXCHANGES',
              value: totalInteractions.toString(),
              icon: Icons.swap_horiz_rounded,
              color: AgentInterFlowDesignSystem.textPrimary,
            ),
          ),
          const _MetricDivider(),
          Expanded(
            child: _StatMetric(
              label: 'SUCCESSFUL',
              value: successfulInteractions.toString(),
              icon: Icons.check_circle_outline,
              color: AgentInterFlowDesignSystem.success,
            ),
          ),
          const _MetricDivider(),
          Expanded(
            child: _StatMetric(
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
      child: _InterFlowCard(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _AgentAvatar(
                  name: senderConfig['name'],
                  icon: senderConfig['icon'],
                  bgColor: senderConfig['bgColor'],
                  iconColor: senderConfig['iconColor'],
                ),
                const SizedBox(width: 16),
                Expanded(child: _AnimatedArrow(controller: arrowController)),
                const SizedBox(width: 16),
                _AgentAvatar(
                  name: receiverConfig['name'],
                  icon: receiverConfig['icon'],
                  bgColor: receiverConfig['bgColor'],
                  iconColor: receiverConfig['iconColor'],
                ),
                const SizedBox(width: 16),
                _StatusBadge(interaction: interaction),
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

class AgentInterFlowLoadingState extends StatelessWidget {
  const AgentInterFlowLoadingState({super.key, required this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AgentInterFlowDesignSystem.encrypted,
            strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          Text(
            error != null ? error! : 'Scanning network activity...',
            style: GoogleFonts.plusJakartaSans(
              color: error != null
                  ? Colors.red
                  : AgentInterFlowDesignSystem.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(
              'Using fallback data',
              style: GoogleFonts.plusJakartaSans(
                color: AgentInterFlowDesignSystem.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AgentInterFlowEmptyState extends StatelessWidget {
  const AgentInterFlowEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AgentInterFlowDesignSystem.encrypted.withValues(
                alpha: 0.1,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hub_outlined,
              size: 64,
              color: AgentInterFlowDesignSystem.encrypted.withValues(
                alpha: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Network Quiet',
            style: GoogleFonts.plusJakartaSans(
              color: AgentInterFlowDesignSystem.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No inter-agent exchanges detected',
            style: GoogleFonts.plusJakartaSans(
              color: AgentInterFlowDesignSystem.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
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

class _InterFlowCard extends StatelessWidget {
  const _InterFlowCard({
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

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AgentInterFlowDesignSystem.border,
    );
  }
}

class _StatMetric extends StatelessWidget {
  const _StatMetric({
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

class _AgentAvatar extends StatelessWidget {
  const _AgentAvatar({
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

class _AnimatedArrow extends StatelessWidget {
  const _AnimatedArrow({required this.controller});

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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.interaction});

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
