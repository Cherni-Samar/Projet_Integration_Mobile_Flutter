import 'package:e_team/presentation/models/timo/timo_task_view_model.dart';
import 'package:e_team/presentation/widgets/timo/timo_design_system.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TimoTaskCard extends StatelessWidget {
  final TimoTask task;

  const TimoTaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TimoDesignSystem.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isDone
              ? TimoDesignSystem.success.withValues(alpha: 0.25)
              : task.color.withValues(alpha: 0.2),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: TimoDesignSystem.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: task.isDone
                  ? TimoDesignSystem.success.withValues(alpha: 0.12)
                  : task.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              task.isDone ? Icons.task_alt_rounded : task.icon,
              color: task.isDone ? TimoDesignSystem.success : task.color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.employeeName,
                  style: GoogleFonts.plusJakartaSans(
                    color: task.isDone
                        ? TimoDesignSystem.textMuted
                        : TimoDesignSystem.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                    decorationColor: TimoDesignSystem.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                if (task.deadline != null)
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: TimoDesignSystem.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat(
                          'dd MMM • HH:mm',
                          'fr_FR',
                        ).format(task.deadline!),
                        style: GoogleFonts.plusJakartaSans(
                          color: TimoDesignSystem.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: task.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  task.typeLabel,
                  style: GoogleFonts.plusJakartaSans(
                    color: task.color,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (task.isDone) ...[
                const SizedBox(height: 6),
                Icon(
                  Icons.verified_rounded,
                  color: TimoDesignSystem.success,
                  size: 16,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
