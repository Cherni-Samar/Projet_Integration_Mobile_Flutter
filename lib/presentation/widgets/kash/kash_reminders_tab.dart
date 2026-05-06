import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'kash_theme.dart';

/// Reminders tab for Kash dashboard showing all payment reminders
class KashRemindersTab extends StatelessWidget {
  final bool isDark;
  final bool loadingReminders;
  final List<dynamic> reminders;
  final VoidCallback onAddReminder;
  final Widget Function(String message, IconData icon, bool isDark)
  buildEmptyState;
  final dynamic Function(dynamic item, String key) readValue;
  final DateTime Function(dynamic value) safeDate;
  final Future<void> Function(String reminderId) onMarkReminderPaid;

  const KashRemindersTab({
    Key? key,
    required this.isDark,
    required this.loadingReminders,
    required this.reminders,
    required this.onAddReminder,
    required this.buildEmptyState,
    required this.readValue,
    required this.safeDate,
    required this.onMarkReminderPaid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (loadingReminders)
      return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        // Header with Add button - ALWAYS VISIBLE
        Container(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Row(
            children: [
              Text(
                'Rappels de paiement',
                style: TextStyle(
                  color: KP.text(isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onAddReminder,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: KP.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 13, color: KP.primary),
                      const SizedBox(width: 5),
                      const Text(
                        'Ajouter',
                        style: TextStyle(
                          color: KP.primary,
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
        ),
        const SizedBox(height: 16),
        // Content - either list or empty state
        Expanded(
          child: reminders.isEmpty
              ? Center(
                  child: buildEmptyState(
                    'Aucun paiement',
                    Icons.notifications_off_rounded,
                    isDark,
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  children: reminders
                      .map((r) => _buildReminderCard(r))
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildReminderCard(dynamic reminder) {
    final title = (readValue(reminder, 'title') ?? 'Unnamed').toString();
    final status = (readValue(reminder, 'status') ?? 'pending').toString();
    final amount = (readValue(reminder, 'amount') as num?)?.toDouble() ?? 0.0;

    final dueDate = safeDate(readValue(reminder, 'dueDate'));

    final isOverdue = status == 'pending' && dueDate.isBefore(DateTime.now());

    final reminderId = readValue(reminder, '_id') ?? readValue(reminder, 'id');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: KP.card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOverdue
              ? KP.danger.withValues(alpha: 0.3)
              : KP.border(isDark),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isOverdue
                      ? KP.danger.withValues(alpha: 0.12)
                      : KP.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isOverdue
                      ? Icons.priority_high_rounded
                      : Icons.notifications_rounded,
                  color: isOverdue ? KP.danger : KP.warning,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: status == 'paid'
                            ? KP.textMuted(isDark)
                            : KP.text(isDark),
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        decoration: status == 'paid'
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: KP.textMuted(isDark),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('EEE dd MMM', 'fr_FR').format(dueDate),
                          style: TextStyle(
                            color: KP.textMuted(isDark),
                            fontSize: 11,
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
                  Text(
                    '$amount DT',
                    style: TextStyle(
                      color: isOverdue ? KP.danger : KP.text(isDark),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (status != 'paid')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isOverdue
                            ? KP.danger.withValues(alpha: 0.12)
                            : KP.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isOverdue ? 'RETARD' : 'À VENIR',
                        style: TextStyle(
                          color: isOverdue ? KP.danger : KP.warning,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: KP.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'PAYÉ',
                        style: TextStyle(
                          color: KP.success,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (status == 'pending') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => onMarkReminderPaid(reminderId),
                style: FilledButton.styleFrom(
                  backgroundColor: KP.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Mark as Paid',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
