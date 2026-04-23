import 'dart:convert';
import 'package:http/http.dart' as http;

/// Central HTTP client used by all services/repositories.
/// Replaces the legacy ApiService with clean error handling and no debug prints.
class ApiClient {
  static Map<String, String> _headers({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['x-auth-token'] = token;
    }
    return headers;
  }

  static Future<Map<String, dynamic>> get({
    required String endpoint,
    String? token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: _headers(token: token),
      );
      return _handleResponse(response);
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: _headers(token: token),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> patch({
    required String endpoint,
    required Map<String, dynamic> body,
    String? token,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse(endpoint),
            headers: _headers(token: token),
            body: jsonEncode(body),
          )
          .timeout(timeout, onTimeout: () {
        throw Exception('Timeout: Server not responding');
      });
      return _handleResponse(response);
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> delete({
    required String endpoint,
    String? token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse(endpoint),
        headers: _headers(token: token),
      );
      return _handleResponse(response);
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final status = response.statusCode;
    final body = response.body;
    final contentType = response.headers['content-type'] ?? '';

    dynamic parsed;
    final trimmed = body.trimLeft();
    final looksLikeJson =
        trimmed.startsWith('{') || trimmed.startsWith('[');
    final isJsonContentType =
        contentType.toLowerCase().contains('application/json');

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
      final normalized = body.replaceAll(RegExp(r'\s+'), ' ').trim();
      final preMatch = RegExp(r'<pre>(.*?)</pre>', caseSensitive: false)
          .firstMatch(body)
          ?.group(1)
          ?.trim();
      message = (preMatch != null && preMatch.isNotEmpty)
          ? preMatch
          : (normalized.isEmpty
              ? 'An error occurred'
              : (normalized.length > 200
                  ? '${normalized.substring(0, 200)}…'
                  : normalized));
    }

    throw Exception('HTTP $status: $message');
  }
}
