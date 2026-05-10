import 'package:flutter/foundation.dart';

import 'package:e_team/data/services/echo_service.dart';
import 'package:e_team/domain/models/echo/echo_models.dart';

class EchoProvider extends ChangeNotifier {
  bool _loadingInbox = false;
  bool _loadingPosts = false;
  bool _loadingStats = false;
  String? _error;

  List<EmailItem> _emails = [];
  List<PendingItem> _pending = [];
  List<PostItem> _posts = [];
  int _totalEmails = 0;
  int _urgentCount = 0;
  int _spamCount = 0;
  int _unreadCount = 0;
  int _totalProcessed = 0;
  int _spamBlocked = 0;
  double _uptime = 0;

  bool get loadingInbox => _loadingInbox;
  bool get loadingPosts => _loadingPosts;
  bool get loadingStats => _loadingStats;
  bool get isLoading => _loadingInbox || _loadingPosts || _loadingStats;
  String? get error => _error;

  List<EmailItem> get emails => List.unmodifiable(_emails);
  List<PendingItem> get pending => List.unmodifiable(_pending);
  List<PostItem> get posts => List.unmodifiable(_posts);
  int get totalEmails => _totalEmails;
  int get urgentCount => _urgentCount;
  int get spamCount => _spamCount;
  int get unreadCount => _unreadCount;
  int get totalProcessed => _totalProcessed;
  int get spamBlocked => _spamBlocked;
  double get uptime => _uptime;

  Future<void> loadInbox({String? token}) async {
    _loadingInbox = true;
    _error = null;
    notifyListeners();

    try {
      final emailsResponse = await EchoService.getEmails(token: token);
      final pendingResponse = await EchoService.getPending(token: token);

      _emails = emailsResponse.emails;
      _pending = pendingResponse.pending;
      _totalEmails = emailsResponse.total;
      _urgentCount = emailsResponse.urgentCount;
      _spamCount = emailsResponse.spamCount;
      _unreadCount = emailsResponse.unreadCount;

      if (!emailsResponse.success && emailsResponse.error != null) {
        _error = emailsResponse.error;
      } else if (!pendingResponse.success && pendingResponse.error != null) {
        _error = pendingResponse.error;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingInbox = false;
      notifyListeners();
    }
  }

  Future<void> loadPosts({String? token}) async {
    _loadingPosts = true;
    _error = null;
    notifyListeners();

    try {
      final response = await EchoService.getMobilePosts(token: token);
      _posts = response.posts;
      if (!response.success && response.error != null) {
        _error = response.error;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingPosts = false;
      notifyListeners();
    }
  }

  Future<void> loadStats({String? token}) async {
    _loadingStats = true;
    _error = null;
    notifyListeners();

    try {
      final response = await EchoService.getStats(token: token);
      _totalProcessed = response.totalProcessed;
      _spamBlocked = response.spamBlocked;
      _uptime = response.uptime;
      if (!response.success && response.error != null) {
        _error = response.error;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingStats = false;
      notifyListeners();
    }
  }

  Future<void> refresh({String? token}) async {
    await Future.wait([
      loadInbox(token: token),
      loadPosts(token: token),
      loadStats(token: token),
    ]);
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }
}
