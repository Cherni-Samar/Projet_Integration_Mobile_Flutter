import '../../data/models/agent.dart';

abstract class IAgentRepository {
  Future<List<Agent>> getAllAgents({String? token});
  Future<Agent?> getAgent({required String agentId, String? token});
  Future<Map<String, dynamic>> initializeAgents({String? token});
}
