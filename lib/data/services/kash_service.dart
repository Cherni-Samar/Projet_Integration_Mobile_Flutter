import 'package:e_team/data/repositories/kash_repository.dart';
import 'package:e_team/domain/models/kash/kash_expense_model.dart';
import 'package:e_team/domain/models/kash/kash_budget_model.dart';
import 'package:e_team/domain/models/kash/kash_reminder_model.dart';
import 'package:e_team/data/dtos/kash/kash_expense_dto.dart';
import 'package:e_team/data/dtos/kash/kash_budget_dto.dart';
import 'package:e_team/data/dtos/kash/kash_reminder_dto.dart';

import 'package:e_team/data/mappers/kash_mapper.dart';

class KashService {
  static final _repo = KashRepository.instance;

  // ===========================================================================
  // EXPENSES
  // ===========================================================================

  /// Fetch all expenses for the current user (last 50, sorted by date desc)
  /// GET /api/kash/expenses
  static Future<List<KashExpense>> getExpenses() async {
    final response = await _repo.getExpenses();

    final list = response['data']['expenses'] as List;

    return list
        .map((e) => KashMapper.toExpense(KashExpenseDTO.fromJson(e)))
        .toList();
  }

  /// Add a new expense
  /// POST /api/kash/add
  /// Body: { amount, currency, vendor, category, date, description, ... }
  static Future<Map<String, dynamic>> addExpense(
    Map<String, dynamic> data,
  ) async {
    final response = await _repo.addExpense(data);

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to add expense');
    }

    return response['data'] ?? {};
  }

  // ===========================================================================
  // BUDGET
  // ===========================================================================

  /// Get budget array for the current user
  /// GET /api/kash/budget
  static Future<List<KashBudget>> getBudget() async {
    final response = await _repo.getBudget();

    final list = response['data']['budget'] as List;

    return list
        .map((e) => KashMapper.toBudget(KashBudgetDTO.fromJson(e)))
        .toList();
  }

  /// Create a new budget entry
  /// POST /api/kash/budget/create
  /// Body: { category, limit, currency }
  static Future<Map<String, dynamic>> createBudget({
    required String category,
    required double limit,
    String currency = 'TND',
  }) async {
    if (category.trim().isEmpty) {
      throw Exception('Category is required');
    }

    if (limit <= 0) {
      throw Exception('Budget limit must be greater than 0');
    }

    final response = await _repo.createBudget(
      category: category.trim(),
      limit: limit,
      currency: currency.toUpperCase(),
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to create budget');
    }

    return response['data'] ?? {};
  }

  // ===========================================================================
  // REMINDERS
  // ===========================================================================

  /// Fetch all reminders for the current user (sorted by dueDate asc)
  /// GET /api/kash/reminders
  static Future<List<KashReminder>> getReminders() async {
    final response = await _repo.getReminders();

    final list = response['data']['reminders'] as List;

    return list
        .map((e) => KashMapper.toReminder(KashReminderDTO.fromJson(e)))
        .toList();
  }

  /// Create a new payment reminder
  /// POST /api/kash/reminders
  /// Body: { title, amount, currency, dueDate, notes }
  static Future<Map<String, dynamic>> createReminder(
    Map<String, dynamic> data,
  ) async {
    // Validate required fields
    if (data['title'] == null || data['title'].toString().trim().isEmpty) {
      throw Exception('Reminder title is required');
    }

    if (data['amount'] == null) {
      throw Exception('Amount is required');
    }

    final amount = double.tryParse(data['amount'].toString());
    if (amount == null || amount <= 0) {
      throw Exception('Amount must be a positive number');
    }

    if (data['dueDate'] == null) {
      throw Exception('Due date is required');
    }

    final body = {
      'title': data['title'].toString().trim(),
      'amount': amount,
      'currency': data['currency'] ?? 'TND',
      'dueDate': data['dueDate'].toString(),
      'notes': data['notes'] ?? '',
      'category': data['category'] ?? 'Other',
      'vendor': data['vendor'] ?? '',
    };

    final response = await _repo.createReminder(body);

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to create reminder');
    }

    return response['data']['reminder'] ?? {};
  }

  /// Mark a reminder as paid
  /// PATCH /api/kash/reminders/:id/mark-paid
  static Future<Map<String, dynamic>> markReminderPaid(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('Reminder ID is required');
    }

    final response = await _repo.markReminderPaid(id.trim());

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to mark reminder as paid');
    }

    return response['data']['reminder'] ?? {};
  }

  // ===========================================================================
  // RECEIPT ANALYSIS (Gemini AI)
  // ===========================================================================

  /// Analyze a receipt image via Gemini AI
  /// POST /api/kash/analyze
  /// Body: { imageBase64 }
  static Future<Map<String, dynamic>> analyzeReceipt(String base64Image) async {
    if (base64Image.trim().isEmpty) {
      throw Exception('Image data is required');
    }

    final response = await _repo.analyzeReceipt(base64Image.trim());

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to analyze receipt');
    }

    return response['data'] ?? {};
  }
}
