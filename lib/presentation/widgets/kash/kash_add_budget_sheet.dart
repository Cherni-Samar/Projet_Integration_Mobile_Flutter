import 'package:flutter/material.dart';
import 'package:e_team/data/services/kash_service.dart';
import 'package:e_team/presentation/widgets/common/app_snack_bar.dart';
import 'package:e_team/presentation/widgets/kash/kash_theme.dart';

/// Shows the Add Budget bottom sheet.
///
/// [onBudgetCreated] is called after a successful API response so the caller
/// can refresh its data and update the energy balance.
Future<void> showKashAddBudgetSheet({
  required BuildContext context,
  required bool isDark,
  required VoidCallback onBudgetCreated,
}) async {
  final amountController = TextEditingController();
  String selectedCurrency = 'TND';
  String selectedCategory = 'Marketing';

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: KP.card(isDark),
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
              'Ajouter un Budget',
              style: Theme.of(
                sheetContext,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            Text(
              'Catégorie',
              style: TextStyle(
                color: KP.text(isDark),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: InputDecoration(
                labelText: 'Sélectionner une catégorie',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: KP.cardSoft(isDark),
              ),
              items: const [
                DropdownMenuItem(value: 'SaaS', child: Text('SaaS')),
                DropdownMenuItem(value: 'Marketing', child: Text('Marketing')),
                DropdownMenuItem(value: 'Travel', child: Text('Travel')),
                DropdownMenuItem(value: 'Office', child: Text('Office')),
                DropdownMenuItem(value: 'Salaries', child: Text('Salaries')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setModalState(() => selectedCategory = value);
                }
              },
              dropdownColor: KP.card(isDark),
            ),
            const SizedBox(height: 14),

            // Limit Amount TextField
            Text(
              'Montant Limite',
              style: TextStyle(
                color: KP.text(isDark),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              style: TextStyle(color: KP.text(isDark)),
              decoration: InputDecoration(
                labelText: 'Ex: 5000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: KP.cardSoft(isDark),
              ),
            ),
            const SizedBox(height: 14),

            // Currency Dropdown
            Text(
              'Devise',
              style: TextStyle(
                color: KP.text(isDark),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: selectedCurrency,
              decoration: InputDecoration(
                labelText: 'Sélectionner une devise',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: KP.cardSoft(isDark),
              ),
              items: const [
                DropdownMenuItem(value: 'TND', child: Text('TND (Tunisien)')),
                DropdownMenuItem(value: 'USD', child: Text('USD (Américain)')),
                DropdownMenuItem(value: 'EUR', child: Text('EUR (Européen)')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setModalState(() => selectedCurrency = value);
                }
              },
              dropdownColor: KP.card(isDark),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: Text(
                    'Annuler',
                    style: TextStyle(color: KP.textMuted(isDark)),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: KP.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final navigator = Navigator.of(sheetContext);

                    if (selectedCategory.isEmpty ||
                        amountController.text.isEmpty) {
                      AppSnackBar.warning(
                        context,
                        'Veuillez remplir tous les champs',
                      );
                      return;
                    }

                    try {
                      final amount = double.parse(amountController.text);
                      if (amount <= 0) {
                        AppSnackBar.warning(
                          context,
                          'Le montant doit être supérieur à 0',
                        );
                        return;
                      }

                      await KashService.createBudget(
                        category: selectedCategory,
                        limit: amount,
                        currency: selectedCurrency,
                      );

                      if (!sheetContext.mounted) return;

                      navigator.pop();

                      // Notify caller to refresh dashboard + energy balance.
                      onBudgetCreated();

                      AppSnackBar.success(context, 'Budget créé avec succès');
                    } on FormatException {
                      AppSnackBar.error(context, 'Montant invalide');
                    } catch (e) {
                      AppSnackBar.error(context, 'Erreur: $e');
                    }
                  },
                  child: const Text(
                    'Créer le Budget',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
