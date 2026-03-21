import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService;

  User? _user;
  bool _loading = false;

  UserProvider({AuthService? authService}) : _authService = authService ?? AuthService() {
    _bootstrap();
  }

  User? get user => _user;
  bool get isLoading => _loading;

  List<String> get activeAgents => _user?.activeAgents ?? const <String>[];

  bool isAgentActive(String agentIdOrName) {
    final needle = agentIdOrName.trim().toLowerCase();
    if (needle.isEmpty) return false;
    return activeAgents.any((a) => a.trim().toLowerCase() == needle);
  }

  int get energyBalance => _user?.energyBalance ?? 0;

  Future<void> _bootstrap() async {
    await loadFromStorage();
    await refreshFromApi();
  }

  Future<void> loadFromStorage() async {
    _loading = true;
    notifyListeners();

    try {
      _user = await _authService.getSavedUser();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshFromApi() async {
    _loading = true;
    notifyListeners();

    try {
      final fresh = await _authService.getMe();
      if (fresh != null) {
        _user = fresh;
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> setUser(User? user) async {
    _user = user;
    notifyListeners();

    if (user != null) {
      await _authService.saveUser(user);
    }
  }

  Future<void> clear() async {
    _user = null;
    notifyListeners();
  }
}
