import 'api_service.dart';
import 'api_config.dart';

class EchoService {
  static String get _baseUrl => ApiConfig.baseUrl;

  static Future<EchoResponse> sendTextMessage({
    required String message,
    required String sender,
    String? token,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: '$_baseUrl/api/echo/echo',
        body: {
          'message': message,
          'sender': sender,
        },
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
    for (final rune in message.runes) {
      final char = String.fromCharCode(rune);
      if (vowels.contains(char)) {
        vowelCount++;
      } else if (consonants.contains(char)) {
        consonantCount++;
      }
    }
    if (consonantCount > 0 && vowelCount / consonantCount < 0.2) {
      return false;
    }
    return true;
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
    if (transcribedText != null) {
      text += '🎤 Message transcrit\n$transcribedText\n\n';
    }
    text += '⚠️ Urgent : ${isUrgent ? 'OUI' : 'NON'}\n';
    text += '⭐ Priorite : ${_getPriorityIcon()}\n\n';
    if (actions.isNotEmpty) {
      text += '✅ Actions a faire\n';
      for (var action in actions) {
        text += '   • $action\n';
      }
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
      scheduledAt: DateTime.tryParse(json['scheduledAt'] ?? '') ?? DateTime.now(),
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

  factory StatsResponse.fromJson(Map<String, dynamic> json) {
    return StatsResponse(
      success: json['success'] ?? false,
      totalProcessed: json['stats']?['totalProcessed'] ?? 0,
      spamBlocked: json['stats']?['spamBlocked'] ?? 0,
      uptime: (json['stats']?['uptime'] ?? 0).toDouble(),
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
