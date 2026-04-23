import 'package:equatable/equatable.dart';

class AgentStats extends Equatable {
  final int tasksCompleted;
  final int energyUsed;
  final double uptime;

  const AgentStats({
    required this.tasksCompleted,
    required this.energyUsed,
    required this.uptime,
  });

  @override
  List<Object?> get props => [tasksCompleted, energyUsed, uptime];
}

class Agent extends Equatable {
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
  final AgentStats? stats;
  final DateTime? lastActivity;

  const Agent({
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

  bool get isActive => status == 'active';
  bool get isOnline => readyStatus == 'ready';
  bool get hasLowEnergy => energy < (maxEnergy * 0.1);
  bool get hasEnergy => energy > 0;

  String get statusColor {
    if (!isActive) return 'grey';
    if (!hasEnergy) return 'red';
    if (hasLowEnergy) return 'orange';
    return 'green';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        displayName,
        description,
        avatar,
        energy,
        maxEnergy,
        energyPercentage,
        status,
        readyStatus,
        specialties,
        isReady,
        stats,
        lastActivity,
      ];
}
