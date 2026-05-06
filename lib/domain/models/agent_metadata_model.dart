class AgentStats {
  final String response;
  final String accuracy;
  final String languages;

  const AgentStats({
    required this.response,
    required this.accuracy,
    required this.languages,
  });

  Map<String, dynamic> toMap() {
    return {'response': response, 'accuracy': accuracy, 'languages': languages};
  }
}

class AgentEnergyTask {
  final String task;
  final int cost;

  const AgentEnergyTask({required this.task, required this.cost});

  Map<String, dynamic> toMap() {
    return {'task': task, 'cost': cost};
  }
}

class AgentMultiScenario {
  final String scenario;
  final String agents;
  final int cost;

  const AgentMultiScenario({
    required this.scenario,
    required this.agents,
    required this.cost,
  });

  Map<String, dynamic> toMap() {
    return {'scenario': scenario, 'agents': agents, 'cost': cost};
  }
}

class AgentEnergyPack {
  final String title;
  final int energy;
  final double price;
  final int color;

  const AgentEnergyPack({
    required this.title,
    required this.energy,
    required this.price,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {'title': title, 'energy': energy, 'price': price, 'color': color};
  }
}

class AgentMetadata {
  final String id;
  final String name;
  final String roleKey; // Localization key for role
  final String descriptionKey; // Localization key for description
  final String iconPath;
  final int colorValue;
  final AgentStats stats;
  final double rating;
  final String hires;
  final String priceLabel;
  final String versionKey; // Localization key for version
  final List<String> skillKeys; // Localization keys for skills
  final List<AgentEnergyTask> energyTasks;
  final List<AgentMultiScenario> multiScenarios;
  final List<AgentEnergyPack> energyPacks;
  final int defaultEnergy;
  final int minEnergy; // Minimum energy per task (backend reality)
  final int maxEnergy; // Maximum energy per task (backend reality)

  const AgentMetadata({
    required this.id,
    required this.name,
    required this.roleKey,
    required this.descriptionKey,
    required this.iconPath,
    required this.colorValue,
    required this.stats,
    required this.rating,
    required this.hires,
    required this.priceLabel,
    required this.versionKey,
    required this.skillKeys,
    required this.energyTasks,
    required this.multiScenarios,
    required this.energyPacks,
    this.defaultEnergy = 170,
    this.minEnergy = 1, // Backend reality: 1-5 energy per task
    this.maxEnergy = 5, // Backend reality: 1-5 energy per task
  });

  /// Convert to Map for backward compatibility with existing UI
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': iconPath,
      'color': colorValue,
      'stats': stats.toMap(),
      'rating': rating,
      'hires': hires,
      'price': priceLabel,
    };
  }

  /// Convert to Map with localized strings
  Map<String, dynamic> toLocalizedMap({
    required String role,
    required String description,
  }) {
    return {
      'name': name,
      'role': role,
      'description': description,
      'icon': iconPath,
      'color': colorValue,
      'stats': stats.toMap(),
      'rating': rating,
      'hires': hires,
      'price': priceLabel,
    };
  }

  /// Get realistic energy range display based on backend logic
  String getEnergyRangeDisplay() {
    return '$minEnergy–$maxEnergy ⚡ per task';
  }
}
