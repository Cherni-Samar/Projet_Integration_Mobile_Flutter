import 'package:e_team/core/config/api_config.dart';
import 'package:e_team/data/services/api_service.dart';
import 'package:e_team/data/services/auth_service.dart';

class DexoRepository {
  DexoRepository._();
  static final DexoRepository instance = DexoRepository._();

  static String get _baseUrl => '${ApiConfig.baseUrl}/api/dexo';

  Future<String?> _token() => AuthService().getToken();

  Future<Map<String, dynamic>> getDocumentsByCategory({
    required String category,
    String? userId,
    int limit = 20,
    int offset = 0,
  }) async {
    final queryParams = <String, String>{
      'category': category,
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (userId != null) queryParams['userId'] = userId;

    final uri = Uri.parse(
      '$_baseUrl/documents-by-category',
    ).replace(queryParameters: queryParams).toString();

    return ApiService.get(endpoint: uri, token: await _token());
  }

  Future<Map<String, dynamic>> getDocumentContent({
    required String documentId,
    String? userId,
  }) async {
    final queryParams = <String, String>{};
    if (userId != null) queryParams['userId'] = userId;

    final uri = Uri.parse(
      '$_baseUrl/document-content/$documentId',
    ).replace(queryParameters: queryParams).toString();

    return ApiService.get(endpoint: uri, token: await _token());
  }

  Future<Map<String, dynamic>> updateWorkforceSettings(
    Map<String, dynamic> data,
  ) async {
    return ApiService.patch(
      endpoint: '$_baseUrl/workforce-settings',
      body: data,
      token: await _token(),
    );
  }

  Future<Map<String, dynamic>> getStrategicAdvice(
    Map<String, dynamic> payload,
  ) {
    return ApiService.post(
      endpoint: '$_baseUrl/strategic-advice',
      body: payload,
    );
  }

  Future<Map<String, dynamic>> saveVision(Map<String, dynamic> payload) {
    return ApiService.post(endpoint: '$_baseUrl/save-vision', body: payload);
  }
}
