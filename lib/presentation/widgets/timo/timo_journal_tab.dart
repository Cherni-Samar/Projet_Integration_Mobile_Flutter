import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:e_team/presentation/models/timo/timo_task_view_model.dart';
import 'package:e_team/presentation/widgets/timo/timo_design_system.dart';
import 'package:e_team/presentation/widgets/timo/timo_shared_widgets.dart';

class TimoJournalTab extends StatelessWidget {
  const TimoJournalTab({
    super.key,
    required this.tasks,
    required this.filteredTasks,
    required this.activeFilter,
    required this.interviewsCount,
    required this.onboardingsCount,
    required this.offboardingsCount,
    required this.doneCount,
    required this.onRefresh,
    required this.onFilterChanged,
  });

  final List<TimoTask> tasks;
  final List<TimoTask> filteredTasks;
  final TaskType? activeFilter;
  final int interviewsCount;
  final int onboardingsCount;
  final int offboardingsCount;
  final int doneCount;
  final Future<void> Function() onRefresh;
  final ValueChanged<TaskType?> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const TimoEmptyState(
        icon: Icons.article_outlined,
        title: 'Aucune tâche planifiée',
        sub: 'Hera n\'a encore rien envoyé à Timo.',
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: TimoDesignSystem.other,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        children: [
          TimoStatsCard(
            interviews: interviewsCount,
            onboardings: onboardingsCount,
            offboardings: offboardingsCount,
            done: doneCount,
            total: tasks.length,
          ),
          const SizedBox(height: 16),
          TimoFilterPills(
            activeFilter: activeFilter,
            onFilterChanged: onFilterChanged,
          ),
          const SizedBox(height: 16),
          if (filteredTasks.isEmpty)
            const TimoEmptyState(
              icon: Icons.filter_list_off_rounded,
              title: 'Aucun résultat',
              sub: 'Pas de tâche pour ce filtre.',
            )
          else
            ...filteredTasks.map((task) => TimoTaskCard(task: task)),
        ],
      ),
    );
  }
}

class TimoFilterPills extends StatelessWidget {
  const TimoFilterPills({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final TaskType? activeFilter;
  final ValueChanged<TaskType?> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final filters = [
      (null, 'Tous', TimoDesignSystem.other),
      (TaskType.interview, 'Interview', TimoDesignSystem.interview),
      (TaskType.onboarding, 'Onboarding', TimoDesignSystem.onboarding),
      (TaskType.offboarding, 'Offboarding', TimoDesignSystem.offboarding),
    ];

    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: filters.map((filter) {
          final selected = activeFilter == filter.$1;
          return GestureDetector(
            onTap: () => onFilterChanged(filter.$1),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: selected ? filter.$3 : TimoDesignSystem.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? filter.$3 : TimoDesignSystem.border,
                  width: 0.5,
                ),
              ),
              child: Text(
                filter.$2,
                style: GoogleFonts.plusJakartaSans(
                  color: selected ? Colors.white : TimoDesignSystem.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
