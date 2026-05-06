import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:e_team/data/services/kash_service.dart';

/// Shows the Add Reminder bottom sheet.
///
/// [onReminderCreated] is called after a successful API response so the caller
/// can refresh its data and update the energy balance.
Future<void> showKashAddReminderSheet({
  required BuildContext context,
  required bool isDark,
  required VoidCallback onReminderCreated,
}) async {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final notesController = TextEditingController();
  String selectedCurrency = 'TND';
  DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

  // Capture messenger before the async gap introduced by showModalBottomSheet.
  final messenger = ScaffoldMessenger.of(context);

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setModalState) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Reminder',
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedCurrency,
              decoration: InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: ['TND', 'USD', 'EUR'].map((cur) {
                return DropdownMenuItem(value: cur, child: Text(cur));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setModalState(() => selectedCurrency = value);
                }
              },
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: sheetContext,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setModalState(() => selectedDate = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () async {
                    final navigator = Navigator.of(sheetContext);

                    if (titleController.text.isEmpty ||
                        amountController.text.isEmpty) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }

                    try {
                      await KashService.createReminder({
                        'title': titleController.text,
                        'amount': double.parse(amountController.text),
                        'currency': selectedCurrency,
                        'dueDate': selectedDate.toIso8601String(),
                        'notes': notesController.text,
                      });

                      if (!sheetContext.mounted) return;

                      navigator.pop();

                      // Notify caller to refresh dashboard + energy balance.
                      onReminderCreated();

                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('✅ Reminder created'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('❌ Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
