import 'dart:convert';
import 'package:characters/characters.dart';
import 'api_service.dart';
export '../models/echo_models.dart';

class EchoService {
  static const String _baseUrl = 'http://10.0.2.2:3000';

  static Future<EchoResponse> sendTextMessage({
    required String message,
    required String sender,
    String? token,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: '$_baseUrl/api/echo/echo',
        body: {'message': message, 'sender': sender},
        token: token,
      );
      return EchoResponse.fromJson(response);
    } catch (e) {
      print('❌ EchoService - sendTextMessage error: $e');
      return EchoResponse.error(e.toString());
    }
  }
// À ajouter dans la classe EchoService
  static Future<Map<String, dynamic>> getSocialFeed({String? token}) async {
    try {
      final response = await ApiService.get(
        endpoint: '$_baseUrl/api/echo/social-feed',
        token: token,
      );
      // On retourne le Map complet qui contient {success: true, feed: [...]}
      return response;
    } catch (e) {
      print('❌ EchoService - getSocialFeed error: $e');
      return {'success': false, 'feed': [], 'error': e.toString()};
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
      print('❌ EchoService - getEmails error: $e');
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
      print('❌ EchoService - getPending error: $e');
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
      return response['success'] ?? false;
    } catch (e) {
      print('❌ EchoService - markAsRead error: $e');
      return false;
    }
  }

  static Future<bool> deleteEmail(String emailId, {String? token}) async {
    try {
      final response = await ApiService.delete(
        endpoint: '$_baseUrl/api/emails/$emailId',
        token: token,
      );
      return response['success'] ?? false;
    } catch (e) {
      print('❌ EchoService - deleteEmail error: $e');
      return false;
    }
  }

  /// Réponses API considérées comme succès (selon implémentation backend).
  /// Transforme JSON / analyse en **texte de courriel** (réponse), pas en fiche résumé.
  static String humanReadableAutoReplyBody(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return t;
    if (!t.startsWith('{') && !t.startsWith('[')) return raw;

    Map<String, dynamic>? map;
    try {
      final decoded = jsonDecode(t);
      if (decoded is Map<String, dynamic>) map = decoded;
    } catch (_) {
      try {
        final normalized = t.replaceAll("'", '"');
        final decoded = jsonDecode(normalized);
        if (decoded is Map<String, dynamic>) map = decoded;
      } catch (_) {}
    }
    if (map == null) {
      final g1 = RegExp(r"summary\s*:\s*'([^']*)'").firstMatch(t)?.group(1);
      if (g1 != null && g1.trim().isNotEmpty) {
        return _composeAutoReplyFromAnalysis({'summary': g1.trim()});
      }
      final g2 = RegExp(r'summary\s*:\s*"([^"]*)"').firstMatch(t)?.group(1);
      if (g2 != null && g2.trim().isNotEmpty) {
        return _composeAutoReplyFromAnalysis({'summary': g2.trim()});
      }
      return raw;
    }

    final direct = map['reply'] ??
        map['replyText'] ??
        map['replyContent'] ??
        map['generatedReply'] ??
        map['emailBody'] ??
        map['body'] ??
        map['message'] ??
        map['text'];
    if (direct != null && direct.toString().trim().isNotEmpty) {
      return direct.toString().trim();
    }

    return _composeAutoReplyFromAnalysis(map);
  }

  /// Construit un paragraphe de réponse type e-mail à partir des champs d’analyse.
  static String _composeAutoReplyFromAnalysis(Map<String, dynamic> map) {
    final summary = map['summary']?.toString().trim() ?? '';
    final actions = map['actions'];
    final urgent = map['isUrgent'] == true || map['isUrgent'] == 1;
    final priority = map['priority']?.toString().toLowerCase() ?? '';

    final buf = StringBuffer();
    buf.writeln('Bonjour,');
    buf.writeln();

    if (summary.isNotEmpty) {
      var line = summary.trimRight();
      final endsWell = line.endsWith('.') ||
          line.endsWith('!') ||
          line.endsWith('?') ||
          line.endsWith('…');
      if (!endsWell) line = '$line.';
      buf.writeln(line);
      buf.writeln();
    }

    if (actions is List && actions.isNotEmpty) {
      buf.writeln(
        'Pour la suite, nous vous confirmons la prise en charge des points suivants :',
      );
      for (final a in actions) {
        final s = a.toString().trim();
        if (s.isNotEmpty) buf.writeln('• $s');
      }
      buf.writeln();
    }

    if (urgent || priority == 'high') {
      buf.writeln(
        'Nous traitons votre demande en priorité et vous tiendrons informé(e) dans les meilleurs délais.',
      );
      buf.writeln();
    } else {
      buf.writeln(
        'Nous restons à votre disposition pour toute précision.',
      );
      buf.writeln();
    }

    final out = buf.toString().trim();
    if (out.isEmpty) return map.toString();
    return out;
  }

  static bool replySucceeded(Map<String, dynamic> response) {
    final s = response['success'];
    if (s == true || s == 1 || s == 'true') return true;
    if (response['ok'] == true || response['saved'] == true) return true;
    if (response['status'] == 'ok' || response['status'] == 'success')
      return true;
    return false;
  }

  static Future<Map<String, dynamic>> replyToEmail({
    required String emailId,
    required String replyContent,
    String? token,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: '$_baseUrl/api/emails/$emailId/reply',
        body: {'replyContent': replyContent},
        token: token,
      );
      return response;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
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
      print('❌ EchoService - getResponseSuggestions error: $e');
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
      final response = await ApiService.post(
        endpoint: '$_baseUrl/api/echo/send-to-hera',
        body: {
          'subject': subject,
          'content': content,
          'from': from ?? 'echo@e-team.com',
        },
        token: token,
      );
      return response;
    } catch (e) {
      print('❌ EchoService - sendEmailToHera error: $e');
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
      print('❌ EchoService - checkSpam error: $e');
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
      print('❌ EchoService - getStats error: $e');
      return StatsResponse.error(e.toString());
    }
  }

  static bool isMeaningfulMessage(String message) {
    if (message.length < 5) return false;
    final vowels = 'aeiouyAEIOUY';
    final consonants = 'bcdfghjklmnpqrstvwxzBCDFGHJKLMNPQRSTVWXZ';
    int vowelCount = 0;
    int consonantCount = 0;
    for (var char in message.characters) {
      if (vowels.contains(char))
        vowelCount++;
      else if (consonants.contains(char))
        consonantCount++;
    }
    if (consonantCount > 0 && vowelCount / consonantCount < 0.2) {
      return false;
    }
    return true;
  }

  // ═══════════════════════════════════════════════════════════════
  // 📄 DOCUMENT MANAGEMENT METHODS
  // ═══════════════════════════════════════════════════════════════

  static Future<DocumentClassificationResponse> classifyDocument({
    required String content,
    String? token,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: '$_baseUrl/api/echo/classify-document',
        body: {'content': content},
        token: token,
      );
      return DocumentClassificationResponse.fromJson(response);
    } catch (e) {
      print('❌ EchoService - classifyDocument error: $e');
      return DocumentClassificationResponse.error(e.toString());
    }
  }

  static Future<Map<String, dynamic>> saveClassifiedDocument({
    required String content,
    required Map<String, dynamic> classification,
    String? token,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: '$_baseUrl/api/echo/save-document',
        body: {'content': content, 'classification': classification},
        token: token,
      );
      return response;
    } catch (e) {
      print('❌ EchoService - saveClassifiedDocument error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<DocumentListResponse> getDocumentsByCategory({
    required String category,
    String? confidentialityLevel,
    String? token,
  }) async {
    try {
      String endpoint = '$_baseUrl/api/echo/documents/$category';
      if (confidentialityLevel != null) {
        endpoint += '?confidentialityLevel=$confidentialityLevel';
      }

      final response = await ApiService.get(endpoint: endpoint, token: token);
      return DocumentListResponse.fromJson(response);
    } catch (e) {
      print('❌ EchoService - getDocumentsByCategory error: $e');
      return DocumentListResponse.error(e.toString());
    }
  }

  static Future<DocumentContentResponse> getDocumentContent({
    required String documentId,
    String? token,
  }) async {
    try {
      final response = await ApiService.get(
        endpoint: '$_baseUrl/api/echo/document-content/$documentId',
        token: token,
      );
      return DocumentContentResponse.fromJson(response);
    } catch (e) {
      print('❌ EchoService - getDocumentContent error: $e');
      return DocumentContentResponse.error(e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 📋 TASK MANAGEMENT METHODS
  // ═══════════════════════════════════════════════════════════════

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
      print('❌ EchoService - extractAndSaveTasks error: $e');
      return TaskExtractionResponse.error(e.toString());
    }
  }

  static Future<TaskListResponse> getTasks({
    String? status,
    String? category,
    String? token,
  }) async {
    try {
      Map<String, String> queryParams = {};
      if (status != null) queryParams['status'] = status;
      if (category != null) queryParams['category'] = category;

      String endpoint = '$_baseUrl/api/echo/tasks';
      if (queryParams.isNotEmpty) {
        endpoint +=
            '?' +
                queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
      }

      final response = await ApiService.get(endpoint: endpoint, token: token);
      return TaskListResponse.fromJson(response);
    } catch (e) {
      print('❌ EchoService - getTasks error: $e');
      return TaskListResponse.error(e.toString());
    }
  }

  static Future<Map<String, dynamic>> updateTaskStatus({
    required String taskId,
    required String status,
    String? token,
  }) async {
    try {
      final response = await ApiService.patch(
        endpoint: '$_baseUrl/api/echo/tasks/$taskId/status',
        body: {'status': status},
        token: token,
      );
      return response;
    } catch (e) {
      print('❌ EchoService - updateTaskStatus error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteTask({
    required String taskId,
    String? token,
  }) async {
    try {
      final response = await ApiService.delete(
        endpoint: '$_baseUrl/api/echo/tasks/$taskId',
        token: token,
      );
      return response;
    } catch (e) {
      print('❌ EchoService - deleteTask error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🛍️ PRODUCT MARKETING METHODS
  // ═══════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> scrapeProduct({
    required String productUrl,
    String? token,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: '$_baseUrl/api/echo/product/scrape',
        body: {'productUrl': productUrl},
        token: token,
      );
      return response;
    } catch (e) {
      print('❌ EchoService - scrapeProduct error: $e');
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
      final response = await ApiService.post(
        endpoint: '$_baseUrl/api/echo/product/campaign/start',
        body: {
          'productUrl': productUrl,
          'frequency': frequency,
          'platforms': platforms,
        },
        token: token,
      );
      return response;
    } catch (e) {
      print('❌ EchoService - startProductCampaign error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getCampaignHistory({
    int limit = 50,
    int offset = 0,
    String? token,
  }) async {
    try {
      final response = await ApiService.get(
        endpoint: '$_baseUrl/api/echo/product/campaigns?limit=$limit&offset=$offset',
        token: token,
      );
      return response;
    } catch (e) {
      print('❌ EchoService - getCampaignHistory error: $e');
      return {'success': false, 'campaigns': [], 'error': e.toString()};
    }
  }
}

