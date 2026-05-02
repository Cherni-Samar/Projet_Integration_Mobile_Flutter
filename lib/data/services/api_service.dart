import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ✅ Headers avec x-auth-token
  static Map<String, String> _getHeaders({String? token}) {
    print('🔧 ========== BUILD HEADERS ==========');

    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['x-auth-token'] = token;
      print('🔧 Token ajouté aux headers:');
      print('   - Longueur: ${token.length}');
      print('   - Début: ${token.substring(0, 30)}');
      print('   - Fin: ${token.substring(token.length - 30)}');
      print('   - COMPLET: $token');
    } else {
      print('⚠️ AUCUN TOKEN à ajouter aux headers');
    }

    print('🔧 Headers finaux: $headers');
    print('🔧 ========== BUILD HEADERS END ==========');

    return headers;
  }

  // POST Request
  static Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    try {
      print('📤 POST Request: $endpoint');
      print('📤 Body: $body');

      final response = await http.post(
        Uri.parse(endpoint),
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ POST Error: $e');
      if (e is Exception) throw e;
      throw Exception('Erreur de connexion: $e');
    }
  }

  // PUT Request
  static Future<Map<String, dynamic>> put({
    required String endpoint,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    try {
      print('📤 PUT Request: $endpoint');
      print('📤 Body: $body');

      final response = await http.put(
        Uri.parse(endpoint),
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ PUT Error: $e');
      if (e is Exception) throw e;
      throw Exception('Erreur de connexion: $e');
    }
  }

  // GET Request
  static Future<Map<String, dynamic>> get({
    required String endpoint,
    String? token,
  }) async {
    try {
      print('📤 GET Request: $endpoint');

      final response = await http.get(
        Uri.parse(endpoint),
        headers: _getHeaders(token: token),
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ GET Error: $e');
      if (e is Exception) throw e;
      throw Exception('Erreur de connexion: $e');
    }
  }

  // ✅ PATCH Method
  static Future<Map<String, dynamic>> patch({
    required String endpoint,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    try {
      print('📤 ========== PATCH REQUEST ==========');
      print('📤 Endpoint: $endpoint');
      print('📤 Token reçu:');
      print('   - Existe: ${token != null}');
      print('   - Longueur: ${token?.length ?? 0}');
      if (token != null) {
        print('   - Début: ${token.substring(0, 30)}');
        print('   - Fin: ${token.substring(token.length - 30)}');
        print('   - COMPLET: $token');
      }
      print('📤 Body: $body');

      final headers = _getHeaders(token: token);

      print('📤 Envoi de la requête HTTP...');
      final response = await http.patch(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: Server not responding');
        },
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      print('📤 ========== PATCH REQUEST END ==========');

      return _handleResponse(response);
    } catch (e) {
      print('❌ PATCH Error: $e');
      if (e is Exception) throw e;
      throw Exception('$e');
    }
  }

  // DELETE Request
  static Future<Map<String, dynamic>> delete({
    required String endpoint,
    String? token,
  }) async {
    try {
      print('📤 DELETE Request: $endpoint');

      final response = await http.delete(
        Uri.parse(endpoint),
        headers: _getHeaders(token: token),
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ DELETE Error: $e');
      if (e is Exception) throw e;
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Gérer la réponse
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final status = response.statusCode;
    final body = response.body;
    final contentType = response.headers['content-type'] ?? '';

    dynamic parsed;
    final trimmed = body.trimLeft();
    final looksLikeJson = trimmed.startsWith('{') || trimmed.startsWith('[');
    final isJsonContentType = contentType.toLowerCase().contains('application/json');

    if (body.isNotEmpty && (isJsonContentType || looksLikeJson)) {
      try {
        parsed = jsonDecode(body);
      } catch (_) {
        parsed = null;
      }
    }

    if (status >= 200 && status < 300) {
      if (parsed == null) {
        if (body.isEmpty) return <String, dynamic>{};
        return <String, dynamic>{'raw': body};
      }
      if (parsed is Map<String, dynamic>) return parsed;
      return <String, dynamic>{'data': parsed};
    }

    String message;
    if (parsed is Map && parsed['message'] is String) {
      message = parsed['message'] as String;
    } else if (parsed is Map && parsed['error'] is String) {
      message = parsed['error'] as String;
    } else {
      // HTML errors (ex: Express default 404) or plain text
      final normalized = body.replaceAll(RegExp(r'\s+'), ' ').trim();
      final preMatch = RegExp(r'<pre>(.*?)</pre>', caseSensitive: false)
          .firstMatch(body)
          ?.group(1)
          ?.trim();
      message = (preMatch != null && preMatch.isNotEmpty)
          ? preMatch
          : (normalized.isEmpty
              ? 'Une erreur est survenue'
              : (normalized.length > 200 ? normalized.substring(0, 200) + '…' : normalized));
    }

    throw Exception('HTTP $status: $message');
  }
}