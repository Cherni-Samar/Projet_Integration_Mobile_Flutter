import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimoCalendarDayCell extends StatelessWidget {
  const TimoCalendarDayCell({
    super.key,
    required this.day,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    this.shadowColor,
  });

  final DateTime day;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final Color? shadowColor;

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
