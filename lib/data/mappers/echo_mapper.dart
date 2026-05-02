import 'package:e_team/domain/models/echo_models.dart';

class EchoMapper {
  static String _str(dynamic value) => value == null ? '' : value.toString();

  static int _int(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _double(dynamic value, {double fallback = 0}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  static bool _bool(dynamic value) {
    return value == true || value == 1 || value == 'true';
  }

  static EmailItem emailFromJson(Map<String, dynamic> json) {
    return EmailItem(
      id: _str(json['id'] ?? json['_id']),
      subject: _str(json['subject']),
      sender: _str(json['sender'] ?? json['from']),
      content: _str(json['content'] ?? json['body']),
      summary: _str(json['summary']),
      isUrgent: _bool(json['isUrgent']),
      isSpam: _bool(json['isSpam']) ||
          _bool(json['is_spam']) ||
          _str(json['category']).toLowerCase() == 'spam',
      priority: _str(json['priority']).isEmpty ? 'low' : _str(json['priority']),
      actions: List<String>.from(json['actions'] ?? []),
      category: _str(json['category']),
      receivedAt: DateTime.tryParse(_str(json['receivedAt'])) ?? DateTime.now(),
      isRead: _bool(json['isRead']),
    );
  }

  static PendingItem pendingFromJson(Map<String, dynamic> json) {
    final scheduledAt = DateTime.tryParse(
      _str(json['scheduledAt'] ?? json['scheduled_at']),
    ) ??
        DateTime.tryParse(_str(json['sendAt'] ?? json['send_at'])) ??
        DateTime.now();

    final remainingRaw = json['remainingMinutes'] ?? json['remaining_minutes'];
    double remainingMinutes =
    remainingRaw == null ? 0 : _double(remainingRaw);

    String willSendIn = _str(
      json['willSendIn'] ?? json['will_send_in'] ?? json['timeRemaining'],
    );

    final now = DateTime.now();
    if (remainingMinutes <= 0 && scheduledAt.isAfter(now)) {
      remainingMinutes = scheduledAt.difference(now).inSeconds / 60.0;
    }

    if (willSendIn.isEmpty && remainingMinutes > 0) {
      final mins = remainingMinutes.ceil().clamp(1, 9999);
      willSendIn = mins <= 1 ? '1 minute' : '$mins minutes';
    }

    return PendingItem(
      emailId: _str(json['emailId'] ?? json['email_id'] ?? json['id'] ?? json['_id']),
      subject: _str(json['subject']),
      sender: _str(
        json['sender'] ?? json['from'] ?? json['senderEmail'] ?? json['fromEmail'],
      ),
      scheduledAt: scheduledAt,
      remainingMinutes: remainingMinutes,
      willSendIn: willSendIn,
    );
  }

  static PostItem postFromJson(Map<String, dynamic> json) {
    final platforms = <PostPlatform>[];

    if (json['platforms'] is List) {
      platforms.addAll(
        (json['platforms'] as List)
            .whereType<Map>()
            .map((item) => postPlatformFromJson(Map<String, dynamic>.from(item))),
      );
    }

    return PostItem(
      id: _str(json['id'] ?? json['_id']),
      content: _str(json['content']),
      fullContent: _str(json['fullContent'] ?? json['content']),
      createdAt: DateTime.tryParse(_str(json['createdAt'])) ?? DateTime.now(),
      image: json['image'] is Map
          ? postImageFromJson(Map<String, dynamic>.from(json['image']))
          : null,
      platforms: platforms,
      stats: postStatsFromJson(
        json['stats'] is Map ? Map<String, dynamic>.from(json['stats']) : {},
      ),
      hasProductLink: _bool(json['hasProductLink']),
      productLinkUrl: json['productLinkUrl']?.toString(),
      isForced: _bool(json['isForced']),
    );
  }

  static PostImage postImageFromJson(Map<String, dynamic> json) {
    return PostImage(
      url: _str(json['url']),
      type: _str(json['type']).isEmpty ? 'none' : _str(json['type']),
      source: json['source']?.toString(),
    );
  }

  static PostPlatform postPlatformFromJson(Map<String, dynamic> json) {
    final name = _str(json['name']);

    return PostPlatform(
      name: name,
      status: _str(json['status']),
      url: json['url']?.toString(),
      publishedAt: DateTime.tryParse(_str(json['publishedAt'])),
      icon: _str(json['icon']).isNotEmpty
          ? _str(json['icon'])
          : name == 'linkedin'
          ? '💼'
          : '🐘',
    );
  }

  static PostStats postStatsFromJson(Map<String, dynamic> json) {
    return PostStats(
      likes: _int(json['likes']),
      comments: _int(json['comments']),
      shares: _int(json['shares']),
    );
  }

  static DocumentClassification documentClassificationFromJson(
      Map<String, dynamic> json,
      ) {
    return DocumentClassification(
      category: _str(json['category']),
      confidentialityLevel: _str(json['confidentialityLevel']),
      summary: _str(json['summary']),
      keyTopics: List<String>.from(json['keyTopics'] ?? []),
      documentType: _str(json['documentType']),
      urgency: _str(json['urgency']),
      confidence: _double(json['confidence']),
    );
  }

  static ResponseSuggestion responseSuggestionFromJson(
      Map<String, dynamic> json,
      ) {
    return ResponseSuggestion(
      type: _str(json['type']),
      title: _str(json['title']),
      content: _str(json['content']),
      category: json['category']?.toString() ?? json['messageCategory']?.toString(),
    );
  }

  static TaskItem taskFromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: _str(json['_id'] ?? json['id']),
      title: _str(json['title'] ?? json['name'] ?? json['taskTitle']),
      description: _str(json['description'] ?? json['details']),
      assignee: json['assignee']?.toString(),
      deadline: DateTime.tryParse(_str(json['deadline'])),
      category: _str(json['category']).isEmpty ? 'other' : _str(json['category']),
      priority: _str(json['priority']).isEmpty ? 'medium' : _str(json['priority']),
      status: _str(json['status'] ?? json['state'] ?? json['taskStatus']).isEmpty
          ? 'todo'
          : _str(json['status'] ?? json['state'] ?? json['taskStatus']),
      confidence: _double(json['confidence'], fallback: 0.5),
      extractedFrom: json['extractedFrom'] is Map
          ? taskExtractedFromJson(
        Map<String, dynamic>.from(json['extractedFrom']),
      )
          : null,
      notes: json['notes']?.toString(),
      createdAt: DateTime.tryParse(_str(json['createdAt'] ?? json['created_at'])) ??
          DateTime.now(),
      completedAt: DateTime.tryParse(
        _str(json['completedAt'] ?? json['completed_at']),
      ),
    );
  }

  static TaskExtractedFrom taskExtractedFromJson(Map<String, dynamic> json) {
    return TaskExtractedFrom(
      emailId: json['emailId']?.toString(),
      sender: json['sender']?.toString(),
      subject: json['subject']?.toString(),
      extractedAt: DateTime.tryParse(_str(json['extractedAt'])) ?? DateTime.now(),
    );
  }

  static TaskStats taskStatsFromJson(Map<String, dynamic> json) {
    return TaskStats(
      todo: _int(json['todo'] ?? json['to_do']),
      inProgress: _int(json['in_progress'] ?? json['inProgress']),
      completed: _int(json['completed']),
      overdue: _int(json['overdue']),
    );
  }

  static PostsPagination postsPaginationFromJson(Map<String, dynamic> json) {
    return PostsPagination(
      currentPage: _int(json['currentPage'] ?? 1),
      totalPages: _int(json['totalPages'] ?? 1),
      totalPosts: _int(json['totalPosts']),
      hasNext: _bool(json['hasNext']),
      hasPrev: _bool(json['hasPrev']),
    );
  }
}