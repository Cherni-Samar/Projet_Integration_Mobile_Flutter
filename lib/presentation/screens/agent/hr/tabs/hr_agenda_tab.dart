import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:e_team/domain/models/hera_models.dart';
import '../hr_shared_widgets.dart';

/// Agenda tab — calendar view of approved leaves.
/// All state lives in [_HrDashboardPageState]; this widget is pure UI.
class HrAgendaTab extends StatelessWidget {
  final DateTime? selectedDay;
  final DateTime focusedDay;
  final CalendarFormat calendarFormat;
  final List<HeraLeave> allLeaves;
  final Future<void> Function() onRefresh;

  /// Called when the user taps a day.
  final void Function(DateTime selected, DateTime focused) onDaySelected;

  /// Called when the user changes the calendar format (month/2weeks/week).
  final void Function(CalendarFormat format) onFormatChanged;

  /// Called when the calendar page changes (month swipe).
  final void Function(DateTime focused) onPageChanged;

  const HrAgendaTab({
    super.key,
    required this.selectedDay,
    required this.focusedDay,
    required this.calendarFormat,
    required this.allLeaves,
    required this.onRefresh,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  });

  // ─── Pure helper — no state access ──────────────────────────────────────────

  List<HeraLeave> _leavesForDay(DateTime day) {
    return allLeaves.where((leave) {
      if (leave.status != 'approved') return false;
      return !day.isBefore(leave.startDate) && !day.isAfter(leave.endDate);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final leaves =
        selectedDay != null ? _leavesForDay(selectedDay!) : <HeraLeave>[];

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: HeraPalette.mauve,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          const HrSectionHeader(label: 'Absences & Congés'),
          const SizedBox(height: 4),
          const Text(
            'Sélectionnez une date pour voir les absences approuvées.',
            style: TextStyle(color: HeraPalette.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          _CalendarCard(
            focusedDay: focusedDay,
            selectedDay: selectedDay,
            calendarFormat: calendarFormat,
            leavesForDay: _leavesForDay,
            onDaySelected: onDaySelected,
            onFormatChanged: onFormatChanged,
            onPageChanged: onPageChanged,
          ),
          const SizedBox(height: 14),
          _buildCalendarLegend(),
          const SizedBox(height: 20),
          Text(
            selectedDay != null
                ? 'Congés du ${DateFormat('d MMMM yyyy', 'fr_FR').format(selectedDay!)}'
                : 'Sélectionnez une date',
            style: const TextStyle(
              color: HeraPalette.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (leaves.isEmpty)
            const HrEmptyState(
              icon: Icons.event_available_rounded,
              title: 'Aucun congé',
              sub: 'Pas d\'absence ce jour-là',
            )
          else
            ...leaves.map(_LeaveDetailCard.new),
        ],
      ),
    );
  }

  Widget _buildCalendarLegend() {
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
          HrLegendChip(label: 'Congé annuel', color: HeraPalette.mauve),
          HrLegendChip(label: 'Maladie', color: HeraPalette.warning),
          HrLegendChip(label: 'Urgent', color: HeraPalette.danger),
        ],
      ),
    );
  }
}

// ─── Private widgets used only by this tab ──────────────────────────────────

class _CalendarCard extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat calendarFormat;
  final List<HeraLeave> Function(DateTime) leavesForDay;
  final void Function(DateTime, DateTime) onDaySelected;
  final void Function(CalendarFormat) onFormatChanged;
  final void Function(DateTime) onPageChanged;

  const _CalendarCard({
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

            final color = dayLeaves.any((l) => l.type == 'urgent')
                ? HeraPalette.danger
                : dayLeaves.any((l) => l.type == 'sick')
                    ? HeraPalette.warning
                    : HeraPalette.mauve;

            return Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.5)),
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
            color: HeraPalette.mauve.withOpacity(0.15),
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

class _LeaveDetailCard extends StatelessWidget {
  final HeraLeave leave;

  const _LeaveDetailCard(this.leave);

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
                  color: color.withOpacity(0.12),
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
