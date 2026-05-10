import 'package:flutter/foundation.dart';

import 'package:e_team/data/services/timo_service.dart';
import 'package:e_team/presentation/models/timo/timo_task_view_model.dart';

class TimoProvider extends ChangeNotifier {
  bool _loadingTasks = false;
  bool _loadingInbox = false;
  String? _error;

  List<TimoTask> _tasks = [];
  List<Map<String, dynamic>> _inbox = [];

  bool get loadingTasks => _loadingTasks;
  bool get loadingInbox => _loadingInbox;
  bool get isLoading => _loadingTasks || _loadingInbox;
  String? get error => _error;
  List<TimoTask> get tasks => List.unmodifiable(_tasks);
  List<Map<String, dynamic>> get inbox => List.unmodifiable(_inbox);

  Future<void> loadTasks() async {
    _loadingTasks = true;
    _error = null;
    notifyListeners();

    try {
      final response = await TimoService.getTimoTasks();
      _tasks =
          List<Map<String, dynamic>>.from(
            response['tasks'] ?? [],
          ).map(TimoTask.fromMap).toList()..sort((a, b) {
            if (a.deadline == null && b.deadline == null) return 0;
            if (a.deadline == null) return 1;
            if (b.deadline == null) return -1;
            return a.deadline!.compareTo(b.deadline!);
          });
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingTasks = false;
      notifyListeners();
    }
  }

  Future<void> loadInbox() async {
    _loadingInbox = true;
    _error = null;
    notifyListeners();

    try {
      final response = await TimoService.getTimoInbox();
      _inbox = List<Map<String, dynamic>>.from(response['items'] ?? []);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingInbox = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> confirmPlanning({
    required String emailId,
    required String date,
    required String name,
  }) async {
    final response = await TimoService.confirmPlanning(
      emailId: emailId,
      date: date,
      name: name,
    );
    await loadTasks();
    await loadInbox();
    return response;
  }

  Future<void> refresh() async {
    await Future.wait([loadTasks(), loadInbox()]);
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }
}
