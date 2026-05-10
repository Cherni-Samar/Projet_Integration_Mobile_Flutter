import 'package:flutter/material.dart';

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
