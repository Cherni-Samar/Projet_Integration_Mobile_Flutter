import 'package:e_team/data/dtos/echo/echo_dto.dart';
import 'package:e_team/data/repositories/echo_repository.dart';

class EchoService {
  static final _repo = EchoRepository.instance;

  static Future<EchoResponse> sendTextMessage({
    required String message,
    required String sender,
    String? token,
  }) async {
    try {
      final response = await _repo.sendTextMessage(
        message: message,
        token: token,
      );
      return EchoResponse.fromJson(response);
    } catch (e) {
      return EchoResponse.error(e.toString());
    }
  }

  static Future<EmailsResponse> getEmails({String? token}) async {
    try {
      final response = await _repo.getEmails(token: token);
      return EmailsResponse.fromJson(response);
    } catch (e) {
      return EmailsResponse.error(e.toString());
    }
  }

  static Future<PendingResponse> getPending({String? token}) async {
    try {
      final response = await _repo.getPending(token: token);
      return PendingResponse.fromJson(response);
    } catch (e) {
      return PendingResponse.error(e.toString());
    }
  }

  static Future<bool> markAsRead(String emailId, {String? token}) async {
    try {
      final response = await _repo.markAsRead(emailId, token: token);
      return response['success'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteEmail(String emailId, {String? token}) async {
    try {
      final response = await _repo.deleteEmail(emailId, token: token);
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
      final response = await _repo.getResponseSuggestions(
        message: message,
        sender: sender,
        context: context,
        analysis: analysis,
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
      return await _repo.sendEmailToHera(
        subject: subject,
        content: content,
        from: from,
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
      final response = await _repo.checkSpam(message: message, token: token);
      return SpamCheckResponse.fromJson(response);
    } catch (e) {
      return SpamCheckResponse.error(e.toString());
    }
  }

  static Future<StatsResponse> getStats({String? token}) async {
    try {
      final response = await _repo.getStats(token: token);
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
      return await _repo.saveClassifiedDocument(
        content: content,
        classification: classification,
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
      final response = await _repo.extractAndSaveTasks(
        message: message,
        sender: sender,
        emailId: emailId,
        subject: subject,
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
      final response = await _repo.getTasks(
        status: status,
        category: category,
        token: token,
      );

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
      return await _repo.updateTaskStatus(
        taskId: taskId,
        status: status,
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
      return await _repo.deleteTask(taskId: taskId, token: token);
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
      final response = await _repo.getMobilePosts(
        page: page,
        limit: limit,
        platform: platform,
        token: token,
      );

      return PostsResponse.fromJson(response);
    } catch (e) {
      return PostsResponse.error(e.toString());
    }
  }

  static Future<Map<String, dynamic>> forcePost({String? token}) async {
    try {
      return await _repo.forcePost(token: token);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> scrapeProduct({
    required String productUrl,
    String? token,
  }) async {
    try {
      return await _repo.scrapeProduct(productUrl: productUrl, token: token);
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
      return await _repo.startProductCampaign(
        productUrl: productUrl,
        frequency: frequency,
        platforms: platforms,
        token: token,
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getCampaignStatus({String? token}) async {
    try {
      return await _repo.getCampaignStatus(token: token);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> stopProductCampaign({
    String? token,
  }) async {
    try {
      return await _repo.stopProductCampaign(token: token);
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
      return await _repo.getCampaignHistory(
        limit: limit,
        status: status,
        token: token,
      );
    } catch (e) {
      return {'success': false, 'error': e.toString(), 'campaigns': []};
    }
  }
}
