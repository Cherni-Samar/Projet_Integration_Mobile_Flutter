import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:e_team/data/services/auth_service.dart';
import 'package:e_team/core/config/api_config.dart';
import 'package:e_team/domain/models/agent_interaction_model.dart';

class AgentInteractionService {
  static String get baseUrl => '${ApiConfig.baseUrl}/api/hera';

  static Future<Map<String, String>> _headers({String? token}) async {
    final savedToken = token ?? await AuthService().getToken();

    if (savedToken == null || savedToken.isEmpty) {
      return {
        'Content-Type': 'application/json',
      };
    }

    // Fixed: backend authMiddleware expects 'x-auth-token', not 'Authorization: Bearer'.
    return {
      'Content-Type': 'application/json',
      'x-auth-token': savedToken,
    };
  }

  static Future<List<AgentInteraction>> getAgentInteractions({
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/admin/agent-interactions');

      final response = await http.get(
        uri,
        headers: await _headers(token: token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['interactions'] ?? data['logs'] ?? [];

        return list.map((json) => AgentInteraction.fromJson(json)).toList();
      }

      print('❌ Erreur HTTP : ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ Erreur Service Interaction : $e');
      return [];
    }
  }

  static Future<Map<String, int>> getInteractionStats({
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/admin/agent-interactions/stats');

      final response = await http.get(
        uri,
        headers: await _headers(token: token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['stats'] != null) {
          final stats = data['stats'] as Map<String, dynamic>;

          return {
            'total': (stats['total'] as num?)?.toInt() ?? 0,
            'successful': (stats['successful'] as num?)?.toInt() ?? 0,
            'encrypted': (stats['encrypted'] as num?)?.toInt() ?? 0,
            'pending': (stats['pending'] as num?)?.toInt() ?? 0,
            'failed': (stats['failed'] as num?)?.toInt() ?? 0,
          };
        }
      }

      print('⚠️ Stats API Error: ${response.statusCode}');

      return {
        'total': 0,
        'successful': 0,
        'encrypted': 0,
        'pending': 0,
        'failed': 0,
      };
    } catch (e) {
      print('❌ AgentInteractionService - Stats Exception: $e');

      return {
        'total': 0,
        'successful': 0,
        'encrypted': 0,
        'pending': 0,
        'failed': 0,
      };
    }
  }
}
