import 'package:e_team/core/config/api_config.dart';
import 'package:e_team/data/services/api_service.dart';

class EchoRepository {
  EchoRepository._();
  static final EchoRepository instance = EchoRepository._();

  static String get _baseUrl => ApiConfig.baseUrl;

  Future<Map<String, dynamic>> sendTextMessage({
    required String message,
    String? token,
  }) {
    return ApiService.post(
      endpoint: '$_baseUrl/api/echo/analyser',
      body: {'message': message},
      token: token,
    );
  }

  Future<Map<String, dynamic>> getEmails({String? token}) {
    return ApiService.get(endpoint: '$_baseUrl/api/emails', token: token);
  }

  Future<Map<String, dynamic>> getPending({String? token}) {
    return ApiService.get(
      endpoint: '$_baseUrl/api/emails/pending',
      token: token,
    );
  }

  Future<Map<String, dynamic>> markAsRead(String emailId, {String? token}) {
    return ApiService.patch(
      endpoint: '$_baseUrl/api/emails/$emailId/read',
      body: {},
      token: token,
    );
  }

  Future<Map<String, dynamic>> deleteEmail(String emailId, {String? token}) {
    return ApiService.delete(
      endpoint: '$_baseUrl/api/emails/$emailId',
      token: token,
    );
  }

  Future<Map<String, dynamic>> getResponseSuggestions({
    required String message,
    required String sender,
    Map<String, dynamic>? context,
    Map<String, dynamic>? analysis,
    String? token,
  }) {
    return ApiService.post(
      endpoint: '$_baseUrl/api/echo/response-suggestions',
      body: {
        'message': message,
        'sender': sender,
        'context': context ?? {},
        'analysis': analysis,
      },
      token: token,
    );
  }

  Future<Map<String, dynamic>> sendEmailToHera({
    required String subject,
    required String content,
    String? from,
    String? token,
  }) {
    return ApiService.post(
      endpoint: '$_baseUrl/api/echo/send-to-hera',
      body: {
        'subject': subject,
        'content': content,
        'from': from ?? 'echo@e-team.com',
      },
      token: token,
    );
  }

  Future<Map<String, dynamic>> checkSpam({
    required String message,
    String? token,
  }) {
    return ApiService.post(
      endpoint: '$_baseUrl/api/messages/spam-check',
      body: {'message': message},
      token: token,
    );
  }

  Future<Map<String, dynamic>> getStats({String? token}) {
    return ApiService.get(
      endpoint: '$_baseUrl/api/messages/stats',
      token: token,
    );
  }

  Future<Map<String, dynamic>> saveClassifiedDocument({
    required String content,
    required Map<String, dynamic> classification,
    String? token,
  }) {
    return ApiService.post(
      endpoint: '$_baseUrl/api/echo/save-document',
      body: {'content': content, 'classification': classification},
      token: token,
    );
  }

  Future<Map<String, dynamic>> extractAndSaveTasks({
    required String message,
    required String sender,
    String? emailId,
    String? subject,
    String? token,
  }) {
    return ApiService.post(
      endpoint: '$_baseUrl/api/echo/extract-save-tasks',
      body: {
        'message': message,
        'sender': sender,
        'emailId': emailId,
        'subject': subject,
      },
      token: token,
    );
  }

  Future<Map<String, dynamic>> getTasks({
    String? status,
    String? category,
    String? token,
  }) {
    final queryParams = <String, String>{};

    if (status != null) queryParams['status'] = status;
    if (category != null) queryParams['category'] = category;

    var endpoint = '$_baseUrl/api/echo/tasks';

    if (queryParams.isNotEmpty) {
      endpoint +=
          '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }

    return ApiService.get(endpoint: endpoint, token: token);
  }

  Future<Map<String, dynamic>> updateTaskStatus({
    required String taskId,
    required String status,
    String? token,
  }) {
    return ApiService.patch(
      endpoint: '$_baseUrl/api/echo/tasks/$taskId/status',
      body: {'status': status},
      token: token,
    );
  }

  Future<Map<String, dynamic>> deleteTask({
    required String taskId,
    String? token,
  }) {
    return ApiService.delete(
      endpoint: '$_baseUrl/api/echo/tasks/$taskId',
      token: token,
    );
  }

  Future<Map<String, dynamic>> getMobilePosts({
    int page = 1,
    int limit = 20,
    String? platform,
    String? token,
  }) {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (platform != null) {
      queryParams['platform'] = platform;
    }

    final endpoint =
        '$_baseUrl/api/echo/mobile/posts?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';

    return ApiService.get(endpoint: endpoint, token: token);
  }

  Future<Map<String, dynamic>> forcePost({String? token}) {
    return ApiService.post(
      endpoint: '$_baseUrl/api/echo/mobile/force-post',
      body: {},
      token: token,
    );
  }

  Future<Map<String, dynamic>> scrapeProduct({
    required String productUrl,
    String? token,
  }) {
    return ApiService.post(
      endpoint: '$_baseUrl/api/echo/product/scrape',
      body: {'productUrl': productUrl},
      token: token,
    );
  }

  Future<Map<String, dynamic>> startProductCampaign({
    required String productUrl,
    required String frequency,
    required List<String> platforms,
    String? token,
  }) {
    return ApiService.post(
      endpoint: '$_baseUrl/api/echo/product/campaign/start',
      body: {
        'productUrl': productUrl,
        'frequency': frequency,
        'platforms': platforms,
      },
      token: token,
    );
  }

  Future<Map<String, dynamic>> getCampaignStatus({String? token}) {
    return ApiService.get(
      endpoint: '$_baseUrl/api/echo/product/campaign/status',
      token: token,
    );
  }

  Future<Map<String, dynamic>> stopProductCampaign({String? token}) {
    return ApiService.post(
      endpoint: '$_baseUrl/api/echo/product/campaign/stop',
      body: {},
      token: token,
    );
  }

  Future<Map<String, dynamic>> getCampaignHistory({
    int limit = 50,
    String? status,
    String? token,
  }) {
    final queryParams = <String, String>{'limit': limit.toString()};

    if (status != null) {
      queryParams['status'] = status;
    }

    final endpoint =
        '$_baseUrl/api/echo/product/campaign/history?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';

    return ApiService.get(endpoint: endpoint, token: token);
  }
}
