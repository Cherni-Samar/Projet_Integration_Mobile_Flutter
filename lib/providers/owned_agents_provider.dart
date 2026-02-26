import 'package:flutter/material.dart';

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

  bool ownsAgent(String agentName) =>
      _agents.any((a) => a.agentName == agentName);

  /// Add a new agent or STACK energy if already owned
  void addAgent(OwnedAgent agent) {
    final idx = _agents.indexWhere(
      (a) => a.agentName == agent.agentName,
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
      (a) => a.agentName == agentName,
    );
    if (idx >= 0) {
      _agents[idx].customName = newName.trim().isEmpty
          ? _agents[idx].agentName
          : newName.trim();
      notifyListeners();
    }
  }
}
