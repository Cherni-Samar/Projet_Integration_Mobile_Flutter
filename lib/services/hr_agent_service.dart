import 'dart:convert';
import 'package:http/http.dart' as http;

class HrAgentService {
  // ══════════════════════════════════════════════════════════════════════════
  // Configuration
  // ══════════════════════════════════════════════════════════════════════════

  static const String baseUrl = 'http://10.0.2.2:3000/api/hera';
  // ══════════════════════════════════════════════════════════════════════════
  // Hello
  // ══════════════════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> hello({required String username}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/hello'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Failed to connect',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Leave Request
  // ══════════════════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> requestLeave({
    required String employeeId,
    required String employeeEmail,
    required String type,
    required String startDate,
    required String endDate,
    String? reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/leave-request'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'employee_id': employeeId,
          'employee_email': employeeEmail,
          'type': type,
          'start_date': startDate,
          'end_date': endDate,
          'reason': reason ?? '',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Failed to request leave',
          'status_code': response.statusCode,
          'body': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Urgent Leave
  // ══════════════════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> urgentLeave({
    required String employeeId,
    required String employeeEmail,
    String? reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/leave-urgent'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'employee_id': employeeId,
          'employee_email': employeeEmail,
          'reason': reason ?? 'Urgence',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Failed to request urgent leave',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Get Leaves
  // ══════════════════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> getLeaves({required String employeeId}) async {
    try {
      print('📡 GET $baseUrl/leaves/$employeeId');

      final response = await http.get(
        Uri.parse('$baseUrl/leaves/$employeeId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📥 Status: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Failed to load leaves',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Erreur getLeaves: $e');
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Onboarding
  // ══════════════════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> onboarding({
    required String name,
    required String email,
    required String role,
    String? department,
    String? contractType,
    String? managerEmail,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/onboarding'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'role': role,
          'department': department ?? '',
          'contract_type': contractType ?? 'CDI',
          'manager_email': managerEmail ?? '',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Failed to onboard employee',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ADMIN - Get Stats
  // ══════════════════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Failed to load stats',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ADMIN - Get Pending Leaves
  // ══════════════════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> getPendingLeaves() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/pending-leaves'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Failed to load pending leaves',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ADMIN - Get All Employees
  // ══════════════════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> getAllEmployees() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/employees'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Failed to load employees',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ADMIN - Approve or Reject Leave
  // ════════════════════════════════════════════════════════════════���═════════

  static Future<Map<String, dynamic>> approveOrRejectLeave({
    required String leaveId,
    required String action,
    String? adminName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/approve-reject'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'leave_id': leaveId,
          'action': action,
          'admin_name': adminName ?? 'Admin',
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Failed to process leave',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ADMIN - Get Recent Actions
  // ══════════════════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> getRecentActions({int limit = 5}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/recent-actions?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Failed to load recent actions',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }
}