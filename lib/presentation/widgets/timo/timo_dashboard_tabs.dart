import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:e_team/presentation/models/timo/timo_task_view_model.dart';
import 'package:e_team/presentation/widgets/timo/timo_design_system.dart';
import 'package:e_team/presentation/widgets/timo/timo_shared_widgets.dart';

class TimoJournalTab extends StatelessWidget {
  final List<TimoTask> tasks;
  final List<TimoTask> filteredTasks;
  final TaskType? activeFilter;
  final int interviewsCount;
  final int onboardingsCount;
  final int offboardingsCount;
  final int doneCount;
  final Future<void> Function() onRefresh;
  final ValueChanged<TaskType?> onFilterChanged;

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
  final TaskType? activeFilter;
  final ValueChanged<TaskType?> onFilterChanged;

  const TimoFilterPills({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

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

class TimoAgendaTab extends StatelessWidget {
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

class TimoCalendarCard extends StatelessWidget {
  final List<TimoTask> tasks;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat calendarFormat;
  final List<TimoTask> Function(DateTime day) tasksOn;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final ValueChanged<CalendarFormat> onFormatChanged;
  final ValueChanged<DateTime> onPageChanged;
  final VoidCallback onToggleFormat;

  const TimoCalendarCard({
    super.key,
    required this.tasks,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.tasksOn,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
    required this.onToggleFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TimoDesignSystem.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TimoDesignSystem.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: TimoDesignSystem.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TimoCalendarHeader(
            focusedDay: focusedDay,
            eventCount: tasks.length,
            calendarFormat: calendarFormat,
            onToggleFormat: onToggleFormat,
          ),
          TableCalendar<TimoTask>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: focusedDay,
            calendarFormat: calendarFormat,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: onDaySelected,
            onFormatChanged: onFormatChanged,
            onPageChanged: onPageChanged,
            eventLoader: tasksOn,
            calendarBuilders: CalendarBuilders<TimoTask>(
              defaultBuilder: (ctx, day, _) {
                final dayTasks = tasksOn(day);
                if (dayTasks.isEmpty) return null;
                return TimoCalendarDayCell(
                  day: day,
                  backgroundColor: TimoDesignSystem.other.withValues(
                    alpha: 0.15,
                  ),
                  borderColor: TimoDesignSystem.other.withValues(alpha: 0.45),
                  textColor: TimoDesignSystem.textPrimary,
                );
              },
              todayBuilder: (ctx, day, _) => TimoCalendarDayCell(
                day: day,
                backgroundColor: TimoDesignSystem.other,
                textColor: Colors.white,
              ),
              selectedBuilder: (ctx, day, _) => TimoCalendarDayCell(
                day: day,
                backgroundColor: const Color(0xFFF57C00),
                textColor: Colors.white,
                shadowColor: TimoDesignSystem.other.withValues(alpha: 0.5),
              ),
              markerBuilder: (ctx, date, events) {
                if (events.isEmpty) return null;
                return Positioned(
                  bottom: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: events
                        .take(3)
                        .map(
                          (task) => Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: task.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: const BoxDecoration(),
              selectedDecoration: const BoxDecoration(),
              defaultTextStyle: GoogleFonts.plusJakartaSans(
                color: TimoDesignSystem.textPrimary,
                fontSize: 13,
              ),
              weekendTextStyle: GoogleFonts.plusJakartaSans(
                color: TimoDesignSystem.textMuted,
                fontSize: 13,
              ),
              outsideTextStyle: GoogleFonts.plusJakartaSans(
                color: TimoDesignSystem.textMuted.withValues(alpha: 0.35),
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: false,
              titleTextStyle: const TextStyle(fontSize: 0),
              leftChevronIcon: Icon(
                Icons.chevron_left_rounded,
                color: TimoDesignSystem.textPrimary,
                size: 24,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right_rounded,
                color: TimoDesignSystem.textPrimary,
                size: 24,
              ),
              headerPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: GoogleFonts.plusJakartaSans(
                color: TimoDesignSystem.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
              weekendStyle: GoogleFonts.plusJakartaSans(
                color: TimoDesignSystem.other.withValues(alpha: 0.7),
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimoCalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final int eventCount;
  final CalendarFormat calendarFormat;
  final VoidCallback onToggleFormat;

  const TimoCalendarHeader({
    super.key,
    required this.focusedDay,
    required this.eventCount,
    required this.calendarFormat,
    required this.onToggleFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat(
                  'MMMM yyyy',
                  'fr_FR',
                ).format(focusedDay).toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  color: TimoDesignSystem.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                '$eventCount événements',
                style: GoogleFonts.plusJakartaSans(
                  color: TimoDesignSystem.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: onToggleFormat,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: TimoDesignSystem.other.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    calendarFormat == CalendarFormat.month
                        ? Icons.view_week_rounded
                        : Icons.calendar_month_rounded,
                    size: 13,
                    color: TimoDesignSystem.other,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    calendarFormat == CalendarFormat.month ? 'Semaine' : 'Mois',
                    style: GoogleFonts.plusJakartaSans(
                      color: TimoDesignSystem.other,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimoCalendarDayCell extends StatelessWidget {
  final DateTime day;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final Color? shadowColor;

  const TimoCalendarDayCell({
    super.key,
    required this.day,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: borderColor == null ? null : Border.all(color: borderColor!),
        boxShadow: shadowColor == null
            ? null
            : [BoxShadow(color: shadowColor!, blurRadius: 8)],
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: GoogleFonts.plusJakartaSans(
            color: textColor,
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
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
  final DateTime? selectedDay;
  final int taskCount;

  const TimoSelectedDayHeader({
    super.key,
    required this.selectedDay,
    required this.taskCount,
  });

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
