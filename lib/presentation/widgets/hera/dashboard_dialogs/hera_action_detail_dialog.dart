import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:e_team/presentation/widgets/hera/hera_shared_widgets.dart';

class HeraActionDetailDialog extends StatelessWidget {
  const HeraActionDetailDialog({super.key, required this.action});

  final Map<String, dynamic> action;

  @override
  Widget build(BuildContext context) {
    final details = action['details'] is Map<String, dynamic>
        ? action['details'] as Map<String, dynamic>
        : <String, dynamic>{};

    final date = action['created_at'] != null
        ? DateFormat(
            'dd MMMM yyyy · HH:mm',
            'fr_FR',
          ).format(DateTime.parse(action['created_at']))
        : 'Date inconnue';

    return AlertDialog(
      backgroundColor: HeraPalette.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: const Row(
        children: [
          Icon(Icons.auto_awesome, color: HeraPalette.mauve, size: 18),
          SizedBox(width: 10),
          Text(
            'Détails',
            style: TextStyle(color: HeraPalette.textPrimary, fontSize: 16),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type : ${action['action_type'] ?? '—'}',
              style: const TextStyle(
                color: HeraPalette.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: const TextStyle(
                color: HeraPalette.textMuted,
                fontSize: 11,
              ),
            ),
            const Divider(color: HeraPalette.border, height: 24),
            ...details.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: HeraPalette.textPrimary,
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(
                        text: '${entry.key} : ',
                        style: const TextStyle(
                          color: HeraPalette.mauve,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: '${entry.value}'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Fermer',
            style: TextStyle(color: HeraPalette.textMuted),
          ),
        ),
      ],
    );
  }
}
