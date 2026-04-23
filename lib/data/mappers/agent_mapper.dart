import '../dtos/agent_dto.dart';
import '../models/agent.dart';

class AgentMapper {
  const AgentMapper._();

  static AgentStats? _statsFromDto(AgentStatsDto? dto) {
    if (dto == null) return null;
    return AgentStats(
      tasksCompleted: dto.tasksCompleted,
      energyUsed: dto.energyUsed,
      uptime: dto.uptime,
    );
  }

  static AgentStatsDto? _statsToDto(AgentStats? stats) {
    if (stats == null) return null;
    return AgentStatsDto(
      tasksCompleted: stats.tasksCompleted,
      energyUsed: stats.energyUsed,
      uptime: stats.uptime,
    );
  }

  static Agent fromDto(AgentDto dto) => Agent(
        id: dto.id,
        name: dto.name,
        displayName: dto.displayName,
        description: dto.description,
        avatar: dto.avatar,
        energy: dto.energy,
        maxEnergy: dto.maxEnergy,
        energyPercentage: dto.energyPercentage,
        status: dto.status,
        readyStatus: dto.readyStatus,
        specialties: dto.specialties,
        isReady: dto.isReady,
        stats: _statsFromDto(dto.stats),
        lastActivity: dto.lastActivity != null
            ? DateTime.tryParse(dto.lastActivity!)
            : null,
      );

  static AgentDto toDto(Agent model) => AgentDto(
        id: model.id,
        name: model.name,
        displayName: model.displayName,
        description: model.description,
        avatar: model.avatar,
        energy: model.energy,
        maxEnergy: model.maxEnergy,
        energyPercentage: model.energyPercentage,
        status: model.status,
        readyStatus: model.readyStatus,
        specialties: model.specialties,
        isReady: model.isReady,
        stats: _statsToDto(model.stats),
        lastActivity: model.lastActivity?.toIso8601String(),
      );

  /// Convenience: parse a raw API JSON map directly to a domain [Agent].
  static Agent fromJson(Map<String, dynamic> json) =>
      fromDto(AgentDto.fromJson(json));
}
