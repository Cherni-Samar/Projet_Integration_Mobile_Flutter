import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:e_team/presentation/models/timo/timo_task_view_model.dart';
import 'package:e_team/presentation/widgets/timo/timo_calendar_day_cell.dart';
import 'package:e_team/presentation/widgets/timo/timo_calendar_header.dart';
import 'package:e_team/presentation/widgets/timo/timo_design_system.dart';

class TimoCalendarCard extends StatelessWidget {
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

  final List<TimoTask> tasks;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat calendarFormat;
  final List<TimoTask> Function(DateTime day) tasksOn;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final ValueChanged<CalendarFormat> onFormatChanged;
  final ValueChanged<DateTime> onPageChanged;
  final VoidCallback onToggleFormat;

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
