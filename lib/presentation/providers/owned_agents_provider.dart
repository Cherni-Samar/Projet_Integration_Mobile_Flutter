import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OwnedAgent {
  final String agentName;
  String customName;             // user-given nickname
  final String agentIllustration;
  final Color agentColor;
  String packTitle;               // latest pack purchased
  int energy;                     // cumulative energy
  final DateTime purchasedAt;

  OwnedAgent({
    required this.agentName,
    String? customName,
    required this.agentIllustration,
    required this.agentColor,
    required this.packTitle,
    required this.energy,
    required this.purchasedAt,
  }) : customName = customName ?? agentName;

  /// Display name: custom name if set, otherwise agent name
  String get displayName => customName;
}

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

  /// Single source of truth: sync owned agents from Mongo-backed `activeAgents`.
  /// This keeps UI like "My Agents" consistent with the backend state.
  void syncFromActiveAgents(List<String> activeAgents) async {
    final desired = activeAgents.map(_norm).where((e) => e.isNotEmpty).toList();

    // Build index of existing agents by normalized name.
    final existingById = <String, OwnedAgent>{
      for (final a in _agents) _norm(a.agentName): a,
    };

    final next = <OwnedAgent>[];
    
    // Fetch energy data from backend API
    final agentEnergyMap = await _fetchAgentEnergies();
    
    for (final id in desired) {
      final existing = existingById[id];
      if (existing != null) {
        // Update existing agent with fresh energy data
        final newEnergy = agentEnergyMap[id] ?? existing.energy;
        // Only update if energy changed to trigger UI refresh
        if (existing.energy != newEnergy) {
          existing.energy = newEnergy;
          print('🔄 [ENERGY] ${existing.agentName} energy updated: ${existing.energy}');
        }
        next.add(existing);
        continue;
      }

      final defaults = _defaultsFor(id);
      next.add(
        OwnedAgent(
          agentName: defaults.displayName,
          agentIllustration: defaults.illustration,
          agentColor: defaults.color,
          packTitle: 'Active',
          energy: agentEnergyMap[id] ?? 170, // Use API energy or default to 170
          purchasedAt: DateTime.now(),
        ),
      );
    }

    final changed = next.length != _agents.length ||
        !_sameAgentOrder(next, _agents) ||
        _energyChanged(next, _agents);
    
    if (!changed) return;

    _agents
      ..clear()
      ..addAll(next);
    notifyListeners();
  }
  
  /// Check if energy values have changed
  bool _energyChanged(List<OwnedAgent> a, List<OwnedAgent> b) {
    if (a.length != b.length) return true;
    for (var i = 0; i < a.length; i++) {
      if (a[i].energy != b[i].energy) return true;
    }
    return false;
  }
  
  /// Fetch agent energies from the backend API
  Future<Map<String, int>> _fetchAgentEnergies() async {
    try {
      // Import http at the top of the file
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/agents'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final agentsData = jsonData['data']['agents'] as List;
          final energyMap = <String, int>{};
          
          for (final agentJson in agentsData) {
            final name = (agentJson['name'] as String).toLowerCase();
            final energy = agentJson['energy'] as int;
            energyMap[name] = energy;
          }
          
          print('🔍 Fetched agent energies: $energyMap');
          return energyMap;
        }
      }
    } catch (e) {
      print('❌ Error fetching agent energies: $e');
    }
    
    // Return default energies if API fails
    return {
      'dexo': 170,
      'echo': 170,
      'hera': 170,
      'kash': 170,
      'timo': 170,
    };
  }

  bool _sameAgentOrder(List<OwnedAgent> a, List<OwnedAgent> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (_norm(a[i].agentName) != _norm(b[i].agentName)) return false;
    }
    return true;
  }

  _AgentDefaults _defaultsFor(String agentId) {
    switch (_norm(agentId)) {
      case 'hera':
        return const _AgentDefaults(
          displayName: 'Hera',
          illustration: 'assets/images/hera.png',
          color: Color(0xFF8B5CF6),
        );
      case 'kash':
        return const _AgentDefaults(
          displayName: 'Kash',
          illustration: 'assets/images/kash.png',
          color: Color(0xFFF59E0B),
        );
      case 'dexo':
        return const _AgentDefaults(
          displayName: 'Dexo',
          illustration: 'assets/images/dexo.png',
          color: Color(0xFF10B981),
        );
      case 'timo':
        return const _AgentDefaults(
          displayName: 'Timo',
          illustration: 'assets/images/krono.png',
          color: Color(0xFFEC4899),
        );
      case 'echo':
        return const _AgentDefaults(
          displayName: 'Echo',
          illustration: 'assets/images/voxi.png',
          color: Color(0xFFA855F7),
        );
      default:
        return _AgentDefaults(
          displayName: agentId.isEmpty
              ? 'Agent'
              : '${agentId[0].toUpperCase()}${agentId.substring(1)}',
          illustration: 'assets/images/hera.png',
          color: const Color(0xFF8B5CF6),
        );
    }
  }

  /// Add a new agent or STACK energy if already owned
  void addAgent(OwnedAgent agent) {
    final idx = _agents.indexWhere(
      (a) => _norm(a.agentName) == _norm(agent.agentName),
    );
    if (idx >= 0) {
      // Agent already owned → stack energy + upgrade pack label
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

  /// Rename an owned agent
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
  
  /// Manually refresh energy from backend API
  Future<void> refreshEnergy() async {
    print('🔄 [ENERGY] Manually refreshing agent energies...');
    final agentEnergyMap = await _fetchAgentEnergies();
    
    bool hasChanges = false;
    for (final agent in _agents) {
      final normalizedName = _norm(agent.agentName);
      final newEnergy = agentEnergyMap[normalizedName];
      if (newEnergy != null && agent.energy != newEnergy) {
        agent.energy = newEnergy;
        hasChanges = true;
        print('🔄 [ENERGY] ${agent.agentName} energy updated: ${agent.energy}');
      }
    }
    
    if (hasChanges) {
      notifyListeners();
      print('✅ [ENERGY] Energy refresh complete');
    } else {
      print('ℹ️ [ENERGY] No energy changes detected');
    }
  }
}

class _AgentDefaults {
  final String displayName;
  final String illustration;
  final Color color;

  const _AgentDefaults({
    required this.displayName,
    required this.illustration,
    required this.color,
  });
}
