import 'package:flutter/foundation.dart';

import 'package:e_team/domain/models/hera_models.dart';

@immutable
class HeraFluxData {
  final List<Map<String, dynamic>> recentActions;
  final bool loadingStats;
  final bool loadingActions;
  final HeraStats? stats;

  const HeraFluxData({
    required this.recentActions,
    required this.loadingStats,
    required this.loadingActions,
    required this.stats,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeraFluxData &&
          recentActions == other.recentActions &&
          loadingStats == other.loadingStats &&
          loadingActions == other.loadingActions &&
          stats == other.stats;

  @override
  int get hashCode =>
      Object.hash(recentActions, loadingStats, loadingActions, stats);
}

@immutable
class HeraTeamData {
  final List<HeraEmployee> employees;
  final List<HeraCandidate> candidates;
  final bool loadingEmployees;

  const HeraTeamData({
    required this.employees,
    required this.candidates,
    required this.loadingEmployees,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeraTeamData &&
          employees == other.employees &&
          candidates == other.candidates &&
          loadingEmployees == other.loadingEmployees;

  @override
  int get hashCode => Object.hash(employees, candidates, loadingEmployees);
}
