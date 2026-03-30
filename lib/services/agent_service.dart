import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../utils/constants.dart';

class AgentService {
  static const String baseUrl = 'http://192.168.1.102:3000/api';

  /// Hire an agent (add to user's activeAgents)
  static Future<Map<String, dynamic>> hireAgent({
    required String agentId,
    required String token,
  }) async {
    try {
      print('🤖 Hiring agent: $agentId');
      
      final response = await ApiService.post(
        endpoint: ApiConstants.hireAgent,
        body: {'agentId': agentId},
        token: token,
      );

      print('✅ Agent hired successfully: $agentId');
      return response;
    } catch (e) {
      print('❌ Error hiring agent: $e');
      rethrow;
    }
  }

  /// Get agent status
  static Future<Map<String, dynamic>> getAgentStatus({
    required String agentId,
    String? token,
  }) async {
    try {
      final response = await ApiService.get(
        endpoint: '$baseUrl/agents/$agentId',
        token: token,
      );

      return response;
    } catch (e) {
      print('❌ Error getting agent status: $e');
      rethrow;
    }
  }

  /// Process document with Dexo agent
  static Future<Map<String, dynamic>> processWithDexo({
    required String filename,
    required String content,
    String action = 'classify',
    Map<String, dynamic>? metadata,
    required String token,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: '$baseUrl/agents/dexo',
        body: {
          'filename': filename,
          'content': content,
          'action': action,
          if (metadata != null) 'metadata': metadata,
        },
        token: token,
      );

      return response;
    } catch (e) {
      print('❌ Error processing with Dexo: $e');
      rethrow;
    }
  }

  /// Analyze message with Echo agent
  static Future<Map<String, dynamic>> analyzeWithEcho({
    required String message,
    String? sender,
    required String token,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: '$baseUrl/agents/echo',
        body: {
          'message': message,
          if (sender != null) 'sender': sender,
        },
        token: token,
      );

      return response;
    } catch (e) {
      print('❌ Error analyzing with Echo: $e');
      rethrow;
    }
  }

  /// Direct Echo analysis (no auth required)
  static Future<Map<String, dynamic>> analyzeWithEchoDirect({
    required String message,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: '$baseUrl/echo/analyser',
        body: {'message': message},
      );

      return response;
    } catch (e) {
      print('❌ Error with direct Echo analysis: $e');
      rethrow;
    }
  }

  /// Batch analyze messages with Echo
  static Future<Map<String, dynamic>> batchAnalyzeWithEcho({
    required List<String> messages,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: '$baseUrl/echo/batch',
        body: {'messages': messages},
      );

      return response;
    } catch (e) {
      print('❌ Error with batch Echo analysis: $e');
      rethrow;
    }
  }
}