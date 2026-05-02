import 'api_service.dart';
import 'api_config.dart';

class AgentService {
  static String get _baseUrl => ApiConfig.baseUrl;

  // ═══════════════════════════════════════════════════════════════
  // 🤖 AGENT MANAGEMENT METHODS
  // ═══════════════════════════════════════════════════════════════

  static Future<AgentsResponse> getAllAgents({String? token}) async {
    try {
      print('🔍 AgentService.getAllAgents called with token: ${token != null ? "YES" : "NO"}');
      final response = await ApiService.get(
        endpoint: '$_baseUrl/api/agents',
        token: token,
      );
      print('🔍 Raw API response: $response');
      final result = AgentsResponse.fromJson(response);
      print('🔍 Parsed AgentsResponse - success: ${result.success}, agents: ${result.agents.length}, totalEnergy: ${result.totalEnergy}');
      return result;
    } catch (e) {
      print('❌ AgentService - getAllAgents error: $e');
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
}

// ═══════════════════════════════════════════════════════════════
// 📊 DATA MODELS
// ═══════════════════════════════════════════════════════════════

class Agent {
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

  Agent({
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

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
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
      stats: json['stats'] != null ? AgentStats.fromJson(json['stats']) : null,
      lastActivity: json['lastActivity'] != null 
          ? DateTime.tryParse(json['lastActivity']) 
          : null,
    );
  }

  // Helper methods
  bool get isActive => status == 'active';
  bool get isOnline => readyStatus == 'ready';
  bool get hasLowEnergy => energy < (maxEnergy * 0.1); // Less than 10%
  bool get hasEnergy => energy > 0;
  
  String get statusColor {
    if (!isActive) return 'grey';
    if (!hasEnergy) return 'red';
    if (hasLowEnergy) return 'orange';
    return 'green';
  }
}

class AgentStats {
  final int tasksCompleted;
  final int energyUsed;
  final double uptime;

  AgentStats({
    required this.tasksCompleted,
    required this.energyUsed,
    required this.uptime,
  });

  factory AgentStats.fromJson(Map<String, dynamic> json) {
    return AgentStats(
      tasksCompleted: json['tasksCompleted'] ?? 0,
      energyUsed: json['energyUsed'] ?? 0,
      uptime: (json['uptime'] ?? 0).toDouble(),
    );
  }
}

class AgentsResponse {
  final bool success;
  final List<Agent> agents;
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
    final agentsList = <Agent>[];
    if (json['data'] != null && json['data']['agents'] != null) {
      for (var item in json['data']['agents']) {
        agentsList.add(Agent.fromJson(item));
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