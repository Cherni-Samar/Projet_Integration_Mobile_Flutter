import 'package:flutter/material.dart';
import '../../../services/echo_service.dart';

class EchoAnalysisCard extends StatelessWidget {
  final EchoResponse analysis;

  const EchoAnalysisCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: analysis.isUrgent ? Colors.red : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildPriorityBadge(),
              const Spacer(),
              if (analysis.isUrgent) _buildUrgentBadge(),
            ],
          ),
          const SizedBox(height: 12),

          if (analysis.summary != null) ...[
            const Text(
              '📝 Résumé',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              analysis.summary!,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
          ],

          if (analysis.transcribedText != null) ...[
            const Text(
              '🎤 Message transcrit',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                analysis.transcribedText!,
                style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (analysis.actions.isNotEmpty) ...[
            const Text(
              '✅ Actions à faire',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 8),
            ...analysis.actions.map((action) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(
                      action,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            )),
          ],

          if (analysis.category != null) ...[
            const SizedBox(height: 8),
            Chip(
              label: Text(
                '📂 ${analysis.category}',
                style: const TextStyle(fontSize: 11),
              ),
              backgroundColor: Colors.grey.shade200,
              padding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    if (analysis.isUrgent) return Colors.red.shade50;
    switch (analysis.priority.toLowerCase()) {
      case 'high':
        return Colors.orange.shade50;
      case 'medium':
        return Colors.yellow.shade50;
      default:
        return Colors.green.shade50;
    }
  }

  Widget _buildPriorityBadge() {
    Color color;
    String text;

    switch (analysis.priority.toLowerCase()) {
      case 'high':
        color = Colors.red;
        text = '🔴 Priorité Haute';
        break;
      case 'medium':
        color = Colors.orange;
        text = '🟠 Priorité Moyenne';
        break;
      default:
        color = Colors.green;
        text = '🟢 Priorité Basse';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildUrgentBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red, width: 1),
      ),
      child: const Text(
        '🚨 URGENT',
        style: TextStyle(
          color: Colors.red,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
