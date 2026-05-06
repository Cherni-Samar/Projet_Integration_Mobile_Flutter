import 'package:e_team/data/dtos/echo_dto.dart';
import 'package:e_team/data/services/api_service.dart';
import 'package:e_team/core/config/api_config.dart';

class EchoService {
  static String get _baseUrl => ApiConfig.baseUrl;

  static Future<EchoResponse> sendTextMessage({
    required String message,
    required String sender,
    String? token,
  }) async {
    try {
      // Fixed: backend route is /analyser, not /echo. Backend only expects {message}.
      final response = await ApiService.post(
        endpoint: '$_baseUrl/api/echo/analyser',
        body: {'message': message},
        token: token,
      );
      return EchoResponse.fromJson(response);
    } catch (e) {
      return EchoResponse.error(e.toString());
    }
  }

  static Future<EmailsResponse> getEmails({String? token}) async {
    try {
      final response = await ApiService.get(
        endpoint: '$_baseUrl/api/emails',
        token: token,
      );
      return EmailsResponse.fromJson(response);
    } catch (e) {
      return EmailsResponse.error(e.toString());
    }
  }

  static Future<PendingResponse> getPending({String? token}) async {
    try {
      final response = await ApiService.get(
        endpoint: '$_baseUrl/api/emails/pending',
        token: token,
      );
      return PendingResponse.fromJson(response);
    } catch (e) {
      return PendingResponse.error(e.toString());
    }
  }

  static Future<bool> markAsRead(String emailId, {String? token}) async {
    try {
      final response = await ApiService.patch(
        endpoint: '$_baseUrl/api/emails/$emailId/read',
        body: {},
        token: token,
      );
      return response['success'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteEmail(String emailId, {String? token}) async {
    try {
      final response = await ApiService.delete(
        endpoint: '$_baseUrl/api/emails/$emailId',
        token: token,
      );
      return response['success'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<ResponseSuggestionsResponse> getResponseSuggestions({
    required String message,
    required String sender,
    Map<String, dynamic>? context,
    Map<String, dynamic>? analysis,
    String? token,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: '$_baseUrl/api/echo/response-suggestions',
        body: {
          'message': message,
          'sender': sender,
          'context': context ?? {},
          'analysis': analysis,
        },
        token: token,
      );
      return ResponseSuggestionsResponse.fromJson(response);
    } catch (e) {
      return ResponseSuggestionsResponse.error(e.toString());
    }
  }

  static Future<Map<String, dynamic>> sendEmailToHera({
    required String subject,
    required String content,
    String? from,
    String? token,
  }) async {
    try {
      return await ApiService.post(
        endpoint: '$_baseUrl/api/echo/send-to-hera',
        body: {
          'subject': subject,
          'content': content,
          'from': from ?? 'echo@e-team.com',
        },
        token: token,
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<SpamCheckResponse> checkSpam({
    required String message,
    String? token,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: '$_baseUrl/api/messages/spam-check',
        body: {'message': message},
        token: token,
      );
      return SpamCheckResponse.fromJson(response);
    } catch (e) {
      return SpamCheckResponse.error(e.toString());
    }
  }

  static Future<StatsResponse> getStats({String? token}) async {
    try {
      final response = await ApiService.get(
        endpoint: '$_baseUrl/api/messages/stats',
        token: token,
      );
      return StatsResponse.fromJson(response);
    } catch (e) {
      return StatsResponse.error(e.toString());
    }
  }

  static Future<Map<String, dynamic>> saveClassifiedDocument({
    required String content,
    required Map<String, dynamic> classification,
    String? token,
  }) async {
    try {
      return await ApiService.post(
        endpoint: '$_baseUrl/api/echo/save-document',
        body: {'content': content, 'classification': classification},
        token: token,
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<TaskExtractionResponse> extractAndSaveTasks({
    required String message,
    required String sender,
    String? emailId,
    String? subject,
    String? token,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: '$_baseUrl/api/echo/extract-save-tasks',
        body: {
          'message': message,
          'sender': sender,
          'emailId': emailId,
          'subject': subject,
        },
        token: token,
      );
      return TaskExtractionResponse.fromJson(response);
    } catch (e) {
      return TaskExtractionResponse.error(e.toString());
    }
  }

  static Future<TaskListResponse> getTasks({
    String? status,
    String? category,
    String? token,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (status != null) queryParams['status'] = status;
      if (category != null) queryParams['category'] = category;

      String endpoint = '$_baseUrl/api/echo/tasks';

      if (queryParams.isNotEmpty) {
        endpoint +=
            '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
      }

      final response = await ApiService.get(endpoint: endpoint, token: token);

      return TaskListResponse.fromJson(response);
    } catch (e) {
      return TaskListResponse.error(e.toString());
    }
  }

  static Future<Map<String, dynamic>> updateTaskStatus({
    required String taskId,
    required String status,
    String? token,
  }) async {
    try {
      return await ApiService.patch(
        endpoint: '$_baseUrl/api/echo/tasks/$taskId/status',
        body: {'status': status},
        token: token,
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteTask({
    required String taskId,
    String? token,
  }) async {
    try {
      return await ApiService.delete(
        endpoint: '$_baseUrl/api/echo/tasks/$taskId',
        token: token,
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<PostsResponse> getMobilePosts({
    int page = 1,
    int limit = 20,
    String? platform,
    String? token,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (platform != null) {
        queryParams['platform'] = platform;
      }

      String endpoint = '$_baseUrl/api/echo/mobile/posts';

      endpoint +=
          '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';

      final response = await ApiService.get(endpoint: endpoint, token: token);

      return PostsResponse.fromJson(response);
    } catch (e) {
      return PostsResponse.error(e.toString());
    }
  }

  static Future<Map<String, dynamic>> forcePost({String? token}) async {
    try {
      return await ApiService.post(
        endpoint: '$_baseUrl/api/echo/mobile/force-post',
        body: {},
        token: token,
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> scrapeProduct({
    required String productUrl,
    String? token,
  }) async {
    try {
      return await ApiService.post(
        endpoint: '$_baseUrl/api/echo/product/scrape',
        body: {'productUrl': productUrl},
        token: token,
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> startProductCampaign({
    required String productUrl,
    required String frequency,
    required List<String> platforms,
    String? token,
  }) async {
    try {
      return await ApiService.post(
        endpoint: '$_baseUrl/api/echo/product/campaign/start',
        body: {
          'productUrl': productUrl,
          'frequency': frequency,
          'platforms': platforms,
        },
        token: token,
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getCampaignStatus({String? token}) async {
    try {
      return await ApiService.get(
        endpoint: '$_baseUrl/api/echo/product/campaign/status',
        token: token,
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> stopProductCampaign({
    String? token,
  }) async {
    try {
      return await ApiService.post(
        endpoint: '$_baseUrl/api/echo/product/campaign/stop',
        body: {},
        token: token,
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getCampaignHistory({
    int limit = 50,
    String? status,
    String? token,
  }) async {
    try {
      final queryParams = <String, String>{'limit': limit.toString()};

      if (status != null) {
        queryParams['status'] = status;
      }

      String endpoint = '$_baseUrl/api/echo/product/campaign/history';

      endpoint +=
          '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';

      return await ApiService.get(endpoint: endpoint, token: token);
    } catch (e) {
      return {'success': false, 'error': e.toString(), 'campaigns': []};
    }
  }
}
