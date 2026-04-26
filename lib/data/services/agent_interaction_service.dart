import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:e_team/presentation/screens/agent/agent_inter_flow_page.dart';
import 'package:e_team/data/services/auth_service.dart';

class AgentInteractionService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/hera';

  static Future<Map<String, String>> _headers({String? token}) async {
    final savedToken = token ?? await AuthService().getToken();

    print('🔐 TOKEN ACTIVITY EXISTS => ${savedToken != null && savedToken.isNotEmpty}');
    print('🔐 TOKEN ACTIVITY VALUE => $savedToken');

    if (savedToken == null || savedToken.isEmpty) {
      return {
        'Content-Type': 'application/json',
      };
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $savedToken',
    };
  }
  static Future<List<AgentInteraction>> getAgentInteractions({
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/admin/agent-interactions');

      print('📡 Tentative de connexion à : $uri');

      final response = await http.get(
        uri,
        headers: await _headers(token: token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['interactions'] ?? data['logs'] ?? [];

        print('✅ Données reçues : ${list.length} logs trouvés');

        return list.map((json) => AgentInteraction.fromJson(json)).toList();
      }

      print('❌ Erreur HTTP : ${response.statusCode}');
      print('❌ Body : ${response.body}');
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
      print('⚠️ Stats Body: ${response.body}');

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