import 'api_service.dart';
import 'package:e_team/core/config/api_config.dart';

class AgentService {
  static String get _baseUrl => ApiConfig.baseUrl;

  // ═══════════════════════════════════════════════════════════════
  // 🤖 AGENT MANAGEMENT METHODS
  // ═══════════════════════════════════════════════════════════════

  static Future<AgentsResponse> getAllAgents({String? token}) async {
    try {
      final response = await ApiService.get(
        endpoint: '$_baseUrl/api/agents',
        token: token,
      );
      return AgentsResponse.fromJson(response);
    } catch (e) {
      return AgentsResponse.error(e.toString());
    }
  }

  static Future<Map<String, dynamic>> hireAgent({
    required String agentId,
    required String token,
  }) async {
    return ApiService.post(
      endpoint: '$_baseUrl/api/agents/hire',
      body: {'agentId': agentId},
      token: token,
    );
  }

  /// Fetches a map of normalised agent name → energy from the backend.
  /// Returns an empty map on any error — callers should fall back to defaults.
  static Future<Map<String, int>> fetchAgentEnergies() async {
    try {
      final response = await ApiService.get(
        endpoint: '$_baseUrl/api/agents',
      );
      if (response['success'] == true && response['data'] != null) {
        final agentsData = response['data']['agents'] as List<dynamic>;
        return {
          for (final a in agentsData)
            (a['name'] as String).toLowerCase(): a['energy'] as int,
        };
      }
    } catch (_) {
      // Network failure — caller falls back to defaults.
    }
    return {};
  }
}

// ═══════════════════════════════════════════════════════════════
// 📊 API RESPONSE MODELS
// These are backend API models, distinct from domain/models/agent_model.dart
// which is the UI display model used by the marketplace.
// ═══════════════════════════════════════════════════════════════

class AgentApiModel {
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
  final AgentApiStats? stats;
  final DateTime? lastActivity;

  AgentApiModel({
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

  factory AgentApiModel.fromJson(Map<String, dynamic> json) {
    return AgentApiModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? '',
      description: json['description'] ?? '',
      avatar: json['avatar'],
      energy: json['energy'] ?? 0,
      maxEnergy: json['maxEnergy'] ?? 200,
      energyPercentage: json['energyPercentage'] ?? 0,
      status: json['status'] ?? 'inactive',
      readyStatus: json['readyStatus'] ?? 'offline',
      specialties: List<String>.from(json['specialties'] ?? []),
      isReady: json['isReady'] ?? false,
      stats: json['stats'] != null
          ? AgentApiStats.fromJson(json['stats'])
          : null,
      lastActivity: json['lastActivity'] != null
          ? DateTime.tryParse(json['lastActivity'])
          : null,
    );
  }

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
}

class AgentApiStats {
  final int tasksCompleted;
  final int energyUsed;
  final double uptime;

  AgentApiStats({
    required this.tasksCompleted,
    required this.energyUsed,
    required this.uptime,
  });

  factory AgentApiStats.fromJson(Map<String, dynamic> json) {
    return AgentApiStats(
      tasksCompleted: json['tasksCompleted'] ?? 0,
      energyUsed: json['energyUsed'] ?? 0,
      uptime: (json['uptime'] ?? 0).toDouble(),
    );
  }
}

class AgentsResponse {
  final bool success;
  final List<AgentApiModel> agents;
  final int totalEnergy;
  final int agentCount;
  final String? error;

  AgentsResponse({
    required this.success,
    required this.agents,
    required this.totalEnergy,
    required this.agentCount,
    this.error,
  });

  factory AgentsResponse.fromJson(Map<String, dynamic> json) {
    final agentsList = <AgentApiModel>[];
    if (json['data'] != null && json['data']['agents'] != null) {
      for (var item in json['data']['agents']) {
        agentsList.add(AgentApiModel.fromJson(item));
      }
    }

    return AgentsResponse(
      success: json['success'] ?? false,
      agents: agentsList,
      totalEnergy: json['data']?['totalEnergy'] ?? 0,
      agentCount: json['data']?['agentCount'] ?? 0,
      error: null,
    );
  }

  factory AgentsResponse.error(String message) {
    return AgentsResponse(
      success: false,
      agents: [],
      totalEnergy: 0,
      agentCount: 0,
      error: message,
    );
  }
}