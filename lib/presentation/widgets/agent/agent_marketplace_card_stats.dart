import 'package:flutter/material.dart';

class AgentMarketplaceStat {
  const AgentMarketplaceStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class AgentMarketplaceStatsRow extends StatelessWidget {
  const AgentMarketplaceStatsRow({
    super.key,
    required this.agentName,
    required this.agentColor,
    required this.isDark,
  });

  final String agentName;
  final Color agentColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: agentMarketplaceStatsFor(agentName)
          .map(
            (stat) => AgentMarketplaceStatItem(
              stat: stat,
              agentColor: agentColor,
              isDark: isDark,
            ),
          )
          .toList(),
    );
  }
}

class AgentMarketplaceStatItem extends StatelessWidget {
  const AgentMarketplaceStatItem({
    super.key,
    required this.stat,
    required this.agentColor,
    required this.isDark,
  });

  final AgentMarketplaceStat stat;
  final Color agentColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(stat.icon, color: agentColor.withValues(alpha: 0.7), size: 16),
          const SizedBox(height: 3),
          Text(
            stat.value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            stat.label,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.5),
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

List<AgentMarketplaceStat> agentMarketplaceStatsFor(String agentName) {
  switch (agentName.toLowerCase()) {
    case 'hera':
      return const [
        AgentMarketplaceStat(
          label: 'HR Requests',
          value: '12',
          icon: Icons.person_add,
        ),
        AgentMarketplaceStat(
          label: 'Interviews',
          value: '4',
          icon: Icons.event,
        ),
        AgentMarketplaceStat(
          label: 'Pending',
          value: '3',
          icon: Icons.pending_actions,
        ),
      ];
    case 'kash':
      return const [
        AgentMarketplaceStat(
          label: 'Budgets',
          value: '8',
          icon: Icons.account_balance,
        ),
        AgentMarketplaceStat(
          label: 'Approved',
          value: '15',
          icon: Icons.check_circle,
        ),
        AgentMarketplaceStat(label: 'Rejected', value: '2', icon: Icons.cancel),
      ];
    case 'echo':
      return const [
        AgentMarketplaceStat(label: 'Posts', value: '6', icon: Icons.campaign),
        AgentMarketplaceStat(
          label: 'Campaigns',
          value: '3',
          icon: Icons.trending_up,
        ),
        AgentMarketplaceStat(
          label: 'Reach',
          value: '2.4k',
          icon: Icons.visibility,
        ),
      ];
    case 'dexo':
      return const [
        AgentMarketplaceStat(
          label: 'Reports',
          value: '5',
          icon: Icons.description,
        ),
        AgentMarketplaceStat(
          label: 'Documents',
          value: '28',
          icon: Icons.folder,
        ),
        AgentMarketplaceStat(
          label: 'Briefings',
          value: '1',
          icon: Icons.summarize,
        ),
      ];
    case 'timo':
      return const [
        AgentMarketplaceStat(
          label: 'Meetings',
          value: '9',
          icon: Icons.event_note,
        ),
        AgentMarketplaceStat(
          label: 'Reminders',
          value: '14',
          icon: Icons.notifications,
        ),
        AgentMarketplaceStat(label: 'Tasks', value: '22', icon: Icons.task_alt),
      ];
    default:
      return const [
        AgentMarketplaceStat(label: 'Tasks', value: '0', icon: Icons.task),
        AgentMarketplaceStat(label: 'Active', value: '0', icon: Icons.check),
        AgentMarketplaceStat(label: 'Pending', value: '0', icon: Icons.pending),
      ];
  }
}
