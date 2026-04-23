class AgentStatsDto {
  final int tasksCompleted;
  final int energyUsed;
  final double uptime;

  const AgentStatsDto({
    required this.tasksCompleted,
    required this.energyUsed,
    required this.uptime,
  });

  factory AgentStatsDto.fromJson(Map<String, dynamic> json) => AgentStatsDto(
        tasksCompleted: (json['tasksCompleted'] as num?)?.toInt() ?? 0,
        energyUsed: (json['energyUsed'] as num?)?.toInt() ?? 0,
        uptime: (json['uptime'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'tasksCompleted': tasksCompleted,
        'energyUsed': energyUsed,
        'uptime': uptime,
      };
}

class AgentDto {
  final String id;
  final String name;
  final String displayName;
  final String description;
  final String? avatar;
  final int energy;
  final int maxEnergy;
  final int energyPercentage;
  final String status;
  final String readyStatus;
  final List<String> specialties;
  final bool isReady;
  final AgentStatsDto? stats;
  final String? lastActivity;

  const AgentDto({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    this.avatar,
    required this.energy,
    required this.maxEnergy,
    required this.energyPercentage,
    required this.status,
    required this.readyStatus,
    required this.specialties,
    required this.isReady,
    this.stats,
    this.lastActivity,
  });

  factory AgentDto.fromJson(Map<String, dynamic> json) => AgentDto(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        displayName: (json['displayName'] ?? '').toString(),
        description: (json['description'] ?? '').toString(),
        avatar: json['avatar']?.toString(),
        energy: (json['energy'] as num?)?.toInt() ?? 0,
        maxEnergy: (json['maxEnergy'] as num?)?.toInt() ?? 200,
        energyPercentage: (json['energyPercentage'] as num?)?.toInt() ?? 0,
        status: (json['status'] ?? 'inactive').toString(),
        readyStatus: (json['readyStatus'] ?? 'offline').toString(),
        specialties: (json['specialties'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        isReady: json['isReady'] == true,
        stats: json['stats'] != null
            ? AgentStatsDto.fromJson(json['stats'] as Map<String, dynamic>)
            : null,
        lastActivity: json['lastActivity']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'displayName': displayName,
        'description': description,
        'avatar': avatar,
        'energy': energy,
        'maxEnergy': maxEnergy,
        'energyPercentage': energyPercentage,
        'status': status,
        'readyStatus': readyStatus,
        'specialties': specialties,
        'isReady': isReady,
        'stats': stats?.toJson(),
        'lastActivity': lastActivity,
      };
}
