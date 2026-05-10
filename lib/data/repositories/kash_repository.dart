import 'package:e_team/core/config/api_config.dart';
import 'package:e_team/data/services/api_service.dart';
import 'package:e_team/data/services/auth_service.dart';

class KashRepository {
  KashRepository._();
  static final KashRepository instance = KashRepository._();

  static String get _baseUrl => '${ApiConfig.baseUrl}/api/kash';

  Future<String?> _token() => AuthService().getToken();

  Future<Map<String, dynamic>> getExpenses() async {
    return ApiService.get(
      endpoint: '$_baseUrl/expenses',
      token: await _token(),
    );
  }

  Future<Map<String, dynamic>> addExpense(Map<String, dynamic> data) async {
    return ApiService.post(
      endpoint: '$_baseUrl/add',
      body: data,
      token: await _token(),
    );
  }

  Future<Map<String, dynamic>> getBudget() async {
    return ApiService.get(endpoint: '$_baseUrl/budget', token: await _token());
  }

  Future<Map<String, dynamic>> createBudget({
    required String category,
    required double limit,
    required String currency,
  }) async {
    return ApiService.post(
      endpoint: '$_baseUrl/budget/create',
      body: {'category': category, 'limit': limit, 'currency': currency},
      token: await _token(),
    );
  }

  Future<Map<String, dynamic>> getReminders() async {
    return ApiService.get(
      endpoint: '$_baseUrl/reminders',
      token: await _token(),
    );
  }

  Future<Map<String, dynamic>> createReminder(Map<String, dynamic> body) async {
    return ApiService.post(
      endpoint: '$_baseUrl/reminders',
      body: body,
      token: await _token(),
    );
  }

  Future<Map<String, dynamic>> markReminderPaid(String id) async {
    return ApiService.patch(
      endpoint: '$_baseUrl/reminders/$id/mark-paid',
      body: {},
      token: await _token(),
    );
  }

  Future<Map<String, dynamic>> analyzeReceipt(String imageBase64) async {
    return ApiService.post(
      endpoint: '$_baseUrl/analyze',
      body: {'imageBase64': imageBase64},
      token: await _token(),
    );
  }
}
