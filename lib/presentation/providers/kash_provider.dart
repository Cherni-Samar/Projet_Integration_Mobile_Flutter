import 'package:flutter/foundation.dart';

import 'package:e_team/data/services/kash_service.dart';
import 'package:e_team/domain/models/kash/kash_budget_model.dart';
import 'package:e_team/domain/models/kash/kash_expense_model.dart';
import 'package:e_team/domain/models/kash/kash_reminder_model.dart';

class KashProvider extends ChangeNotifier {
  bool _loadingExpenses = false;
  bool _loadingBudgets = false;
  bool _loadingReminders = false;
  String? _error;

  List<KashExpense> _expenses = [];
  List<KashBudget> _budgets = [];
  List<KashReminder> _reminders = [];

  bool get loadingExpenses => _loadingExpenses;
  bool get loadingBudgets => _loadingBudgets;
  bool get loadingReminders => _loadingReminders;
  bool get isLoading =>
      _loadingExpenses || _loadingBudgets || _loadingReminders;
  String? get error => _error;

  List<KashExpense> get expenses => List.unmodifiable(_expenses);
  List<KashBudget> get budgets => List.unmodifiable(_budgets);
  List<KashReminder> get reminders => List.unmodifiable(_reminders);

  double get totalSpent =>
      _expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
  int get paidRemindersCount => _reminders.where((item) => item.isPaid).length;
  int get overdueRemindersCount =>
      _reminders.where((item) => item.isOverdue).length;

  Future<void> loadDashboardData() async {
    _error = null;
    notifyListeners();

    await Future.wait([loadExpenses(), loadBudgets(), loadReminders()]);
  }

  Future<void> refresh() => loadDashboardData();

  Future<void> loadExpenses() async {
    _loadingExpenses = true;
    notifyListeners();

    try {
      _expenses = await KashService.getExpenses();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingExpenses = false;
      notifyListeners();
    }
  }

  Future<void> loadBudgets() async {
    _loadingBudgets = true;
    notifyListeners();

    try {
      _budgets = await KashService.getBudget();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingBudgets = false;
      notifyListeners();
    }
  }

  Future<void> loadReminders() async {
    _loadingReminders = true;
    notifyListeners();

    try {
      _reminders = await KashService.getReminders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingReminders = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> addExpense(Map<String, dynamic> data) async {
    final result = await KashService.addExpense(data);
    await loadExpenses();
    return result;
  }

  Future<Map<String, dynamic>> createBudget({
    required String category,
    required double limit,
    String currency = 'TND',
  }) async {
    final result = await KashService.createBudget(
      category: category,
      limit: limit,
      currency: currency,
    );
    await loadBudgets();
    return result;
  }

  Future<Map<String, dynamic>> createReminder(Map<String, dynamic> data) async {
    final result = await KashService.createReminder(data);
    await loadReminders();
    return result;
  }

  Future<Map<String, dynamic>> markReminderPaid(String id) async {
    final result = await KashService.markReminderPaid(id);
    await loadReminders();
    await loadExpenses();
    return result;
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }
}
