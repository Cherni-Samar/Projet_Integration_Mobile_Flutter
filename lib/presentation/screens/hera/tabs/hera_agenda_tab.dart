import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:e_team/domain/models/hera_models.dart';
import 'package:e_team/presentation/widgets/hera/agenda/hera_agenda_widgets.dart';
import 'package:e_team/presentation/widgets/hera/hera_shared_widgets.dart';

/// Agenda tab — calendar view of approved leaves.
/// All state lives in [_HeraDashboardPageState]; this widget is pure UI.
class HeraAgendaTab extends StatelessWidget {
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

  const HeraAgendaTab({
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
    final leaves = selectedDay != null
        ? _leavesForDay(selectedDay!)
        : <HeraLeave>[];

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: HeraPalette.mauve,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          const HeraSectionHeader(label: 'Absences & Congés'),
          const SizedBox(height: 4),
          const Text(
            'Sélectionnez une date pour voir les absences approuvées.',
            style: TextStyle(color: HeraPalette.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          HeraAgendaCalendarCard(
            focusedDay: focusedDay,
            selectedDay: selectedDay,
            calendarFormat: calendarFormat,
            leavesForDay: _leavesForDay,
            onDaySelected: onDaySelected,
            onFormatChanged: onFormatChanged,
            onPageChanged: onPageChanged,
          ),
          const SizedBox(height: 14),
          const HeraAgendaLegend(),
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
            const HeraEmptyState(
              icon: Icons.event_available_rounded,
              title: 'Aucun congé',
              sub: 'Pas d\'absence ce jour-là',
            )
          else
            ...leaves.map(HeraLeaveDetailCard.new),
        ],
      ),
    );
  }
}
