import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:e_team/presentation/widgets/timo/timo_design_system.dart';

class TimoCalendarHeader extends StatelessWidget {
  const TimoCalendarHeader({
    super.key,
    required this.focusedDay,
    required this.eventCount,
    required this.calendarFormat,
    required this.onToggleFormat,
  });

  final DateTime focusedDay;
  final int eventCount;
  final CalendarFormat calendarFormat;
  final VoidCallback onToggleFormat;

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
