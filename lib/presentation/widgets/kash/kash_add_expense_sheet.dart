import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:e_team/data/services/kash_service.dart';
import 'package:e_team/presentation/widgets/common/app_snack_bar.dart';

/// Shows a modal bottom sheet to add a new expense
Future<void> showKashAddExpenseSheet({
  required BuildContext context,
  required bool isDark,
  required List<String> categories,
  required VoidCallback onExpenseCreated,
}) async {
  final vendorController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  String selectedCurrency = 'TND';
  String selectedCategory = categories.isNotEmpty ? categories.first : 'Other';
  DateTime selectedDate = DateTime.now();

  showModalBottomSheet(
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
              'Add Expense',
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: vendorController,
              decoration: InputDecoration(
                labelText: 'Vendor',
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
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category / Budget Project',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setModalState(() => selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: sheetContext,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
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
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
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

                    if (vendorController.text.isEmpty ||
                        amountController.text.isEmpty) {
                      AppSnackBar.warning(context, 'Please fill all fields');
                      return;
                    }

                    try {
                      await KashService.addExpense({
                        'vendor': vendorController.text,
                        'amount': double.parse(amountController.text),
                        'currency': selectedCurrency,
                        'category': selectedCategory,
                        'date': selectedDate.toIso8601String(),
                        'description': descriptionController.text,
                      });

                      if (!sheetContext.mounted) return;

                      navigator.pop();
                      onExpenseCreated();

                      AppSnackBar.success(context, 'Expense added');
                    } catch (e) {
                      if (!sheetContext.mounted) return;
                      AppSnackBar.error(context, 'Error: $e');
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
