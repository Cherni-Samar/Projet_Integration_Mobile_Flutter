import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:e_team/domain/models/dexo/dexo_onboarding_models.dart';
import 'package:e_team/presentation/widgets/dexo/organization_blueprint/organization_blueprint_theme.dart';

class OrganizationBlueprintAgentsSection extends StatelessWidget {
  const OrganizationBlueprintAgentsSection({super.key, required this.agents});

  final List<RecommendedAgent> agents;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECOMMENDED AI AGENTS',
          style: GoogleFonts.plusJakartaSans(
            color: OrganizationBlueprintTheme.dark,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        ...agents.map((agent) => OrganizationBlueprintAgentTile(agent: agent)),
      ],
    );
  }
}

class OrganizationBlueprintAgentTile extends StatelessWidget {
  const OrganizationBlueprintAgentTile({super.key, required this.agent});

  final RecommendedAgent agent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: OrganizationBlueprintTheme.border,
          width: 0.6,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome,
            color: OrganizationBlueprintTheme.dark,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agent.name.isNotEmpty ? agent.name : agent.id,
                  style: GoogleFonts.plusJakartaSans(
                    color: OrganizationBlueprintTheme.textMain,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  agent.reason,
                  style: GoogleFonts.plusJakartaSans(
                    color: OrganizationBlueprintTheme.textMuted,
                    fontSize: 11,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
