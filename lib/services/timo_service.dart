import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class TimoService {
  // ── LIRE L'INBOX ──
  static Future<Map<String, dynamic>> getTimoInbox() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/timo/inbox'),
        headers: {"Content-Type": "application/json"},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  // ── CONFIRMER LE PLANNING ──
  static Future<Map<String, dynamic>> confirmPlanning({
    required String emailId,
    required String date,
    required String name,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/timo/confirm');

      print("📡 Tentative POST sur: $url");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "emailId": emailId,
          "selectedDate": date,
          "employeeName": name
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getTimoTasks() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/timo/tasks'),
        headers: {"Content-Type": "application/json"},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> autoPlanMeeting({
    required String employeeName,
    required String type,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/timo/auto-plan'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "employeeName": employeeName,
          "type": type
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }
}
