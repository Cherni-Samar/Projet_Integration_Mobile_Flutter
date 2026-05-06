/// HeraService — business logic layer for the Hera agent.
///
/// Responsibilities:
///   - Orchestrate calls to HeraRepository
///   - Parse DTOs and return typed responses
///   - Wrap errors into safe fallback values
///   - NO direct HTTP calls
///   - NO BuildContext / UI code
///
/// All public method signatures are IDENTICAL to the previous implementation
/// so every existing caller continues to work without modification.
library;

import 'package:e_team/data/dtos/hera_dto.dart';
import 'package:e_team/data/repositories/hera_repository.dart';

class HeraService {
  // ─── Repository ───────────────────────────────────────────────────────────
  static final _repo = HeraRepository.instance;

  // ═══════════════════════════════════════════════════════════════════════════
  // TYPED RESPONSES  (used by Hera screens)
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<HeraStatsResponse> getAdminStatsTyped() async {
    try {
      final json = await _repo.getAdminStats();
      return HeraStatsResponse.fromJson(json);
    } catch (e) {
      return HeraStatsResponse.error(e.toString());
    }
  }

  static Future<HeraEmployeesResponse> getAllEmployeesTyped() async {
    try {
      final json = await _repo.getEmployees();
      return HeraEmployeesResponse.fromJson(json);
    } catch (e) {
      return HeraEmployeesResponse.error(e.toString());
    }
  }

  static Future<HeraActionsResponse> getRecentActionsTyped({
    int limit = 20,
  }) async {
    try {
      final json = await _repo.getRecentActions(limit: limit);
      return HeraActionsResponse.fromJson(json, key: 'recent_actions');
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
      final json = await _repo.getLeaves(employeeId);
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
      final json = await _repo.getCandidates();
      return HeraCandidatesResponse.fromJson(json);
    } catch (e) {
      return HeraCandidatesResponse.error(e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RAW MAP RESPONSES  (used by various screens)
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> deleteAction(String actionId) async {
    try {
      return await _repo.deleteAction(actionId);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> requestLeave({
    required String employeeId,
    required String employeeEmail,
    required String type,
    required String startDate,
    required String endDate,
    String? reason,
  }) async {
    try {
      return await _repo.requestLeave(
        employeeId: employeeId,
        employeeEmail: employeeEmail,
        type: type,
        startDate: startDate,
        endDate: endDate,
        reason: reason ?? '',
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> urgentLeave({
    required String employeeId,
    required String employeeEmail,
    String? reason,
  }) async {
    try {
      return await _repo.urgentLeave(
        employeeId: employeeId,
        employeeEmail: employeeEmail,
        reason: reason ?? 'Urgence',
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> onboarding({
    required String name,
    required String email,
    required String role,
    String? department,
    String? contractType,
    String? managerEmail,
  }) async {
    try {
      return await _repo.onboarding(
        name: name,
        email: email,
        role: role,
        department: department ?? '',
        contractType: contractType ?? 'CDI',
        managerEmail: managerEmail ?? '',
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> generateHeraDoc({
    required String employeeId,
    required String docType,
  }) async {
    try {
      return await _repo.generateDoc(employeeId: employeeId, docType: docType);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getHistory({
    required String employeeId,
  }) async {
    try {
      return await _repo.getHistory(employeeId);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<bool> requestDexoDoc(String employeeId, String docType) async {
    try {
      final response = await _repo.requestDexoDoc(
        employeeId: employeeId,
        docType: docType,
      );
      return response['success'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getRecentActions({int limit = 20}) async {
    try {
      return await _repo.getRecentActions(limit: limit);
    } catch (e) {
      return {'success': false, 'recent_actions': [], 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getAllActions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return await _repo.getAllActions(page: page, limit: limit);
    } catch (e) {
      return {
        'success': false,
        'actions': [],
        'total_pages': 1,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> getDexoCheckup() async {
    try {
      return await _repo.getDexoCheckup();
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
      return await _repo.sendEmailToEcho(
        subject: subject,
        content: content,
        from: from ?? 'hera@e-team.com',
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> hello({required String username}) async {
    try {
      return await _repo.hello(username);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getOpportunities() async {
    try {
      return await _repo.getOpportunities();
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<bool> approveProject(String projectId) async {
    try {
      final response = await _repo.approveProject(projectId);
      return response['success'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getDocumentActions({
    int limit = 20,
  }) async {
    try {
      return await _repo.getDocumentActions(limit: limit);
    } catch (e) {
      return {'success': false, 'actions': [], 'error': e.toString()};
    }
  }
}
