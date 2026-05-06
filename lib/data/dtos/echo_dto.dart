import 'package:e_team/domain/models/echo_models.dart';
import 'package:e_team/data/mappers/echo_mapper.dart';

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

  const EchoResponse({
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
      success: json['success'] == true,
      summary: json['summary']?.toString(),
      isUrgent: json['isUrgent'] == true,
      priority: json['priority']?.toString() ?? 'low',
      actions: List<String>.from(json['actions'] ?? []),
      category: json['category']?.toString(),
      transcribedText: json['transcribedText']?.toString(),
      original: json['original']?.toString(),
      error: null,
    );
  }

  factory EchoResponse.error(String message) {
    return EchoResponse(
      success: false,
      isUrgent: false,
      priority: 'low',
      actions: const [],
      error: message,
    );
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

  const EmailsResponse({
    required this.success,
    required this.total,
    required this.urgentCount,
    required this.spamCount,
    required this.unreadCount,
    required this.emails,
    this.error,
  });

  factory EmailsResponse.fromJson(Map<String, dynamic> json) {
    final list = <EmailItem>[];

    if (json['emails'] is List) {
      for (final item in json['emails']) {
        if (item is Map) {
          list.add(EchoMapper.emailFromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return EmailsResponse(
      success: json['success'] == true,
      total: json['total'] ?? 0,
      urgentCount: json['urgentCount'] ?? 0,
      spamCount: json['spamCount'] ?? 0,
      unreadCount: json['unreadCount'] ?? 0,
      emails: list,
    );
  }

  factory EmailsResponse.error(String message) {
    return EmailsResponse(
      success: false,
      total: 0,
      urgentCount: 0,
      spamCount: 0,
      unreadCount: 0,
      emails: const [],
      error: message,
    );
  }
}

class PendingResponse {
  final bool success;
  final int count;
  final List<PendingItem> pending;
  final String? error;

  const PendingResponse({
    required this.success,
    required this.count,
    required this.pending,
    this.error,
  });

  factory PendingResponse.fromJson(Map<String, dynamic> json) {
    List? raw = json['pending'] is List ? json['pending'] as List : null;
    raw ??= json['items'] is List ? json['items'] as List : null;
    raw ??= json['data'] is List ? json['data'] as List : null;

    final items = <PendingItem>[];

    if (raw != null) {
      for (final item in raw) {
        if (item is Map) {
          items.add(
            EchoMapper.pendingFromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return PendingResponse(
      success: json['success'] == true,
      count: json['count'] ?? items.length,
      pending: items,
    );
  }

  factory PendingResponse.error(String message) {
    return PendingResponse(
      success: false,
      count: 0,
      pending: const [],
      error: message,
    );
  }
}

class SpamCheckResponse {
  final bool success;
  final bool isSpam;
  final double confidence;
  final String? reason;
  final String? error;

  const SpamCheckResponse({
    required this.success,
    required this.isSpam,
    required this.confidence,
    this.reason,
    this.error,
  });

  factory SpamCheckResponse.fromJson(Map<String, dynamic> json) {
    return SpamCheckResponse(
      success: json['success'] == true,
      isSpam: json['isSpam'] == true,
      confidence: (json['confidence'] ?? 0).toDouble(),
      reason: json['reason']?.toString(),
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
}

class StatsResponse {
  final bool success;
  final int totalProcessed;
  final int spamBlocked;
  final double uptime;
  final String? error;

  const StatsResponse({
    required this.success,
    required this.totalProcessed,
    required this.spamBlocked,
    required this.uptime,
    this.error,
  });

  factory StatsResponse.fromJson(Map<String, dynamic> json) {
    int readInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    double readDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    final stats = json['stats'] is Map<String, dynamic>
        ? json['stats'] as Map<String, dynamic>
        : json;

    return StatsResponse(
      success: json['success'] == true || json['stats'] != null,
      totalProcessed: readInt(
        stats['totalProcessed'] ??
            stats['total_processed'] ??
            stats['messagesProcessed'] ??
            stats['total'],
      ),
      spamBlocked: readInt(
        stats['spamBlocked'] ?? stats['spam_blocked'] ?? stats['spamCount'],
      ),
      uptime: readDouble(stats['uptime'] ?? stats['uptimeSeconds']),
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
}

class DocumentClassificationResponse {
  final bool success;
  final DocumentClassification? classification;
  final String? error;

  const DocumentClassificationResponse({
    required this.success,
    this.classification,
    this.error,
  });

  factory DocumentClassificationResponse.fromJson(Map<String, dynamic> json) {
    return DocumentClassificationResponse(
      success: json['success'] == true,
      classification: json['classification'] is Map
          ? EchoMapper.documentClassificationFromJson(
              Map<String, dynamic>.from(json['classification']),
            )
          : null,
      error: json['error']?.toString(),
    );
  }

  factory DocumentClassificationResponse.error(String message) {
    return DocumentClassificationResponse(success: false, error: message);
  }
}

class ResponseSuggestionsResponse {
  final bool success;
  final List<ResponseSuggestion> suggestions;
  final String? error;

  const ResponseSuggestionsResponse({
    required this.success,
    required this.suggestions,
    this.error,
  });

  factory ResponseSuggestionsResponse.fromJson(Map<String, dynamic> json) {
    final list = <ResponseSuggestion>[];

    if (json['suggestions'] is List) {
      for (final item in json['suggestions']) {
        if (item is Map) {
          list.add(
            EchoMapper.responseSuggestionFromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    return ResponseSuggestionsResponse(
      success: json['success'] == true,
      suggestions: list,
      error: json['error']?.toString(),
    );
  }

  factory ResponseSuggestionsResponse.error(String message) {
    return ResponseSuggestionsResponse(
      success: false,
      suggestions: const [],
      error: message,
    );
  }
}

class PostsResponse {
  final bool success;
  final List<PostItem> posts;
  final PostsPagination pagination;
  final String? error;

  const PostsResponse({
    required this.success,
    required this.posts,
    required this.pagination,
    this.error,
  });

  factory PostsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final posts = <PostItem>[];

    if (data['posts'] is List) {
      for (final item in data['posts']) {
        if (item is Map) {
          posts.add(EchoMapper.postFromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return PostsResponse(
      success: json['success'] == true,
      posts: posts,
      pagination: data['pagination'] is Map
          ? EchoMapper.postsPaginationFromJson(
              Map<String, dynamic>.from(data['pagination']),
            )
          : PostsPagination.empty(),
      error: json['error']?.toString(),
    );
  }

  factory PostsResponse.error(String message) {
    return PostsResponse(
      success: false,
      posts: const [],
      pagination: PostsPagination.empty(),
      error: message,
    );
  }
}

class TaskExtractionResponse {
  final bool success;
  final String message;
  final List<TaskItem> tasks;
  final int totalExtracted;
  final double? confidence;
  final String? error;

  const TaskExtractionResponse({
    required this.success,
    required this.message,
    required this.tasks,
    required this.totalExtracted,
    this.confidence,
    this.error,
  });

  factory TaskExtractionResponse.fromJson(Map<String, dynamic> json) {
    final tasks = <TaskItem>[];

    if (json['tasks'] is List) {
      for (final item in json['tasks']) {
        if (item is Map) {
          tasks.add(EchoMapper.taskFromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return TaskExtractionResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      tasks: tasks,
      totalExtracted: json['totalExtracted'] ?? tasks.length,
      confidence: json['confidence']?.toDouble(),
      error: json['error']?.toString(),
    );
  }

  factory TaskExtractionResponse.error(String message) {
    return TaskExtractionResponse(
      success: false,
      message: '',
      tasks: const [],
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

  const TaskListResponse({
    required this.success,
    required this.tasks,
    required this.groupedTasks,
    required this.overdueTasks,
    required this.totalTasks,
    required this.stats,
    this.error,
  });

  factory TaskListResponse.fromJson(Map<String, dynamic> json) {
    final root = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    List<TaskItem> parseTasks(dynamic raw) {
      if (raw is! List) return [];
      return raw
          .whereType<Map>()
          .map(
            (item) => EchoMapper.taskFromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    final tasks = parseTasks(root['tasks'] ?? root['items'] ?? root['results']);
    final overdueTasks = parseTasks(
      root['overdueTasks'] ?? root['overdue_tasks'],
    );

    final groupedTasks = <String, List<TaskItem>>{};
    final rawGrouped = root['groupedTasks'] ?? root['grouped_tasks'];

    if (rawGrouped is Map) {
      rawGrouped.forEach((key, value) {
        groupedTasks[key.toString()] = parseTasks(value);
      });
    }

    return TaskListResponse(
      success:
          json['success'] == true ||
          tasks.isNotEmpty ||
          groupedTasks.isNotEmpty,
      tasks: tasks,
      groupedTasks: groupedTasks,
      overdueTasks: overdueTasks,
      totalTasks: root['totalTasks'] ?? root['total_tasks'] ?? tasks.length,
      stats: root['stats'] is Map
          ? EchoMapper.taskStatsFromJson(
              Map<String, dynamic>.from(root['stats']),
            )
          : TaskStats.empty(),
      error: root['error']?.toString() ?? json['error']?.toString(),
    );
  }

  factory TaskListResponse.error(String message) {
    return TaskListResponse(
      success: false,
      tasks: const [],
      groupedTasks: const {},
      overdueTasks: const [],
      totalTasks: 0,
      stats: TaskStats.empty(),
      error: message,
    );
  }
}
