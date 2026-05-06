/// HeraRepository — data access layer for the Hera agent.
///
/// Responsibilities:
///   - Build full endpoint URLs
///   - Call ApiService (GET / POST / DELETE)
///   - Return raw `Map<String, dynamic>` responses
///   - NO business logic, NO DTO parsing, NO error-wrapping beyond rethrow
///
/// Callers: HeraService only.
library;

import 'package:e_team/core/config/api_config.dart';
import 'package:e_team/data/services/api_service.dart';
import 'package:e_team/data/services/auth_service.dart';

class HeraRepository {
  // ─── Singleton ────────────────────────────────────────────────────────────
  HeraRepository._();
  static final HeraRepository instance = HeraRepository._();

  // ─── Base URL ─────────────────────────────────────────────────────────────
  static String get _base => '${ApiConfig.baseUrl}/api/hera';

  // ─── Token helper ─────────────────────────────────────────────────────────
  Future<String?> _token() => AuthService().getToken();

  // ═══════════════════════════════════════════════════════════════════════════
  // GET
  // ═══════════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> getAdminStats() async {
    final token = await _token();
    return ApiService.get(endpoint: '$_base/admin/stats', token: token);
  }

  Future<Map<String, dynamic>> getEmployees() async {
    final token = await _token();
    return ApiService.get(endpoint: '$_base/admin/employees', token: token);
  }

  Future<Map<String, dynamic>> getCandidates() async {
    final token = await _token();
    return ApiService.get(endpoint: '$_base/candidates', token: token);
  }

  Future<Map<String, dynamic>> getLeaves(String employeeId) async {
    final token = await _token();
    return ApiService.get(endpoint: '$_base/leaves/$employeeId', token: token);
  }

  Future<Map<String, dynamic>> getHistory(String employeeId) async {
    final token = await _token();
    return ApiService.get(endpoint: '$_base/history/$employeeId', token: token);
  }

  Future<Map<String, dynamic>> getRecentActions({int limit = 20}) async {
    final token = await _token();
    return ApiService.get(
      endpoint: '$_base/admin/recent-actions?limit=$limit',
      token: token,
    );
  }

  Future<Map<String, dynamic>> getAllActions({
    int page = 1,
    int limit = 20,
  }) async {
    final token = await _token();
    return ApiService.get(
      endpoint: '$_base/admin/actions?page=$page&limit=$limit',
      token: token,
    );
  }

  Future<Map<String, dynamic>> getDexoCheckup() async {
    final token = await _token();
    return ApiService.get(endpoint: '$_base/admin/dexo-checkup', token: token);
  }

  Future<Map<String, dynamic>> getOpportunities() async {
    final token = await _token();
    return ApiService.get(endpoint: '$_base/admin/opportunities', token: token);
  }

  Future<Map<String, dynamic>> getDocumentActions({int limit = 20}) async {
    final token = await _token();
    return ApiService.get(
      endpoint: '$_base/admin/document-actions?limit=$limit',
      token: token,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POST
  // ═══════════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> requestLeave({
    required String employeeId,
    required String employeeEmail,
    required String type,
    required String startDate,
    required String endDate,
    String reason = '',
  }) async {
    final token = await _token();
    return ApiService.post(
      endpoint: '$_base/leave-request',
      body: {
        'employee_id': employeeId,
        'employee_email': employeeEmail,
        'type': type,
        'start_date': startDate,
        'end_date': endDate,
        'reason': reason,
      },
      token: token,
    );
  }

  Future<Map<String, dynamic>> urgentLeave({
    required String employeeId,
    required String employeeEmail,
    String reason = 'Urgence',
  }) async {
    final token = await _token();
    return ApiService.post(
      endpoint: '$_base/urgent-leave',
      body: {
        'employee_id': employeeId,
        'employee_email': employeeEmail,
        'reason': reason,
      },
      token: token,
    );
  }

  Future<Map<String, dynamic>> onboarding({
    required String name,
    required String email,
    required String role,
    String department = '',
    String contractType = 'CDI',
    String managerEmail = '',
  }) async {
    final token = await _token();
    return ApiService.post(
      endpoint: '$_base/onboarding',
      body: {
        'name': name,
        'email': email,
        'role': role,
        'department': department,
        'contract_type': contractType,
        'manager_email': managerEmail,
      },
      token: token,
    );
  }

  Future<Map<String, dynamic>> generateDoc({
    required String employeeId,
    required String docType,
  }) async {
    final token = await _token();
    return ApiService.post(
      endpoint: '$_base/generate-doc',
      body: {'employee_id': employeeId, 'doc_type': docType},
      token: token,
    );
  }

  Future<Map<String, dynamic>> requestDexoDoc({
    required String employeeId,
    required String docType,
  }) async {
    final token = await _token();
    return ApiService.post(
      endpoint: '$_base/request-doc',
      body: {'employeeId': employeeId, 'docType': docType},
      token: token,
    );
  }

  Future<Map<String, dynamic>> sendEmailToEcho({
    required String subject,
    required String content,
    String from = 'hera@e-team.com',
  }) async {
    final token = await _token();
    return ApiService.post(
      endpoint: '$_base/send-to-echo',
      body: {'subject': subject, 'content': content, 'from': from},
      token: token,
    );
  }

  Future<Map<String, dynamic>> hello(String username) async {
    final token = await _token();
    return ApiService.post(
      endpoint: '$_base/chat',
      body: {'username': username, 'intent': 'hello', 'message': 'hello'},
      token: token,
    );
  }

  Future<Map<String, dynamic>> approveProject(String projectId) async {
    final token = await _token();
    return ApiService.post(
      endpoint: '$_base/admin/approve-project',
      body: {'projectId': projectId},
      token: token,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DELETE
  // ═══════════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> deleteAction(String actionId) async {
    final token = await _token();
    return ApiService.delete(
      endpoint: '$_base/admin/action/$actionId',
      token: token,
    );
  }
}
