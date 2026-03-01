import 'dart:convert';
import 'package:http/http.dart' as http;

class HrAgentService {
  // ✅ Pointe vers EXPRESS (pas N8N)
  static const String _base = 'http://10.0.2.2:3000/api/hera';

  static Future<Map<String, dynamic>> hello({String username = 'user'}) =>
      _post('hello', {'username': username});

  static Future<Map<String, dynamic>> requestLeave({
    required String employeeId,
    required String employeeEmail,
    required String type,
    required String startDate,
    required String endDate,
    required int days,
    required String reason,
  }) async {
    final response = await http.post(
      Uri.parse('$_base/leave-request'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'employee_id': employeeId,
        'employee_email': employeeEmail,
        'type': type,
        'start_date': startDate,
        'end_date': endDate,
        'days': days,
        'reason': reason,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> urgentLeave({
    required String employeeId,
    required String reason,
  }) => _post('leave-urgent', {'employee_id': employeeId, 'reason': reason});

  static Future<Map<String, dynamic>> onboarding({
    required String name,
    required String email,
    required String role,
    required String department,
    required String contractType,
    required String managerEmail,
  }) => _post('onboarding', {
    'name': name,
    'email': email,
    'role': role,
    'department': department,
    'contract_type': contractType,
    'manager_email': managerEmail,
  });

  static Future<Map<String, dynamic>> promote({
    required String employeeId,
    required String newRole,
    required double newSalary,
  }) => _post('promote', {
    'employee_id': employeeId,
    'new_role': newRole,
    'new_salary': newSalary,
  });

  static Future<Map<String, dynamic>> offboarding({
    required String employeeId,
    required String reason,
    required String lastDay,
  }) => _post('offboarding', {
    'employee_id': employeeId,
    'reason': reason,
    'last_day': lastDay,
  });

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_base/$path'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Erreur ${response.statusCode}');
    } catch (e) {
      throw Exception('Serveur indisponible: $e');
    }
  }
}
