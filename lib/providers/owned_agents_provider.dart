import 'package:flutter/material.dart';
import '../models/owned_agent_model.dart';
export '../models/owned_agent_model.dart';


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
  void syncFromActiveAgents(List<String> activeAgents) {
    final desired = activeAgents.map(_norm).where((e) => e.isNotEmpty).toList();

    // Build index of existing agents by normalized name.
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
          agentName: defaults.displayName,
          agentIllustration: defaults.illustration,
          agentColor: defaults.color,
          packTitle: 'Active',
          energy: 0,
          purchasedAt: DateTime.now(),
        ),
      );
    }

    final changed = next.length != _agents.length ||
        !_sameAgentOrder(next, _agents);
    if (!changed) return;

    _agents
      ..clear()
      ..addAll(next);
    notifyListeners();
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
