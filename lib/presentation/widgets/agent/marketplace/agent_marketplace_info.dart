import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/utils/domain_model_color_extensions.dart';
import 'package:flutter/material.dart';

class AgentMarketplaceTitle extends StatelessWidget {
  const AgentMarketplaceTitle({
    super.key,
    required this.isDark,
    required this.agentCount,
    required this.l10n,
  });

  final bool isDark;
  final int agentCount;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFCDFF00), Color(0xFFAADD00)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.agentMarketplaceTitle,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.touch_app,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.5),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.agentMarketplaceSwipeToExplore(agentCount),
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.5),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AgentMarketplaceInfo extends StatelessWidget {
  const AgentMarketplaceInfo({
    super.key,
    required this.agent,
    required this.isDark,
    required this.l10n,
  });

  final Map<String, dynamic> agent;
  final bool isDark;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(agent['name']),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            agent['description'],
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.75)
                  : Colors.black.withValues(alpha: 0.75),
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AgentStat(
                icon: Icons.flash_on,
                label: l10n.agentMarketplaceStatResponse,
                value: agent['stats']['response'],
                color: const Color(0xFFCDFF00),
                isDark: isDark,
              ),
              _AgentStat(
                icon: Icons.check_circle,
                label: l10n.agentMarketplaceStatAccuracy,
                value: agent['stats']['accuracy'],
                color: const Color(0xFFA855F7),
                isDark: isDark,
              ),
              _AgentStat(
                icon: Icons.language,
                label: l10n.agentMarketplaceStatLanguages,
                value: agent['stats']['languages'],
                color: colorFromValue(agent['color']),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AgentStat extends StatelessWidget {
  const _AgentStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.05),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.black.withValues(alpha: 0.6),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
