import 'package:e_team/domain/models/hera/hera_models.dart';

class HeraMapper {
  static String _str(dynamic value) => value == null ? '' : value.toString();

  static int _int(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static String extractId(dynamic id) {
    if (id == null) return '';
    if (id is String) return id;
    if (id is Map) {
      return id[r'$oid']?.toString() ?? id['_id']?.toString() ?? '';
    }
    return id.toString();
  }

  static HeraEmployee employeeFromJson(Map<String, dynamic> json) {
    return HeraEmployee(
      id: extractId(json['_id'] ?? json['id']),
      name: _str(json['name']),
      email: _str(json['email']),
      role: _str(json['role']),
      department: _str(json['department']),
      status: _str(json['status']).isEmpty ? 'active' : _str(json['status']),
      balances: json['balances'] is Map
          ? Map<String, dynamic>.from(json['balances'])
          : {},
      contract: json['contract'] is Map
          ? Map<String, dynamic>.from(json['contract'])
          : null,
    );
  }

  static HeraAction actionFromJson(Map<String, dynamic> json) {
    return HeraAction(
      id: extractId(json['_id'] ?? json['id']),

      employeeId: extractId(json['employee_id']),

      actionType: _str(json['action_type']),

      employeeName: _str(json['employee_name']).isEmpty
          ? 'Employé'
          : _str(json['employee_name']),

      // ✅ AJOUT ICI
      triggeredBy: _str(json['triggered_by']).isEmpty
          ? 'system'
          : _str(json['triggered_by']),

      createdAt: DateTime.tryParse(_str(json['created_at'])),

      details: json['details'] is Map
          ? Map<String, dynamic>.from(json['details'])
          : {},
    );
  }

  static HeraLeave leaveFromJson(
    Map<String, dynamic> json, {
    String employeeName = '',
    String employeeRole = '',
  }) {
    return HeraLeave(
      id: extractId(json['_id'] ?? json['id']),
      employeeName: employeeName.isNotEmpty
          ? employeeName
          : _str(json['employee_name']),
      employeeRole: employeeRole.isNotEmpty
          ? employeeRole
          : _str(json['employee_role']),
      type: _str(json['type']),
      status: _str(json['status']),
      startDate: DateTime.tryParse(_str(json['start_date'])) ?? DateTime.now(),
      endDate: DateTime.tryParse(_str(json['end_date'])) ?? DateTime.now(),
      days: _int(json['days']),
      reason: _str(json['reason']),
    );
  }

  static HeraCandidate candidateFromJson(Map<String, dynamic> json) {
    return HeraCandidate(
      id: extractId(json['_id'] ?? json['id']),
      name: _str(json['name']).isEmpty ? 'Candidat' : _str(json['name']),
      department: _str(json['department']).isEmpty
          ? 'Design'
          : _str(json['department']),
      scoreIa: _int(json['score_ia']),
    );
  }

  static HeraStats statsFromJson(Map<String, dynamic> json) {
    return HeraStats(
      totalEmployees: _int(json['total_employees']),
      onLeaveToday: _int(json['on_leave_today']),
      monthlyLeaveDays: _int(json['monthly_leave_days']),
    );
  }
}
