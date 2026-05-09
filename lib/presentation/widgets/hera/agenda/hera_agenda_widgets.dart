import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:e_team/domain/models/hera_models.dart';
import 'package:e_team/presentation/widgets/hera/hera_shared_widgets.dart';

class HeraAgendaCalendarCard extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat calendarFormat;
  final List<HeraLeave> Function(DateTime) leavesForDay;
  final void Function(DateTime, DateTime) onDaySelected;
  final void Function(CalendarFormat) onFormatChanged;
  final void Function(DateTime) onPageChanged;

  const HeraAgendaCalendarCard({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.leavesForDay,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HeraPalette.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: HeraPalette.border),
      ),
      child: TableCalendar<HeraLeave>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        calendarFormat: calendarFormat,
        onDaySelected: onDaySelected,
        onFormatChanged: onFormatChanged,
        onPageChanged: onPageChanged,
        eventLoader: leavesForDay,
        calendarBuilders: CalendarBuilders<HeraLeave>(
          defaultBuilder: (context, day, _) {
            final dayLeaves = leavesForDay(day);
            if (dayLeaves.isEmpty) return null;

            final color = dayLeaves.any((leave) => leave.type == 'urgent')
                ? HeraPalette.danger
                : dayLeaves.any((leave) => leave.type == 'sick')
                ? HeraPalette.warning
                : HeraPalette.mauve;

            return Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.5)),
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return null;
            return Positioned(
              bottom: 3,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: events.take(3).map((leave) {
                  final color = leave.type == 'urgent'
                      ? HeraPalette.danger
                      : leave.type == 'sick'
                      ? HeraPalette.warning
                      : HeraPalette.mauve;
                  return Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(
            shape: BoxShape.circle,
            color: HeraPalette.mauve,
          ),
          selectedDecoration: BoxDecoration(
            shape: BoxShape.circle,
            color: HeraPalette.violet,
          ),
          todayTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
          selectedTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
          defaultTextStyle: TextStyle(
            color: HeraPalette.textPrimary,
            fontSize: 13,
          ),
          weekendTextStyle: TextStyle(
            color: HeraPalette.textSoft,
            fontSize: 13,
          ),
          outsideTextStyle: TextStyle(color: HeraPalette.border),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: HeraPalette.mauve.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          formatButtonTextStyle: const TextStyle(
            color: HeraPalette.mauve,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
          titleTextStyle: const TextStyle(
            color: HeraPalette.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
          leftChevronIcon: const Icon(
            Icons.chevron_left_rounded,
            color: HeraPalette.textPrimary,
            size: 24,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right_rounded,
            color: HeraPalette.textPrimary,
            size: 24,
          ),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: HeraPalette.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          weekendStyle: TextStyle(
            color: HeraPalette.textMuted,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class HeraAgendaLegend extends StatelessWidget {
  const HeraAgendaLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HeraPalette.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HeraPalette.border),
      ),
      child: const Wrap(
        spacing: 20,
        runSpacing: 8,
        children: [
          HeraLegendChip(label: 'Congé annuel', color: HeraPalette.mauve),
          HeraLegendChip(label: 'Maladie', color: HeraPalette.warning),
          HeraLegendChip(label: 'Urgent', color: HeraPalette.danger),
        ],
      ),
    );
  }
}

class HeraLeaveDetailCard extends StatelessWidget {
  final HeraLeave leave;

  const HeraLeaveDetailCard(this.leave, {super.key});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM yyyy', 'fr_FR');
    final icon = leave.type == 'sick'
        ? Icons.medical_services
        : leave.type == 'urgent'
        ? Icons.warning_amber_rounded
        : Icons.beach_access;
    final color = leave.type == 'sick'
        ? HeraPalette.warning
        : leave.type == 'urgent'
        ? HeraPalette.danger
        : HeraPalette.mauve;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HeraPalette.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HeraPalette.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.employeeName.isEmpty ? '—' : leave.employeeName,
                      style: const TextStyle(
                        color: HeraPalette.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${leave.days} jour${leave.days > 1 ? "s" : ""}',
                      style: const TextStyle(
                        color: HeraPalette.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: HeraPalette.cardSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 13,
                      color: HeraPalette.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${fmt.format(leave.startDate)} → ${fmt.format(leave.endDate)}',
                        style: const TextStyle(
                          color: HeraPalette.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                if (leave.reason.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 13,
                        color: HeraPalette.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          leave.reason,
                          style: const TextStyle(
                            color: HeraPalette.textSoft,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
