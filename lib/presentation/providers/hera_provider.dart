/// HeraProvider — state management for the Hera agent dashboard.
///
/// Responsibilities:
///   - Hold all server-fetched data (stats, employees, leaves, candidates, actions)
///   - Hold loading and error states
///   - Expose load / refresh / mutate methods
///   - NO UI code, NO BuildContext, NO Widgets
///
/// Error handling:
///   - A single [AppError? error] replaces the previous per-field error strings.
///   - The last failure encountered during a load cycle is surfaced.
///   - Mutation errors (deleteAction) are returned directly to the caller
///     so the UI can react immediately without polling the provider.
///
/// Consumed by: HeraDashboardPage and its tab widgets.
library;

import 'package:flutter/foundation.dart';

import 'package:e_team/core/errors/app_error.dart';
import 'package:e_team/data/services/hera_service.dart';
import 'package:e_team/domain/models/hera_models.dart';

class HeraProvider extends ChangeNotifier {
  // ─── Data ─────────────────────────────────────────────────────────────────

  HeraStats? _stats;
  List<Map<String, dynamic>> _recentActions = [];
  List<HeraEmployee> _employees = [];
  List<HeraLeave> _allLeaves = [];
  List<HeraCandidate> _candidates = [];

  // ─── Loading flags ────────────────────────────────────────────────────────

  bool _loadingStats = false;
  bool _loadingActions = false;
  bool _loadingEmployees = false;

  // ─── Unified error ────────────────────────────────────────────────────────
  // Holds the last error that occurred during a load cycle.
  // Cleared at the start of every loadDashboardData() call.
  // Mutation errors are NOT stored here — they are returned directly.

  AppError? _error;

  // ─── Public getters ───────────────────────────────────────────────────────

  HeraStats? get stats => _stats;
  List<Map<String, dynamic>> get recentActions =>
      List.unmodifiable(_recentActions);
  List<HeraEmployee> get employees => List.unmodifiable(_employees);
  List<HeraLeave> get allLeaves => List.unmodifiable(_allLeaves);
  List<HeraCandidate> get candidates => List.unmodifiable(_candidates);

  bool get loadingStats => _loadingStats;
  bool get loadingActions => _loadingActions;
  bool get loadingEmployees => _loadingEmployees;

  /// The last load error, or null if everything succeeded.
  AppError? get error => _error;

  /// True when any load is in progress.
  bool get isLoading => _loadingStats || _loadingActions || _loadingEmployees;

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Load all dashboard data in parallel.
  /// Clears any previous error before starting.
  Future<void> loadDashboardData() async {
    _error = null;
    notifyListeners();

    await Future.wait([
      _loadStats(),
      _loadRecentActions(),
      _loadEmployees(),
      _loadCandidates(),
    ]);
  }

  /// Alias for pull-to-refresh — same as [loadDashboardData].
  Future<void> refresh() => loadDashboardData();

  /// Optimistically remove an action from the list, then call the API.
  /// Returns an [AppError] on failure (caller shows it), null on success.
  /// Rolls back the optimistic update on failure.
  Future<AppError?> deleteAction(
    Map<String, dynamic> action,
    int index,
  ) async {
    if (index >= _recentActions.length) return null;

    final id = _extractId(action['_id']);
    final removed = _recentActions[index];

    // Optimistic update
    _recentActions = List.from(_recentActions)..removeAt(index);
    notifyListeners();

    if (id != null) {
      try {
        await HeraService.deleteAction(id);
      } catch (e) {
        // Roll back
        _recentActions = List.from(_recentActions)..insert(index, removed);
        notifyListeners();
        return AppError.mutation("Impossible de supprimer l'action.", source: e);
      }
    }

    return null; // success
  }

  /// Load leaves for a specific employee and merge into [allLeaves].
  Future<void> loadLeavesForEmployee({
    required String employeeId,
    required String employeeName,
    required String employeeRole,
  }) async {
    try {
      final response = await HeraService.getLeavesTyped(
        employeeId: employeeId,
        employeeName: employeeName,
        employeeRole: employeeRole,
      );
      if (response.success) {
        final others = _allLeaves
            .where((l) => l.employeeName != employeeName)
            .toList();
        _allLeaves = [...others, ...response.leaves];
        notifyListeners();
      }
    } catch (_) {
      // Silent — leaves are non-critical, no error surfaced
    }
  }

  /// Clears the current error. Call after the UI has acknowledged it.
  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  // ─── Private loaders ──────────────────────────────────────────────────────

  Future<void> _loadStats() async {
    _loadingStats = true;
    notifyListeners();

    try {
      final response = await HeraService.getAdminStatsTyped();
      _stats = response.stats;
      if (!response.success && response.error != null) {
        _error = AppError.server(response.error);
      }
    } catch (e) {
      _error = AppError.from(e);
    } finally {
      _loadingStats = false;
      notifyListeners();
    }
  }

  Future<void> _loadRecentActions() async {
    _loadingActions = true;
    notifyListeners();

    try {
      final response = await HeraService.getRecentActions(limit: 20);
      _recentActions = List<Map<String, dynamic>>.from(
        response['recent_actions'] ?? [],
      );
    } catch (e) {
      _error = AppError.from(e);
    } finally {
      _loadingActions = false;
      notifyListeners();
    }
  }

  Future<void> _loadEmployees() async {
    _loadingEmployees = true;
    notifyListeners();

    try {
      final response = await HeraService.getAllEmployeesTyped();
      _employees = response.employees;
    } catch (e) {
      _error = AppError.from(e);
    } finally {
      _loadingEmployees = false;
      notifyListeners();
    }

    // Load leaves after employees are available
    await _loadAllLeaves();
  }

  Future<void> _loadCandidates() async {
    try {
      final response = await HeraService.getAllCandidatesTyped();
      _candidates = response.candidates;
      notifyListeners();
    } catch (_) {
      // Silent — candidates are non-critical
    }
  }

  Future<void> _loadAllLeaves() async {
    try {
      final leaves = <HeraLeave>[];
      for (final emp in _employees) {
        final response = await HeraService.getLeavesTyped(
          employeeId: emp.id,
          employeeName: emp.name,
          employeeRole: emp.role,
        );
        if (response.success) {
          leaves.addAll(response.leaves);
        }
      }
      _allLeaves = leaves;
      notifyListeners();
    } catch (_) {
      // Silent
    }
  }

  // ─── Utility ──────────────────────────────────────────────────────────────

  static String? _extractId(dynamic id) {
    if (id == null) return null;
    if (id is String) return id;
    if (id is Map) return id[r'$oid']?.toString() ?? id['_id']?.toString();
    return id.toString();
  }
}
