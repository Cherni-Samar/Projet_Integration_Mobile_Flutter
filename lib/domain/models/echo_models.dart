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

  const EmailItem({
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

class PostItem {
  final String id;
  final String content;
  final String fullContent;
  final DateTime createdAt;
  final PostImage? image;
  final List<PostPlatform> platforms;
  final PostStats stats;
  final bool hasProductLink;
  final String? productLinkUrl;
  final bool isForced;

  const PostItem({
    required this.id,
    required this.content,
    required this.fullContent,
    required this.createdAt,
    this.image,
    required this.platforms,
    required this.stats,
    this.hasProductLink = false,
    this.productLinkUrl,
    this.isForced = false,
  });
}

class PostImage {
  final String url;
  final String type;
  final String? source;

  const PostImage({
    required this.url,
    required this.type,
    this.source,
  });
}

class PostPlatform {
  final String name;
  final String status;
  final String icon;
  final String? url;
  final DateTime? publishedAt;

  const PostPlatform({
    required this.name,
    required this.status,
    required this.icon,
    this.url,
    this.publishedAt,
  });
}

class PostStats {
  final int likes;
  final int comments;
  final int shares;

  const PostStats({
    required this.likes,
    required this.comments,
    required this.shares,
  });

  int get totalEngagement => likes + comments + shares;
}

class DocumentClassification {
  final String category;
  final String confidentialityLevel;
  final String summary;
  final List<String> keyTopics;
  final String documentType;
  final String urgency;
  final double confidence;

  const DocumentClassification({
    required this.category,
    required this.confidentialityLevel,
    required this.summary,
    required this.keyTopics,
    required this.documentType,
    required this.urgency,
    required this.confidence,
  });

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

class PendingItem {
  final String emailId;
  final String subject;
  final String sender;
  final DateTime scheduledAt;
  final double remainingMinutes;
  final String willSendIn;

  const PendingItem({
    required this.emailId,
    required this.subject,
    required this.sender,
    required this.scheduledAt,
    required this.remainingMinutes,
    required this.willSendIn,
  });

  bool get isStillScheduled {
    if (emailId.isEmpty) return false;
    if (scheduledAt.isAfter(DateTime.now())) return true;
    return remainingMinutes > 0.25;
  }

  double get effectiveRemainingMinutes {
    if (remainingMinutes > 0) return remainingMinutes;
    final now = DateTime.now();
    if (!scheduledAt.isAfter(now)) return 0;
    return scheduledAt.difference(now).inSeconds / 60.0;
  }

  String get displayWillSendIn {
    if (!isStillScheduled) return '';
    final m = effectiveRemainingMinutes;
    if (m <= 0) return '';
    if (willSendIn.isNotEmpty) return willSendIn;
    final ceil = m.ceil();
    return ceil <= 1 ? '1 minute' : '$ceil minutes';
  }
}

class ResponseSuggestion {
  final String type;
  final String title;
  final String content;
  final String? category;

  const ResponseSuggestion({
    required this.type,
    required this.title,
    required this.content,
    this.category,
  });
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

  const TaskItem({
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

  bool get isOverdue {
    final s = status.toLowerCase();
    final completed = s.contains('complete') ||
        s.contains('termine') ||
        s == 'done' ||
        s == 'closed';

    return deadline != null &&
        deadline!.isBefore(DateTime.now()) &&
        !completed;
  }
}

class TaskExtractedFrom {
  final String? emailId;
  final String? sender;
  final String? subject;
  final DateTime extractedAt;

  const TaskExtractedFrom({
    this.emailId,
    this.sender,
    this.subject,
    required this.extractedAt,
  });
}

class TaskStats {
  final int todo;
  final int inProgress;
  final int completed;
  final int overdue;

  const TaskStats({
    required this.todo,
    required this.inProgress,
    required this.completed,
    required this.overdue,
  });

  factory TaskStats.empty() {
    return const TaskStats(
      todo: 0,
      inProgress: 0,
      completed: 0,
      overdue: 0,
    );
  }
}

class PostsPagination {
  final int currentPage;
  final int totalPages;
  final int totalPosts;
  final bool hasNext;
  final bool hasPrev;

  const PostsPagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalPosts,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PostsPagination.empty() {
    return const PostsPagination(
      currentPage: 1,
      totalPages: 1,
      totalPosts: 0,
      hasNext: false,
      hasPrev: false,
    );
  }
}