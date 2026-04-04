import 'dart:convert';
import 'package:characters/characters.dart';
import 'api_service.dart';

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
}

class EchoResponse {
  final bool success;
  final String? summary;
  final bool isUrgent;
  final String priority;
  final List<String> actions;
  final String? category;
  final String? transcribedText;
  final String? original;
  final String? error;

  EchoResponse({
    required this.success,
    this.summary,
    required this.isUrgent,
    required this.priority,
    required this.actions,
    this.category,
    this.transcribedText,
    this.original,
    this.error,
  });

  factory EchoResponse.fromJson(Map<String, dynamic> json) {
    return EchoResponse(
      success: json['success'] ?? false,
      summary: json['summary'],
      isUrgent: json['isUrgent'] ?? false,
      priority: json['priority'] ?? 'low',
      actions: List<String>.from(json['actions'] ?? []),
      category: json['category'],
      transcribedText: json['transcribedText'],
      original: json['original'],
      error: null,
    );
  }

  factory EchoResponse.error(String message) {
    return EchoResponse(
      success: false,
      isUrgent: false,
      priority: 'low',
      actions: [],
      error: message,
    );
  }

  String get formattedText {
    String text = '';
    if (summary != null) text += '📝 Resume\n$summary\n\n';
    if (transcribedText != null)
      text += '🎤 Message transcrit\n$transcribedText\n\n';
    text += '⚠️ Urgent : ${isUrgent ? 'OUI' : 'NON'}\n';
    text += '⭐ Priorite : ${_getPriorityIcon()}\n\n';
    if (actions.isNotEmpty) {
      text += '✅ Actions a faire\n';
      for (var action in actions) text += '   • $action\n';
    }
    if (category != null) text += '\n📂 Categorie : $category';
    if (error != null) text += '❌ Erreur : $error';
    return text;
  }

  String _getPriorityIcon() {
    switch (priority.toLowerCase()) {
      case 'high':
        return '🔴 HIGH';
      case 'medium':
        return '🟠 MEDIUM';
      default:
        return '🟢 LOW';
    }
  }
}

class EmailsResponse {
  final bool success;
  final int total;
  final int urgentCount;
  final int spamCount;
  final int unreadCount;
  final List<EmailItem> emails;
  final String? error;

  EmailsResponse({
    required this.success,
    required this.total,
    required this.urgentCount,
    required this.spamCount,
    required this.unreadCount,
    required this.emails,
    this.error,
  });

  factory EmailsResponse.fromJson(Map<String, dynamic> json) {
    final emailList = <EmailItem>[];
    if (json['emails'] != null) {
      for (var item in json['emails']) {
        emailList.add(EmailItem.fromJson(item));
      }
    }
    return EmailsResponse(
      success: json['success'] ?? false,
      total: json['total'] ?? 0,
      urgentCount: json['urgentCount'] ?? 0,
      spamCount: json['spamCount'] ?? 0,
      unreadCount: json['unreadCount'] ?? 0,
      emails: emailList,
      error: null,
    );
  }

  factory EmailsResponse.error(String message) {
    return EmailsResponse(
      success: false,
      total: 0,
      urgentCount: 0,
      spamCount: 0,
      unreadCount: 0,
      emails: [],
      error: message,
    );
  }
}

class PendingResponse {
  final bool success;
  final int count;
  final List<PendingItem> pending;
  final String? error;

  PendingResponse({
    required this.success,
    required this.count,
    required this.pending,
    this.error,
  });

  factory PendingResponse.fromJson(Map<String, dynamic> json) {
    final pendingList = <PendingItem>[];
    if (json['pending'] != null) {
      for (var item in json['pending']) {
        pendingList.add(PendingItem.fromJson(item));
      }
    }
    return PendingResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      pending: pendingList,
      error: null,
    );
  }

  factory PendingResponse.error(String message) {
    return PendingResponse(
      success: false,
      count: 0,
      pending: [],
      error: message,
    );
  }
}

class PendingItem {
  final String emailId;
  final String subject;
  final String sender;
  final DateTime scheduledAt;
  final double remainingMinutes;
  final String willSendIn;

  PendingItem({
    required this.emailId,
    required this.subject,
    required this.sender,
    required this.scheduledAt,
    required this.remainingMinutes,
    required this.willSendIn,
  });

  factory PendingItem.fromJson(Map<String, dynamic> json) {
    return PendingItem(
      emailId: json['emailId'] ?? '',
      subject: json['subject'] ?? '',
      sender: json['sender'] ?? '',
      scheduledAt:
          DateTime.tryParse(json['scheduledAt'] ?? '') ?? DateTime.now(),
      remainingMinutes: (json['remainingMinutes'] ?? 0).toDouble(),
      willSendIn: json['willSendIn'] ?? '',
    );
  }
}

class EmailItem {
  final String id;
  final String subject;
  final String sender;
  final String content;
  final String summary;
  final bool isUrgent;
  final bool isSpam;
  final String priority;
  final List<String> actions;
  final String category;
  final DateTime receivedAt;
  final bool isRead;

  EmailItem({
    required this.id,
    required this.subject,
    required this.sender,
    required this.content,
    required this.summary,
    required this.isUrgent,
    required this.isSpam,
    required this.priority,
    required this.actions,
    required this.category,
    required this.receivedAt,
    required this.isRead,
  });

  factory EmailItem.fromJson(Map<String, dynamic> json) {
    return EmailItem(
      id: json['id'] ?? '',
      subject: json['subject'] ?? '',
      sender: json['sender'] ?? '',
      content: json['content'] ?? '',
      summary: json['summary'] ?? '',
      isUrgent: json['isUrgent'] ?? false,
      isSpam: json['isSpam'] ?? false,
      priority: json['priority'] ?? 'low',
      actions: List<String>.from(json['actions'] ?? []),
      category: json['category'] ?? '',
      receivedAt: DateTime.tryParse(json['receivedAt'] ?? '') ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  EmailItem copyWith({
    String? id,
    String? subject,
    String? sender,
    String? content,
    String? summary,
    bool? isUrgent,
    bool? isSpam,
    String? priority,
    List<String>? actions,
    String? category,
    DateTime? receivedAt,
    bool? isRead,
  }) {
    return EmailItem(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      isUrgent: isUrgent ?? this.isUrgent,
      isSpam: isSpam ?? this.isSpam,
      priority: priority ?? this.priority,
      actions: actions ?? this.actions,
      category: category ?? this.category,
      receivedAt: receivedAt ?? this.receivedAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

class SpamCheckResponse {
  final bool success;
  final bool isSpam;
  final double confidence;
  final String? reason;
  final String? error;

  SpamCheckResponse({
    required this.success,
    required this.isSpam,
    required this.confidence,
    this.reason,
    this.error,
  });

  factory SpamCheckResponse.fromJson(Map<String, dynamic> json) {
    return SpamCheckResponse(
      success: json['success'] ?? false,
      isSpam: json['isSpam'] ?? false,
      confidence: (json['confidence'] ?? 0).toDouble(),
      reason: json['reason'],
      error: null,
    );
  }

  factory SpamCheckResponse.error(String message) {
    return SpamCheckResponse(
      success: false,
      isSpam: false,
      confidence: 0,
      error: message,
    );
  }

  String get formattedText {
    if (error != null) return '❌ Erreur: $error';
    return isSpam
        ? '⚠️ SPAM DETECTE\nConfiance: ${(confidence * 100).toInt()}%\nRaison: $reason'
        : '✅ Message legitime\nConfiance: ${(confidence * 100).toInt()}%';
  }
}

class StatsResponse {
  final bool success;
  final int totalProcessed;
  final int spamBlocked;
  final double uptime;
  final String? error;

  StatsResponse({
    required this.success,
    required this.totalProcessed,
    required this.spamBlocked,
    required this.uptime,
    this.error,
  });

  static int _readInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static int _pickInt(Map<String, dynamic>? m, List<String> keys) {
    if (m == null) return 0;
    for (final k in keys) {
      if (m.containsKey(k) && m[k] != null) return _readInt(m[k]);
    }
    return 0;
  }

  /// Accepte plusieurs formes JSON (stats imbriquées, clés à la racine, snake_case).
  factory StatsResponse.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? asMap(dynamic x) =>
        x is Map<String, dynamic> ? x : null;

    final stats = asMap(json['stats']);
    final data = asMap(json['data']);
    const totalKeys = [
      'totalProcessed',
      'total_processed',
      'messagesProcessed',
      'messages_processed',
      'processed',
      'handled',
    ];
    const spamKeys = ['spamBlocked', 'spam_blocked', 'spam', 'blockedSpam'];

    double readUptime(Map<String, dynamic>? m) {
      if (m == null) return 0;
      for (final k in ['uptime', 'uptimeSeconds', 'uptime_seconds']) {
        final v = m[k];
        if (v == null) continue;
        if (v is num) return v.toDouble();
        return double.tryParse(v.toString()) ?? 0;
      }
      return 0;
    }

    int total = _pickInt(stats, totalKeys);
    int spam = _pickInt(stats, spamKeys);
    double up = readUptime(stats);

    if (total == 0) total = _pickInt(json, totalKeys);
    if (spam == 0) spam = _pickInt(json, spamKeys);
    if (up == 0) up = readUptime(json);

    if (data != null) {
      if (total == 0) total = _pickInt(data, totalKeys);
      if (spam == 0) spam = _pickInt(data, spamKeys);
      if (up == 0) up = readUptime(data);
    }

    final explicitFailure = json['success'] == false;
    final ok =
        !explicitFailure &&
        (json['success'] == true ||
            stats != null ||
            data != null ||
            json.keys.any(
              (k) => totalKeys.contains(k) || spamKeys.contains(k),
            ));

    return StatsResponse(
      success: ok,
      totalProcessed: total,
      spamBlocked: spam,
      uptime: up,
      error: null,
    );
  }

  factory StatsResponse.error(String message) {
    return StatsResponse(
      success: false,
      totalProcessed: 0,
      spamBlocked: 0,
      uptime: 0,
      error: message,
    );
  }

  String get formattedText {
    if (error != null) return '❌ Erreur: $error';
    return '''
📊 STATISTIQUES
━━━━━━━━━━━━━━━━━━━━━
📨 Messages traites : $totalProcessed
🛡️ Spam bloques : $spamBlocked
⏱️ Uptime : ${uptime.toStringAsFixed(0)} secondes
    ''';
  }
}

class HistoryResponse {
  final bool success;
  final int count;
  final List<HistoryItem> history;
  final String? error;

  HistoryResponse({
    required this.success,
    required this.count,
    required this.history,
    this.error,
  });

  factory HistoryResponse.fromJson(Map<String, dynamic> json) {
    final historyList = <HistoryItem>[];
    if (json['history'] != null) {
      for (var item in json['history']) {
        historyList.add(HistoryItem.fromJson(item));
      }
    }
    return HistoryResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      history: historyList,
      error: null,
    );
  }

  factory HistoryResponse.error(String message) {
    return HistoryResponse(
      success: false,
      count: 0,
      history: [],
      error: message,
    );
  }
}

class HistoryItem {
  final String id;
  final String message;
  final String response;
  final String timestamp;
  final bool isSpam;

  HistoryItem({
    required this.id,
    required this.message,
    required this.response,
    required this.timestamp,
    required this.isSpam,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id']?.toString() ?? '',
      message: json['message'] ?? '',
      response: json['response'] ?? '',
      timestamp: json['timestamp'] ?? '',
      isSpam: json['isSpam'] ?? false,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 📄 DOCUMENT MANAGEMENT RESPONSE CLASSES
// ═══════════════════════════════════════════════════════════════

class DocumentClassificationResponse {
  final bool success;
  final DocumentClassification? classification;
  final String? error;

  DocumentClassificationResponse({
    required this.success,
    this.classification,
    this.error,
  });

  factory DocumentClassificationResponse.fromJson(Map<String, dynamic> json) {
    return DocumentClassificationResponse(
      success: json['success'] ?? false,
      classification: json['classification'] != null
          ? DocumentClassification.fromJson(json['classification'])
          : null,
      error: json['error'],
    );
  }

  factory DocumentClassificationResponse.error(String message) {
    return DocumentClassificationResponse(success: false, error: message);
  }
}

class DocumentClassification {
  final String category;
  final String confidentialityLevel;
  final String summary;
  final List<String> keyTopics;
  final String documentType;
  final String urgency;
  final double confidence;

  DocumentClassification({
    required this.category,
    required this.confidentialityLevel,
    required this.summary,
    required this.keyTopics,
    required this.documentType,
    required this.urgency,
    required this.confidence,
  });

  factory DocumentClassification.fromJson(Map<String, dynamic> json) {
    return DocumentClassification(
      category: json['category'] ?? '',
      confidentialityLevel: json['confidentialityLevel'] ?? '',
      summary: json['summary'] ?? '',
      keyTopics: List<String>.from(json['keyTopics'] ?? []),
      documentType: json['documentType'] ?? '',
      urgency: json['urgency'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'confidentialityLevel': confidentialityLevel,
      'summary': summary,
      'keyTopics': keyTopics,
      'documentType': documentType,
      'urgency': urgency,
      'confidence': confidence,
    };
  }
}

class DocumentListResponse {
  final bool success;
  final List<DocumentItem> documents;
  final String? error;

  DocumentListResponse({
    required this.success,
    required this.documents,
    this.error,
  });

  factory DocumentListResponse.fromJson(Map<String, dynamic> json) {
    final documentList = <DocumentItem>[];
    if (json['documents'] != null) {
      for (var item in json['documents']) {
        documentList.add(DocumentItem.fromJson(item));
      }
    }
    return DocumentListResponse(
      success: json['success'] ?? false,
      documents: documentList,
      error: json['error'],
    );
  }

  factory DocumentListResponse.error(String message) {
    return DocumentListResponse(success: false, documents: [], error: message);
  }
}

class DocumentItem {
  final String id;
  final String name;
  final String category;
  final String confidentialityLevel;
  final String summary;
  final List<String> keyTopics;
  final String documentType;
  final String urgency;
  final DateTime createdAt;
  final int size;

  DocumentItem({
    required this.id,
    required this.name,
    required this.category,
    required this.confidentialityLevel,
    required this.summary,
    required this.keyTopics,
    required this.documentType,
    required this.urgency,
    required this.createdAt,
    required this.size,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      confidentialityLevel: json['confidentialityLevel'] ?? '',
      summary: json['summary'] ?? '',
      keyTopics: List<String>.from(json['keyTopics'] ?? []),
      documentType: json['documentType'] ?? '',
      urgency: json['urgency'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      size: json['size'] ?? 0,
    );
  }
}

class DocumentContentResponse {
  final bool success;
  final DocumentContent? document;
  final String? error;

  DocumentContentResponse({required this.success, this.document, this.error});

  factory DocumentContentResponse.fromJson(Map<String, dynamic> json) {
    return DocumentContentResponse(
      success: json['success'] ?? false,
      document: json['document'] != null
          ? DocumentContent.fromJson(json['document'])
          : null,
      error: json['error'],
    );
  }

  factory DocumentContentResponse.error(String message) {
    return DocumentContentResponse(success: false, error: message);
  }
}

class DocumentContent {
  final String id;
  final String name;
  final String content;
  final String category;
  final String confidentialityLevel;
  final String summary;
  final List<String> keyTopics;
  final String documentType;
  final String urgency;
  final DateTime createdAt;
  final int size;
  final Map<String, dynamic>? metadata;

  DocumentContent({
    required this.id,
    required this.name,
    required this.content,
    required this.category,
    required this.confidentialityLevel,
    required this.summary,
    required this.keyTopics,
    required this.documentType,
    required this.urgency,
    required this.createdAt,
    required this.size,
    this.metadata,
  });

  factory DocumentContent.fromJson(Map<String, dynamic> json) {
    return DocumentContent(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? '',
      confidentialityLevel: json['confidentialityLevel'] ?? '',
      summary: json['summary'] ?? '',
      keyTopics: List<String>.from(json['keyTopics'] ?? []),
      documentType: json['documentType'] ?? '',
      urgency: json['urgency'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      size: json['size'] ?? 0,
      metadata: json['metadata'],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 💡 RESPONSE SUGGESTIONS CLASSES
// ═══════════════════════════════════════════════════════════════

class ResponseSuggestionsResponse {
  final bool success;
  final List<ResponseSuggestion> suggestions;
  final String? error;

  ResponseSuggestionsResponse({
    required this.success,
    required this.suggestions,
    this.error,
  });

  factory ResponseSuggestionsResponse.fromJson(Map<String, dynamic> json) {
    return ResponseSuggestionsResponse(
      success: json['success'] ?? false,
      suggestions: json['suggestions'] != null
          ? (json['suggestions'] as List)
                .map((item) => ResponseSuggestion.fromJson(item))
                .toList()
          : [],
      error: json['error'],
    );
  }

  factory ResponseSuggestionsResponse.error(String message) {
    return ResponseSuggestionsResponse(
      success: false,
      suggestions: [],
      error: message,
    );
  }
}

class ResponseSuggestion {
  final String type;
  final String title;
  final String content;

  /// Catégorie métier (ex: congés, recrutement) si fournie par l’API.
  final String? category;

  ResponseSuggestion({
    required this.type,
    required this.title,
    required this.content,
    this.category,
  });

  factory ResponseSuggestion.fromJson(Map<String, dynamic> json) {
    return ResponseSuggestion(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category:
          json['category'] as String? ?? json['messageCategory'] as String?,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 📋 TASK MANAGEMENT CLASSES
// ═══════════════════════════════════════════════════════════════

class TaskExtractionResponse {
  final bool success;
  final String message;
  final List<TaskItem> tasks;
  final int totalExtracted;
  final double? confidence;
  final String? error;

  TaskExtractionResponse({
    required this.success,
    required this.message,
    required this.tasks,
    required this.totalExtracted,
    this.confidence,
    this.error,
  });

  factory TaskExtractionResponse.fromJson(Map<String, dynamic> json) {
    return TaskExtractionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      tasks: json['tasks'] != null
          ? (json['tasks'] as List)
                .map((item) => TaskItem.fromJson(item))
                .toList()
          : [],
      totalExtracted: json['totalExtracted'] ?? 0,
      confidence: json['confidence']?.toDouble(),
      error: json['error'],
    );
  }

  factory TaskExtractionResponse.error(String message) {
    return TaskExtractionResponse(
      success: false,
      message: '',
      tasks: [],
      totalExtracted: 0,
      error: message,
    );
  }
}

class TaskListResponse {
  final bool success;
  final List<TaskItem> tasks;
  final Map<String, List<TaskItem>> groupedTasks;
  final List<TaskItem> overdueTasks;
  final int totalTasks;
  final TaskStats stats;
  final String? error;

  TaskListResponse({
    required this.success,
    required this.tasks,
    required this.groupedTasks,
    required this.overdueTasks,
    required this.totalTasks,
    required this.stats,
    this.error,
  });

  factory TaskListResponse.fromJson(Map<String, dynamic> json) {
    Map<String, List<TaskItem>> grouped = {};
    if (json['groupedTasks'] != null) {
      (json['groupedTasks'] as Map<String, dynamic>).forEach((key, value) {
        grouped[key] = (value as List)
            .map((item) => TaskItem.fromJson(item))
            .toList();
      });
    }

    return TaskListResponse(
      success: json['success'] ?? false,
      tasks: json['tasks'] != null
          ? (json['tasks'] as List)
                .map((item) => TaskItem.fromJson(item))
                .toList()
          : [],
      groupedTasks: grouped,
      overdueTasks: json['overdueTasks'] != null
          ? (json['overdueTasks'] as List)
                .map((item) => TaskItem.fromJson(item))
                .toList()
          : [],
      totalTasks: json['totalTasks'] ?? 0,
      stats: TaskStats.fromJson(json['stats'] ?? {}),
      error: json['error'],
    );
  }

  factory TaskListResponse.error(String message) {
    return TaskListResponse(
      success: false,
      tasks: [],
      groupedTasks: {},
      overdueTasks: [],
      totalTasks: 0,
      stats: TaskStats.empty(),
      error: message,
    );
  }
}

class TaskItem {
  final String id;
  final String title;
  final String description;
  final String? assignee;
  final DateTime? deadline;
  final String category;
  final String priority;
  final String status;
  final double confidence;
  final TaskExtractedFrom? extractedFrom;
  final String? notes;
  final DateTime createdAt;
  final DateTime? completedAt;

  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    this.assignee,
    this.deadline,
    required this.category,
    required this.priority,
    required this.status,
    required this.confidence,
    this.extractedFrom,
    this.notes,
    required this.createdAt,
    this.completedAt,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      assignee: json['assignee'],
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'])
          : null,
      category: json['category'] ?? 'other',
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'todo',
      confidence: (json['confidence'] ?? 0.5).toDouble(),
      extractedFrom: json['extractedFrom'] != null
          ? TaskExtractedFrom.fromJson(json['extractedFrom'])
          : null,
      notes: json['notes'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'])
          : null,
    );
  }

  bool get isOverdue {
    return deadline != null &&
        deadline!.isBefore(DateTime.now()) &&
        status != 'completed';
  }
}

class TaskExtractedFrom {
  final String? emailId;
  final String? sender;
  final String? subject;
  final DateTime extractedAt;

  TaskExtractedFrom({
    this.emailId,
    this.sender,
    this.subject,
    required this.extractedAt,
  });

  factory TaskExtractedFrom.fromJson(Map<String, dynamic> json) {
    return TaskExtractedFrom(
      emailId: json['emailId'],
      sender: json['sender'],
      subject: json['subject'],
      extractedAt:
          DateTime.tryParse(json['extractedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class TaskStats {
  final int todo;
  final int inProgress;
  final int completed;
  final int overdue;

  TaskStats({
    required this.todo,
    required this.inProgress,
    required this.completed,
    required this.overdue,
  });

  factory TaskStats.fromJson(Map<String, dynamic> json) {
    return TaskStats(
      todo: json['todo'] ?? 0,
      inProgress: json['in_progress'] ?? 0,
      completed: json['completed'] ?? 0,
      overdue: json['overdue'] ?? 0,
    );
  }

  factory TaskStats.empty() {
    return TaskStats(todo: 0, inProgress: 0, completed: 0, overdue: 0);
  }
}
