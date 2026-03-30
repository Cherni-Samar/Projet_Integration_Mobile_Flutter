import 'package:http/http.dart' as http;
import 'dart:convert';

class AgentMailService {
  static const String baseUrl = 'http://192.168.1.102:3000';

  // Envoyer un email d'un agent à un autre
  static Future<bool> sendEmail({
    required String fromAgent,
    required String toAgent,
    required String subject,
    required String content,
    String? token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/messages/email'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'x-auth-token': token,
        },
        body: jsonEncode({
          'from': fromAgent,
          'to': toAgent,
          'subject': subject,
          'content': content,
          'type': 'internal',
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur envoi email: $e');
      return false;
    }
  }
}