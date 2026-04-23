import '../../core/network/api_client.dart';
import '../../data/mappers/agent_mapper.dart';
import '../../data/models/agent.dart';
import '../../domain/repositories/i_agent_repository.dart';

class AgentRepository implements IAgentRepository {
  static const String _baseUrl = 'http://10.0.2.2:3000';

  @override
  Future<List<Agent>> getAllAgents({String? token}) async {
    final response = await ApiClient.get(
      endpoint: '$_baseUrl/api/agents',
      token: token,
    );

    final agentsJson = response['data']?['agents'];
    if (agentsJson is List) {
      return agentsJson
          .map((json) => AgentMapper.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<Agent?> getAgent({required String agentId, String? token}) async {
    final response = await ApiClient.get(
      endpoint: '$_baseUrl/api/agents/$agentId',
      token: token,
    );
    if (response['data'] != null) {
      return AgentMapper.fromJson(response['data'] as Map<String, dynamic>);
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>> initializeAgents({String? token}) async {
    return ApiClient.post(
      endpoint: '$_baseUrl/api/agents/initialize',
      body: {},
      token: token,
    );
  }
}
