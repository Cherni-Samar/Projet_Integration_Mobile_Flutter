import 'package:e_team/domain/models/hera_models.dart';
import 'package:e_team/data/mappers/hera_mapper.dart';

class HeraEmployeesResponse {
  final bool success;
  final List<HeraEmployee> employees;
  final String? error;

  const HeraEmployeesResponse({
    required this.success,
    required this.employees,
    this.error,
  });

  factory HeraEmployeesResponse.fromJson(Map<String, dynamic> json) {
    final items = <HeraEmployee>[];

    if (json['employees'] is List) {
      for (final item in json['employees']) {
        if (item is Map) {
          items.add(
            HeraMapper.employeeFromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return HeraEmployeesResponse(
      success: json['success'] == true,
      employees: items,
      error: json['error']?.toString(),
    );
  }

  factory HeraEmployeesResponse.error(String message) {
    return HeraEmployeesResponse(
      success: false,
      employees: const [],
      error: message,
    );
  }
}

class HeraActionsResponse {
  final bool success;
  final List<HeraAction> actions;
  final int totalPages;
  final String? error;

  const HeraActionsResponse({
    required this.success,
    required this.actions,
    this.totalPages = 1,
    this.error,
  });

  factory HeraActionsResponse.fromJson(
    Map<String, dynamic> json, {
    String key = 'actions',
  }) {
    final items = <HeraAction>[];
    final raw = json[key] ?? json['recent_actions'];

    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          items.add(HeraMapper.actionFromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return HeraActionsResponse(
      success: json['success'] == true,
      actions: items,
      totalPages: json['total_pages'] ?? 1,
      error: json['error']?.toString(),
    );
  }

  factory HeraActionsResponse.error(String message) {
    return HeraActionsResponse(
      success: false,
      actions: const [],
      error: message,
    );
  }
}

class HeraLeavesResponse {
  final bool success;
  final List<HeraLeave> leaves;
  final String? error;

  const HeraLeavesResponse({
    required this.success,
    required this.leaves,
    this.error,
  });

  factory HeraLeavesResponse.fromJson(
    Map<String, dynamic> json, {
    String employeeName = '',
    String employeeRole = '',
  }) {
    final items = <HeraLeave>[];

    if (json['leaves'] is List) {
      for (final item in json['leaves']) {
        if (item is Map) {
          items.add(
            HeraMapper.leaveFromJson(
              Map<String, dynamic>.from(item),
              employeeName: employeeName,
              employeeRole: employeeRole,
            ),
          );
        }
      }
    }

    return HeraLeavesResponse(
      success: json['success'] == true,
      leaves: items,
      error: json['error']?.toString(),
    );
  }

  factory HeraLeavesResponse.error(String message) {
    return HeraLeavesResponse(success: false, leaves: const [], error: message);
  }
}

class HeraCandidatesResponse {
  final bool success;
  final List<HeraCandidate> candidates;
  final String? error;

  const HeraCandidatesResponse({
    required this.success,
    required this.candidates,
    this.error,
  });

  factory HeraCandidatesResponse.fromJson(Map<String, dynamic> json) {
    final items = <HeraCandidate>[];

    if (json['candidates'] is List) {
      for (final item in json['candidates']) {
        if (item is Map) {
          items.add(
            HeraMapper.candidateFromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return HeraCandidatesResponse(
      success: json['success'] == true,
      candidates: items,
      error: json['error']?.toString(),
    );
  }

  factory HeraCandidatesResponse.error(String message) {
    return HeraCandidatesResponse(
      success: false,
      candidates: const [],
      error: message,
    );
  }
}

class HeraStatsResponse {
  final bool success;
  final HeraStats? stats;
  final String? error;

  const HeraStatsResponse({required this.success, this.stats, this.error});

  factory HeraStatsResponse.fromJson(Map<String, dynamic> json) {
    return HeraStatsResponse(
      success: json['success'] == true,
      stats: json['stats'] is Map
          ? HeraMapper.statsFromJson(Map<String, dynamic>.from(json['stats']))
          : null,
      error: json['error']?.toString(),
    );
  }

  factory HeraStatsResponse.error(String message) {
    return HeraStatsResponse(success: false, error: message);
  }
}
