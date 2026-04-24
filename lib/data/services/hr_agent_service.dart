import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:e_team/data/services/api_config.dart';
import 'package:e_team/data/services/api_service.dart';
import 'package:e_team/data/dtos/hera_dto.dart';

class HrAgentService {
  static String get baseUrl => '${ApiConfig.baseUrl}/api/hera';

  static Future<Map<String, dynamic>> _getRaw(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> _postRaw(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> _deleteRaw(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  static Future<HeraStatsResponse> getAdminStatsTyped() async {
    try {
      final json = await _getRaw('/admin/stats');
      return HeraStatsResponse.fromJson(json);
    } catch (e) {
      return HeraStatsResponse.error(e.toString());
    }
  }

  static Future<HeraEmployeesResponse> getAllEmployeesTyped() async {
    try {
      final json = await _getRaw('/admin/employees');
      return HeraEmployeesResponse.fromJson(json);
    } catch (e) {
      return HeraEmployeesResponse.error(e.toString());
    }
  }

  static Future<HeraActionsResponse> getRecentActionsTyped({
    int limit = 20,
  }) async {
    try {
      final json = await _getRaw('/admin/recent-actions?limit=$limit');
      return HeraActionsResponse.fromJson(json, key: 'recent_actions');
    } catch (e) {
      return HeraActionsResponse.error(e.toString());
    }
  }

  static Future<HeraActionsResponse> getAllActionsTyped({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final json = await _getRaw('/admin/all-actions?page=$page&limit=$limit');
      return HeraActionsResponse.fromJson(json, key: 'actions');
    } catch (e) {
      return HeraActionsResponse.error(e.toString());
    }
  }

  static Future<HeraLeavesResponse> getLeavesTyped({
    required String employeeId,
    String employeeName = '',
    String employeeRole = '',
  }) async {
    try {
      final json = await _getRaw('/leaves/$employeeId');
      return HeraLeavesResponse.fromJson(
        json,
        employeeName: employeeName,
        employeeRole: employeeRole,
      );
    } catch (e) {
      return HeraLeavesResponse.error(e.toString());
    }
  }

  static Future<HeraCandidatesResponse> getAllCandidatesTyped() async {
    try {
      final json = await _getRaw('/candidates');
      return HeraCandidatesResponse.fromJson(json);
    } catch (e) {
      return HeraCandidatesResponse.error(e.toString());
    }
  }

  static Future<Map<String, dynamic>> deleteAction(String actionId) {
    return _deleteRaw('/admin/action/$actionId');
  }

  static Future<Map<String, dynamic>> requestLeave({
    required String employeeId,
    required String employeeEmail,
    required String type,
    required String startDate,
    required String endDate,
    String? reason,
  }) {
    return _postRaw('/leave-request', {
      'employee_id': employeeId,
      'employee_email': employeeEmail,
      'type': type,
      'start_date': startDate,
      'end_date': endDate,
      'reason': reason ?? '',
    });
  }

  static Future<Map<String, dynamic>> urgentLeave({
    required String employeeId,
    required String employeeEmail,
    String? reason,
  }) {
    return _postRaw('/leave-urgent', {
      'employee_id': employeeId,
      'employee_email': employeeEmail,
      'reason': reason ?? 'Urgence',
    });
  }

  static Future<Map<String, dynamic>> onboarding({
    required String name,
    required String email,
    required String role,
    String? department,
    String? contractType,
    String? managerEmail,
  }) {
    return _postRaw('/onboarding', {
      'name': name,
      'email': email,
      'role': role,
      'department': department ?? '',
      'contract_type': contractType ?? 'CDI',
      'manager_email': managerEmail ?? '',
    });
  }

  static Future<Map<String, dynamic>> generateHeraDoc({
    required String employeeId,
    required String docType,
  }) {
    return _postRaw('/generate-doc', {
      'employee_id': employeeId,
      'doc_type': docType,
    });
  }

  static Future<Map<String, dynamic>> getHistory({
    required String employeeId,
  }) {
    return _getRaw('/history/$employeeId');
  }

  static Future<bool> requestDexoDoc(String employeeId, String docType) async {
    try {
      final response = await ApiService.post(
        endpoint: 'http://10.0.2.2:3000/api/dexo/request-doc',
        body: {
          'employeeId': employeeId,
          'docType': docType,
        },
      );
      return response['success'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getRecentActions({int limit = 20}) async {
    try {
      return await _getRaw('/admin/recent-actions?limit=$limit');
    } catch (e) {
      return {
        'success': false,
        'recent_actions': [],
        'error': e.toString(),
      };
    }
  }
  static Future<Map<String, dynamic>> getAllActions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _getRaw(
        '/admin/actions?page=$page&limit=$limit',
      );

      return response;
    } catch (e) {
      print('❌ getAllActions error: $e');
      return {
        'success': false,
        'actions': [],
        'total_pages': 1,
      };
    }
  }
  static Future<Map<String, dynamic>> getDexoCheckup() async {
    try {
      return await _getRaw('/admin/dexo-checkup');
    } catch (e) {
      return {
        'success': false,
        'report': 'Impossible de charger la synthèse Dexo.',
        'error': e.toString(),
      };
    }
  }
  static Future<Map<String, dynamic>> sendEmailToEcho({
    required String subject,
    required String content,
    String? from,
  }) async {
    try {
      final response = await _postRaw(
        '/hera/send-to-echo', // ⚠️ adapte si besoin
        {
          'subject': subject,
          'content': content,
          'from': from ?? 'hera@e-team.com',
        },
      );

      return response;
    } catch (e) {
      print('❌ sendEmailToEcho error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  static Future<Map<String, dynamic>> hello({
    required String username,
  }) async {
    try {
      return await _postRaw('/chat', {
        'username': username,
        'intent': 'hello',
        'message': 'hello',
      });
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  static Future<Map<String, dynamic>> getDocumentActions({int limit = 20}) async {
    try {
      return await _getRaw('/admin/document-actions?limit=$limit');
    } catch (e) {
      return {
        'success': false,
        'actions': [],
        'error': e.toString(),
      };
    }
  }
}