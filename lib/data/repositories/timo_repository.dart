import 'package:e_team/core/config/api_config.dart';
import 'package:e_team/data/services/api_service.dart';

class TimoRepository {
  TimoRepository._();
  static final TimoRepository instance = TimoRepository._();

  static String get _baseUrl => '${ApiConfig.baseUrl}/api/hera';

  Future<Map<String, dynamic>> getTimoInbox() {
    return ApiService.get(endpoint: '$_baseUrl/admin/timo-inbox');
  }

  Future<Map<String, dynamic>> confirmPlanning({
    required String emailId,
    required String date,
    required String name,
  }) {
    return ApiService.post(
      endpoint: '$_baseUrl/admin/timo-confirm',
      body: {'emailId': emailId, 'selectedDate': date, 'employeeName': name},
    );
  }

  Future<Map<String, dynamic>> getTimoTasks() {
    return ApiService.get(endpoint: '$_baseUrl/admin/timo-tasks');
  }
}
