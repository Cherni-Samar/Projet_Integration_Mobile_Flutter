import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:e_team/domain/models/hera_models.dart';
import 'package:e_team/presentation/widgets/hera/hera_shared_widgets.dart';

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
