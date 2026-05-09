import 'package:e_team/presentation/widgets/agent/inter_flow/agent_inter_flow_design.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
