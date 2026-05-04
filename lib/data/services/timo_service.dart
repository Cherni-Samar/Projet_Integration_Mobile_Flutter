import 'package:e_team/core/config/api_config.dart';
import 'api_service.dart';

class TimoService {
  static String get baseUrl => '${ApiConfig.baseUrl}/api/hera';

  /// Fetch Timo's inbox of pending scheduling items.
  static Future<Map<String, dynamic>> getTimoInbox() async {
    try {
      return await ApiService.get(endpoint: '$baseUrl/admin/timo-inbox');
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Confirm a planning item with a selected date.
  static Future<Map<String, dynamic>> confirmPlanning({
    required String emailId,
    required String date,
    required String name,
  }) async {
    try {
      return await ApiService.post(
        endpoint: '$baseUrl/admin/timo-confirm',
        body: {
          'emailId': emailId,
          'selectedDate': date,
          'employeeName': name,
        },
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Fetch Timo's task list.
  static Future<Map<String, dynamic>> getTimoTasks() async {
    try {
      return await ApiService.get(endpoint: '$baseUrl/admin/timo-tasks');
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
