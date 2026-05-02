import 'package:flutter/foundation.dart';

import 'package:e_team/domain/models/user_model.dart';
import 'package:e_team/data/services/auth_service.dart';
import 'package:e_team/data/mappers/user_mapper.dart';
import 'package:e_team/data/dtos/user_dto.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _loading = false;

  User? get user => _user;
  bool get isLoading => _loading;

  int get energyBalance => _user?.energyBalance ?? 0;

  String get subscriptionPlanLabel {
    final raw = (_user?.subscriptionPlan ?? '').trim().toLowerCase();
    if (raw == 'premium') return 'Premium Plan';
    if (raw == 'basic') return 'Basic Plan';
    return 'Free Trial';
  }

  UserProvider() {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final savedDto = await _authService.getSavedUser();

    if (savedDto != null) {
      _user = UserMapper.fromDTO(savedDto);
      notifyListeners();
    }

    await refreshFromApi();
  }
  List<String> get activeAgents {
    return _user?.activeAgents ?? [];
  }

  Future<void> refreshFromApi() async {
    _loading = true;
    notifyListeners();

    try {
      final dto = await _authService.getMe();

      if (dto != null) {
        _user = UserMapper.fromDTO(dto);
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> setUser(UserDTO dto) async {
    _user = UserMapper.fromDTO(dto);
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  bool isAgentActive(String agentId) {
    return _user?.activeAgents.contains(agentId) ?? false;
  }
}