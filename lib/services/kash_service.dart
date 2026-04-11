import 'package:intl/intl.dart';
import 'api_config.dart';
import 'api_service.dart';
import 'auth_service.dart';

class KashService {
  static final AuthService _authService = AuthService();

  static String get _baseUrl => '${ApiConfig.baseUrl}/api/kash';

  // ===========================================================================
  // EXPENSES
  // ===========================================================================

  /// Fetch all expenses for the current user (last 50, sorted by date desc)
  /// GET /api/kash/expenses
  static Future<List<dynamic>> getExpenses() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await ApiService.get(
        endpoint: '$_baseUrl/expenses',
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch expenses');
      }

      return response['data']['expenses'] ?? [];
    } catch (e) {
      print('❌ KashService - getExpenses error: $e');
      rethrow;
    }
  }

  /// Add a new expense
  /// POST /api/kash/add
  /// Body: { amount, currency, vendor, category, date, description, ... }
  static Future<Map<String, dynamic>> addExpense(
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await ApiService.post(
        endpoint: '$_baseUrl/add',
        body: data,
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to add expense');
      }

      return response['data'] ?? {};
    } catch (e) {
      print('❌ KashService - addExpense error: $e');
      rethrow;
    }
  }

  // ===========================================================================
  // BUDGET
  // ===========================================================================

  /// Get budget array for the current user
  /// GET /api/kash/budget
  static Future<List<dynamic>> getBudget() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await ApiService.get(
        endpoint: '$_baseUrl/budget',
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch budget');
      }

      return response['data']['budget'] ?? [];
    } catch (e) {
      print('❌ KashService - getBudget error: $e');
      rethrow;
    }
  }

  /// Add or update a budget entry
  /// POST /api/kash/budget
  /// Body: { project, amount }
  static Future<List<dynamic>> setBudget(
    String project,
    double amount,
  ) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

      if (project.trim().isEmpty) {
        throw Exception('Project name is required');
      }

      if (amount < 0) {
        throw Exception('Amount must be greater than or equal to 0');
      }

      final response = await ApiService.post(
        endpoint: '$_baseUrl/budget',
        body: {
          'project': project.trim(),
          'amount': amount,
        },
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to set budget');
      }

      return response['data']['budget'] ?? [];
    } catch (e) {
      print('❌ KashService - setBudget error: $e');
      rethrow;
    }
  }

  // ===========================================================================
  // REMINDERS
  // ===========================================================================

  /// Fetch all reminders for the current user (sorted by dueDate asc)
  /// GET /api/kash/reminders
  static Future<List<dynamic>> getReminders() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await ApiService.get(
        endpoint: '$_baseUrl/reminders',
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch reminders');
      }

      return response['data']['reminders'] ?? [];
    } catch (e) {
      print('❌ KashService - getReminders error: $e');
      rethrow;
    }
  }

  /// Create a new payment reminder
  /// POST /api/kash/reminders
  /// Body: { title, amount, currency, dueDate, notes }
  static Future<Map<String, dynamic>> createReminder(
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

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
      };

      final response = await ApiService.post(
        endpoint: '$_baseUrl/reminders',
        body: body,
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to create reminder');
      }

      return response['data']['reminder'] ?? {};
    } catch (e) {
      print('❌ KashService - createReminder error: $e');
      rethrow;
    }
  }

  /// Mark a reminder as paid
  /// PATCH /api/kash/reminders/:id/mark-paid
  static Future<Map<String, dynamic>> markReminderPaid(String id) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

      if (id.trim().isEmpty) {
        throw Exception('Reminder ID is required');
      }

      final response = await ApiService.patch(
        endpoint: '$_baseUrl/reminders/${id.trim()}/mark-paid',
        body: {},
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to mark reminder as paid');
      }

      return response['data']['reminder'] ?? {};
    } catch (e) {
      print('❌ KashService - markReminderPaid error: $e');
      rethrow;
    }
  }

  // ===========================================================================
  // RECEIPT ANALYSIS (Gemini AI)
  // ===========================================================================

  /// Analyze a receipt image via Gemini AI
  /// POST /api/kash/analyze
  /// Body: { imageBase64 }
  static Future<Map<String, dynamic>> analyzeReceipt(String base64Image) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

      if (base64Image.trim().isEmpty) {
        throw Exception('Image data is required');
      }

      final response = await ApiService.post(
        endpoint: '$_baseUrl/analyze',
        body: {
          'imageBase64': base64Image.trim(),
        },
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to analyze receipt');
      }

      return response['data'] ?? {};
    } catch (e) {
      print('❌ KashService - analyzeReceipt error: $e');
      rethrow;
    }
  }
}
