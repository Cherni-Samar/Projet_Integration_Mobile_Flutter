import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:e_team/presentation/models/timo/timo_task_view_model.dart';
import 'package:e_team/presentation/widgets/timo/timo_calendar_card.dart';
import 'package:e_team/presentation/widgets/timo/timo_design_system.dart';
import 'package:e_team/presentation/widgets/timo/timo_common_widgets.dart';
import 'package:e_team/presentation/widgets/timo/timo_task_widgets.dart';

class TimoAgendaTab extends StatelessWidget {
  const TimoAgendaTab({
    super.key,
    required this.tasks,
    required this.dayTasks,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.tasksOn,
    required this.onRefresh,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
    required this.onToggleFormat,
  });

  final List<TimoTask> tasks;
  final List<TimoTask> dayTasks;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat calendarFormat;
  final List<TimoTask> Function(DateTime day) tasksOn;
  final Future<void> Function() onRefresh;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final ValueChanged<CalendarFormat> onFormatChanged;
  final ValueChanged<DateTime> onPageChanged;
  final VoidCallback onToggleFormat;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: TimoDesignSystem.other,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        children: [
          TimoCalendarCard(
            tasks: tasks,
            focusedDay: focusedDay,
            selectedDay: selectedDay,
            calendarFormat: calendarFormat,
            tasksOn: tasksOn,
            onDaySelected: onDaySelected,
            onFormatChanged: onFormatChanged,
            onPageChanged: onPageChanged,
            onToggleFormat: onToggleFormat,
          ),
          const SizedBox(height: 14),
          const TimoAgendaLegend(),
          const SizedBox(height: 20),
          TimoSelectedDayHeader(
            selectedDay: selectedDay,
            taskCount: dayTasks.length,
          ),
          const SizedBox(height: 12),
          if (dayTasks.isEmpty)
            const TimoEmptyState(
              icon: Icons.event_available_rounded,
              title: 'Aucun planning',
              sub: 'Rien de planifié ce jour-là.',
            )
          else
            ...dayTasks.map((task) => TimoTaskCard(task: task)),
        ],
      ),
    );
  }
}

class TimoAgendaLegend extends StatelessWidget {
  const TimoAgendaLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TimoDesignSystem.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TimoDesignSystem.border, width: 0.5),
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 8,
        children: [
          TimoLegendChip(label: 'Interview', color: TimoDesignSystem.interview),
          TimoLegendChip(
            label: 'Onboarding',
            color: TimoDesignSystem.onboarding,
          ),
          TimoLegendChip(
            label: 'Offboarding',
            color: TimoDesignSystem.offboarding,
          ),
        ],
      ),
    );
  }
}

class TimoSelectedDayHeader extends StatelessWidget {
  const TimoSelectedDayHeader({
    super.key,
    required this.selectedDay,
    required this.taskCount,
  });

  final DateTime? selectedDay;
  final int taskCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          selectedDay != null
              ? 'Plannings du ${DateFormat('d MMMM', 'fr_FR').format(selectedDay!)}'
              : 'Sélectionnez une date',
          style: GoogleFonts.plusJakartaSans(
            color: TimoDesignSystem.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        if (taskCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: TimoDesignSystem.other.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$taskCount',
              style: GoogleFonts.plusJakartaSans(
                color: TimoDesignSystem.other,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }
}
