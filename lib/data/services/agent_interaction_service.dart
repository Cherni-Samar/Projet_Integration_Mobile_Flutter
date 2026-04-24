import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:e_team/presentation/screens/agent/agent_inter_flow_page.dart';

class AgentInteractionService {
  // ✅ 10.0.2.2 est l'adresse IP de ton Mac pour l'émulateur Android
  // ✅ On ajoute le préfixe /api/hera qui est dans ton app.js
  static const String baseUrl = 'http://10.0.2.2:3000/api/hera';

  static Future<List<AgentInteraction>> getAgentInteractions({String? token}) async {
    try {
      print('📡 Tentative de connexion à : $baseUrl/admin/agent-interactions');

      final response = await http.get(
        Uri.parse('$baseUrl/admin/agent-interactions'), // ✅ La route exacte
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // On vérifie si la clé est 'interactions' ou 'logs'
        final List<dynamic> list = data['interactions'] ?? data['logs'] ?? [];

        print('✅ Données reçues : ${list.length} logs trouvés');

        return list.map((json) => AgentInteraction.fromJson(json)).toList();
      } else {
        print('❌ Erreur HTTP : ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Erreur Service Interaction : $e');
      return []; // Retourne une liste vide pour ne pas faire crash le front
    }
  }


  /// Récupère les statistiques des interactions
  static Future<Map<String, int>> getInteractionStats({String? token}) async {
    // ✅ CORRECTION DE L'URL : 10.0.2.2 + le bon préfixe
    const String statsUrl = 'http://10.0.2.2:3000/api/hera/admin/agent-interactions/stats';

    try {
      final response = await http.get(
        Uri.parse(statsUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
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
      return {'total': 0, 'successful': 0, 'encrypted': 0, 'pending': 0, 'failed': 0};

    } catch (e) {
      print('❌ AgentInteractionService - Stats Exception: $e');
      return {'total': 0, 'successful': 0, 'encrypted': 0, 'pending': 0, 'failed': 0};
    }
  }
}