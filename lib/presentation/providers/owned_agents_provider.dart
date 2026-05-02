import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:e_team/domain/models/owned_agent.dart';
import '/data/services/agent_metadata_service.dart';
import '/data/services/api_config.dart';

export 'package:e_team/domain/models/owned_agent.dart';

class OwnedAgentsProvider extends ChangeNotifier {
  final List<OwnedAgent> _agents = [];

  List<OwnedAgent> get agents => List.unmodifiable(_agents);

  int get count => _agents.length;

  int get totalEnergy =>
      _agents.fold(0, (sum, a) => sum + a.energy);

  String _norm(String v) => v.trim().toLowerCase();

  bool ownsAgent(String agentName) {
    final n = _norm(agentName);
    return _agents.any((a) => _norm(a.agentName) == n);
  }

  /// Synchronously rebuilds the owned-agents list from the backend-provided
  /// [activeAgentNames] list. Uses only [AgentMetadataService] for defaults —
  /// no HTTP calls, safe to call from ProxyProvider.update().
  void syncFromActiveAgents(List<String> activeAgentNames) {
    final desired =
        activeAgentNames.map(_norm).where((e) => e.isNotEmpty).toList();

    // Build index of existing agents so we preserve customName / energy.
    final existingById = <String, OwnedAgent>{
      for (final a in _agents) _norm(a.agentName): a,
    };

    final next = <OwnedAgent>[];

    for (final id in desired) {
      final existing = existingById[id];
      if (existing != null) {
        next.add(existing);
        continue;
      }

      final defaults = _defaultsFor(id);
      next.add(
        OwnedAgent(
          agentName: defaults['displayName'] as String,
          agentIllustration: defaults['illustration'] as String,
          agentColor: defaults['color'] as Color,
          packTitle: 'Active',
          energy: defaults['defaultEnergy'] as int,
          purchasedAt: DateTime.now(),
        ),
      );
    }

    // Only notify if the list actually changed.
    final changed = next.length != _agents.length ||
        !_sameAgentOrder(next, _agents);

    if (!changed) return;

    _agents
      ..clear()
      ..addAll(next);
    notifyListeners();
  }

  /// Fetches live energy values from the backend and updates each owned agent.
  /// Call this explicitly after purchase or on screen focus — never from
  /// ProxyProvider.update().
  Future<void> refreshEnergy() async {
    final energyMap = await _fetchAgentEnergies();

    bool hasChanges = false;
    for (final agent in _agents) {
      final newEnergy = energyMap[_norm(agent.agentName)];
      if (newEnergy != null && agent.energy != newEnergy) {
        agent.energy = newEnergy;
        hasChanges = true;
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  /// Fetches agent energy values from /api/agents.
  /// Returns a map of normalised agent name → energy.
  /// Falls back to [AgentMetadataService] defaults on any error.
  Future<Map<String, int>> _fetchAgentEnergies() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/agents'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final agentsData = jsonData['data']['agents'] as List<dynamic>;
          return {
            for (final a in agentsData)
              (a['name'] as String).toLowerCase(): a['energy'] as int,
          };
        }
      }
    } catch (_) {
      // Network failure — fall through to defaults.
    }

    return {
      'dexo': AgentMetadataService.getDefaultEnergyForAgent('dexo'),
      'echo': AgentMetadataService.getDefaultEnergyForAgent('echo'),
      'hera': AgentMetadataService.getDefaultEnergyForAgent('hera'),
      'kash': AgentMetadataService.getDefaultEnergyForAgent('kash'),
      'timo': AgentMetadataService.getDefaultEnergyForAgent('timo'),
    };
  }

  bool _sameAgentOrder(List<OwnedAgent> a, List<OwnedAgent> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (_norm(a[i].agentName) != _norm(b[i].agentName)) return false;
    }
    return true;
  }

  Map<String, dynamic> _defaultsFor(String agentId) {
    return AgentMetadataService.getAgentDefaults(agentId);
  }

  /// Adds a new agent or stacks energy if already owned.
  void addAgent(OwnedAgent agent) {
    final idx = _agents.indexWhere(
      (a) => _norm(a.agentName) == _norm(agent.agentName),
    );
    if (idx >= 0) {
      _agents[idx].energy += agent.energy;
      _agents[idx].packTitle = agent.packTitle;
    } else {
      _agents.add(agent);
    }
    notifyListeners();
  }

  void addAll(List<OwnedAgent> agents) {
    for (final a in agents) {
      addAgent(a);
    }
  }

  /// Renames an owned agent.
  void renameAgent(String agentName, String newName) {
    final idx = _agents.indexWhere(
      (a) => _norm(a.agentName) == _norm(agentName),
    );
    if (idx >= 0) {
      _agents[idx].customName = newName.trim().isEmpty
          ? _agents[idx].agentName
          : newName.trim();
      notifyListeners();
    }
  }
}
