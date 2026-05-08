import 'package:e_team/data/services/activity_service.dart';
import 'package:flutter/material.dart';

class ActivityDashboardOverview extends StatelessWidget {
  const ActivityDashboardOverview({
    super.key,
    required this.dashboard,
    required this.isDark,
  });

  final ActivityDashboard dashboard;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final overview = dashboard.overview;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.purple.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.3),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Overview (24h)',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ActivityStatCard(
                  title: 'Total Activities',
                  value: overview.activitiesLast24h.toString(),
                  icon: Icons.timeline,
                  color: Colors.blue,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActivityStatCard(
                  title: 'Success Rate',
                  value: '${overview.successRate}%',
                  icon: Icons.check_circle,
                  color: Colors.green,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ActivityStatCard(
                  title: 'Energy Used',
                  value: overview.totalEnergyConsumed.toString(),
                  icon: Icons.battery_charging_full,
                  color: Colors.orange,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActivityStatCard(
                  title: 'Failed Tasks',
                  value: overview.failedActivities.toString(),
                  icon: Icons.error,
                  color: Colors.red,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActivityStatCard extends StatelessWidget {
  const ActivityStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.grey : Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ActivityAgentFilter extends StatelessWidget {
  const ActivityAgentFilter({
    super.key,
    required this.agentFilters,
    required this.selectedAgent,
    required this.isDark,
    required this.onChanged,
  });

  final List<String> agentFilters;
  final String selectedAgent;
  final bool isDark;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Agent',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: agentFilters.map((agent) {
                final isSelected = agent == selectedAgent;
                return GestureDetector(
                  onTap: () => onChanged(agent),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.purple : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.purple
                            : (isDark ? Colors.grey : Colors.grey[400]!),
                      ),
                    ),
                    child: Text(
                      agent == 'all' ? 'All Agents' : agent.toUpperCase(),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.grey : Colors.grey[600]),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key, required this.activity, required this.isDark});

  final ActivityItem activity;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final statusColor = getActivityStatusColor(activity.status);
    final priorityColor = getActivityPriorityColor(activity.priority);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.grey.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.3),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(activity.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  activity.logEntry,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                formatActivityTimestamp(activity.timestamp),
                style: TextStyle(
                  color: isDark ? Colors.grey : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            activity.title,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (activity.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              activity.description,
              style: TextStyle(
                color: isDark ? Colors.grey : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              ActivityBadge(label: activity.status, color: statusColor),
              const SizedBox(width: 8),
              ActivityBadge(label: activity.priority, color: priorityColor),
              const Spacer(),
              const Icon(
                Icons.battery_charging_full,
                color: Colors.orange,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${activity.energyConsumed}',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActivityBadge extends StatelessWidget {
  const ActivityBadge({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ActivityLoadingMoreIndicator extends StatelessWidget {
  const ActivityLoadingMoreIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: CircularProgressIndicator(color: Colors.purple)),
    );
  }
}

Color getActivityStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'success':
      return Colors.green;
    case 'failed':
      return Colors.red;
    case 'pending':
      return Colors.orange;
    case 'in_progress':
      return Colors.blue;
    default:
      return Colors.grey;
  }
}

Color getActivityPriorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case 'high':
      return Colors.red;
    case 'medium':
      return Colors.orange;
    case 'low':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

String formatActivityTimestamp(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inMinutes < 1) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else {
    return '${difference.inDays}d ago';
  }
}
