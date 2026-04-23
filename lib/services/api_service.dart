// Kept for backward compatibility.
// Delegates all calls to the new ApiClient in core/network.
// New code should use ApiClient directly.
import '../core/network/api_client.dart';

class ApiService {
  static Future<Map<String, dynamic>> get({
    required String endpoint,
    String? token,
  }) =>
      ApiClient.get(endpoint: endpoint, token: token);

  static Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> body,
    String? token,
  }) =>
      ApiClient.post(endpoint: endpoint, body: body, token: token);

  static Future<Map<String, dynamic>> patch({
    required String endpoint,
    required Map<String, dynamic> body,
    String? token,
  }) =>
      ApiClient.patch(endpoint: endpoint, body: body, token: token);

  static Future<Map<String, dynamic>> delete({
    required String endpoint,
    String? token,
  }) =>
      ApiClient.delete(endpoint: endpoint, token: token);
}
