import 'dart:convert';
import 'package:http/http.dart' as http;

class HrAgentService {
  // Android emulator  → 10.0.2.2
  // iOS simulator     → localhost
  // Device physique   → ton IP locale ex: 192.168.1.x
  static const String _baseUrl = 'http://10.0.2.2:3000/api/agents';

  static Future<Map<String, dynamic>> hello({String username = 'user'}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/hr?username=$username'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur ${response.statusCode}');
  }
}
