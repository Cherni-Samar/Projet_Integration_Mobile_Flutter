import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart'; // Assure-toi d'importer ton URL de base

class TimoService {
  static const String baseUrl = "http://10.0.2.2:3000/api/hera"; // URL Android Emulator

  // ── LIRE L'INBOX ──
  static Future<Map<String, dynamic>> getTimoInbox() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/timo-inbox'),
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
      // ✅ On s'assure que le chemin est exact : /admin/timo-confirm
      final url = Uri.parse('$baseUrl/admin/timo-confirm');

      print("📡 Tentative POST sur: $url"); // Pour vérifier dans ta console Flutter

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
    final response = await http.get(
      Uri.parse('$baseUrl/admin/timo-tasks'), // ✅ Route Ligne 55
      headers: {"Content-Type": "application/json"},
    );
    return jsonDecode(response.body);
  }}