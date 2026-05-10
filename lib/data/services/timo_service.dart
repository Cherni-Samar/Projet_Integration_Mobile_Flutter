import 'package:e_team/data/repositories/timo_repository.dart';

class TimoService {
  static final _repo = TimoRepository.instance;

  /// Fetch Timo's inbox of pending scheduling items.
  static Future<Map<String, dynamic>> getTimoInbox() async {
    try {
      return await _repo.getTimoInbox();
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Confirm a planning item with a selected date.
  static Future<Map<String, dynamic>> confirmPlanning({
    required String emailId,
    required String date,
    required String name,
  }) async {
    try {
      return await _repo.confirmPlanning(
        emailId: emailId,
        date: date,
        name: name,
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Fetch Timo's task list.
  static Future<Map<String, dynamic>> getTimoTasks() async {
    try {
      return await _repo.getTimoTasks();
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
