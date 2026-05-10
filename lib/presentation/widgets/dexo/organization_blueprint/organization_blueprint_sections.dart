import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:e_team/domain/models/dexo/dexo_onboarding_models.dart';
import 'package:e_team/presentation/widgets/dexo/organization_blueprint/organization_blueprint_theme.dart';

class OrganizationBlueprintHeader extends StatelessWidget {
  const OrganizationBlueprintHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: OrganizationBlueprintTheme.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.account_tree_rounded,
            color: OrganizationBlueprintTheme.dark,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ORGANIZATION BLUEPRINT',
                style: GoogleFonts.plusJakartaSans(
                  color: OrganizationBlueprintTheme.dark,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Adjust Dexo\u2019s dynamic company structure.',
                style: GoogleFonts.plusJakartaSans(
                  color: OrganizationBlueprintTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OrganizationBlueprintDepartmentRow extends StatelessWidget {
  const OrganizationBlueprintDepartmentRow({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: OrganizationBlueprintTheme.border,
          width: 0.6,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: OrganizationBlueprintTheme.dark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: OrganizationBlueprintTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    color: OrganizationBlueprintTheme.textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: OrganizationBlueprintTheme.textMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          OrganizationBlueprintCounterButton(
            icon: Icons.remove_rounded,
            onTap: onMinus,
          ),
          SizedBox(
            width: 38,
            child: Center(
              child: Text(
                '$value',
                style: GoogleFonts.plusJakartaSans(
                  color: OrganizationBlueprintTheme.textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          OrganizationBlueprintCounterButton(
            icon: Icons.add_rounded,
            onTap: onPlus,
          ),
        ],
      ),
    );
  }
}

class OrganizationBlueprintTotalBox extends StatelessWidget {
  const OrganizationBlueprintTotalBox({super.key, required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OrganizationBlueprintTheme.dark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.groups_rounded,
            color: OrganizationBlueprintTheme.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Total recommended workforce',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '$total',
            style: GoogleFonts.plusJakartaSans(
              color: OrganizationBlueprintTheme.primary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

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

class OrganizationBlueprintCounterButton extends StatelessWidget {
  const OrganizationBlueprintCounterButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: OrganizationBlueprintTheme.border,
            width: 0.6,
          ),
        ),
        child: Icon(icon, size: 18, color: OrganizationBlueprintTheme.dark),
      ),
    );
  }
}

class OrganizationBlueprintConfirmButton extends StatelessWidget {
  const OrganizationBlueprintConfirmButton({
    super.key,
    required this.isSaving,
    required this.onPressed,
  });

  final bool isSaving;
  final Future<void> Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: OrganizationBlueprintTheme.dark,
          disabledBackgroundColor: OrganizationBlueprintTheme.dark.withValues(
            alpha: 0.45,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: OrganizationBlueprintTheme.primary,
                ),
              )
            : Text(
                'ACTIVATE ORGANIZATION VISION',
                style: GoogleFonts.plusJakartaSans(
                  color: OrganizationBlueprintTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
      ),
    );
  }
}
