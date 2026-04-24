import 'dart:convert';
import 'api_service.dart';
import '../models/agent_model.dart';
export '../models/agent_model.dart';

class AgentService {
  static const String _baseUrl = 'http://10.0.2.2:3000';

  static Future<AgentsResponse> getAllAgents({String? token}) async {
    try {
      print('🔍 AgentService.getAllAgents called');
      final response = await ApiService.get(
        endpoint: '$_baseUrl/api/agents',
        token: token,
      );
      final result = AgentsResponse.fromJson(response);
      print('✅ Loaded ${result.agents.length} agents');
      return result;
    } catch (e) {
      print('❌ AgentService - getAllAgents error: $e');
      return AgentsResponse.error(e.toString());
    }
  }

  static Future<AgentResponse> getAgent({
    required String agentId,
    String? token,
  }) async {
    try {
      final response = await ApiService.get(
        endpoint: '$_baseUrl/api/agents/$agentId',
        token: token,
      );
      return AgentResponse.fromJson(response);
    } catch (e) {
      print('❌ AgentService - getAgent error: $e');
      return AgentResponse.error(e.toString());
    }
  }

  static Future<Map<String, dynamic>> initializeAgents({String? token}) async {
    try {
      final response = await ApiService.post(
        endpoint: '$_baseUrl/api/agents/initialize',
        body: {},
        token: token,
      );
      return response;
    } catch (e) {
      print('❌ AgentService - initializeAgents error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}

