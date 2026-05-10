import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/widgets/agent/agent_avatar_hero.dart';
import 'package:e_team/presentation/widgets/agent/agent_description_bubble.dart';
import 'package:e_team/presentation/widgets/agent/agent_energy_costs_section.dart';
import 'package:e_team/presentation/widgets/agent/agent_multi_scenario_card.dart';
import 'package:e_team/presentation/widgets/agent/agent_name_header.dart';
import 'package:e_team/presentation/widgets/agent/agent_skills_section.dart';
import 'package:flutter/material.dart';

class AgentDetailsBody extends StatelessWidget {
  const AgentDetailsBody({
    super.key,
    required this.l10n,
    required this.isDark,
    required this.agentName,
    required this.agentColor,
    required this.agentIcon,
    required this.description,
    required this.version,
    required this.skills,
    required this.energyCosts,
    required this.multiScenarios,
    required this.pulseController,
    required this.avatarDx,
  });

  final AppLocalizations l10n;
  final bool isDark;
  final String agentName;
  final Color agentColor;
  final String agentIcon;
  final String description;
  final String version;
  final List<String> skills;
  final List<Map<String, dynamic>> energyCosts;
  final List<Map<String, dynamic>> multiScenarios;
  final AnimationController pulseController;
  final double avatarDx;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AgentAvatarHero(
          agentIcon: agentIcon,
          agentColor: agentColor,
          pulseController: pulseController,
          avatarDx: avatarDx,
        ),
        const SizedBox(height: 24),
        AgentNameHeader(agentName: agentName, version: version, isDark: isDark),
        const SizedBox(height: 24),
        AgentDescriptionBubble(
          description: description,
          agentColor: agentColor,
          isDark: isDark,
        ),
        const SizedBox(height: 32),
        AgentSkillsSection(
          title: l10n.agentDetailsCoreSkills,
          skills: skills,
          isDark: isDark,
        ),
        const SizedBox(height: 32),
        AgentEnergyCostsSection(
          title: 'ENERGY COST PER TASK',
          energyCosts: energyCosts,
          agentColor: agentColor,
          isDark: isDark,
        ),
        if (multiScenarios.isNotEmpty) ...[
          const SizedBox(height: 32),
          Text(
            'MULTI-AGENT SCENARIOS',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ...multiScenarios.map(
            (scenario) => AgentMultiScenarioCard(
              scenario: scenario,
              agentColor: agentColor,
              isDark: isDark,
            ),
          ),
        ],
        const SizedBox(height: 120),
      ],
    );
  }
}
