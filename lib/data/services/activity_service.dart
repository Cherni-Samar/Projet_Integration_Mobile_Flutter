import 'dart:convert';
import 'package:http/http.dart' as http;

class ActivityService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/activities';

  /// Get mobile activity feed with pagination
  static Future<ActivityFeedResponse> getMobileFeed({
    int page = 1,
    int limit = 20,
    String? agentFilter,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (agentFilter != null && agentFilter != 'all') 'agentFilter': agentFilter,
      };
      
      final uri = Uri.parse('$baseUrl/mobile/feed').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          return ActivityFeedResponse.fromJson(jsonData['data']);
        }
      }
      
      throw Exception('Failed to load activity feed: ${response.statusCode}');
    } catch (e) {
      print('❌ Error fetching activity feed: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Get activity dashboard statistics
  static Future<ActivityDashboard> getDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mobile/dashboard'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          return ActivityDashboard.fromJson(jsonData['data']);
        }
      }
      
      throw Exception('Failed to load dashboard: ${response.statusCode}');
    } catch (e) {
      print('❌ Error fetching dashboard: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Get activities by specific agent
  static Future<List<ActivityItem>> getActivitiesByAgent(String agentName, {int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agent/$agentName?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final activities = jsonData['activities'] as List;
          return activities.map((json) => ActivityItem.fromJson(json)).toList();
        }
      }
      
      throw Exception('Failed to load agent activities: ${response.statusCode}');
    } catch (e) {
      print('❌ Error fetching agent activities: $e');
      throw Exception('Network error: $e');
    }
  }
}

// Data Models
class ActivityFeedResponse {
  final List<ActivityItem> activities;
  final ActivityPagination pagination;

  ActivityFeedResponse({
    required this.activities,
    required this.pagination,
  });

  factory ActivityFeedResponse.fromJson(Map<String, dynamic> json) {
    return ActivityFeedResponse(
      activities: (json['activities'] as List)
          .map((item) => ActivityItem.fromJson(item))
          .toList(),
      pagination: ActivityPagination.fromJson(json['pagination']),
    );
  }
}

class ActivityItem {
  final String id;
  final String sourceAgent;
  final String? targetAgent;
  final String actionType;
  final String title;
  final String description;
  final String status;
  final int energyConsumed;
  final String priority;
  final DateTime timestamp;
  final String logEntry;
  final String icon;
  final String color;

  ActivityItem({
    required this.id,
    required this.sourceAgent,
    this.targetAgent,
    required this.actionType,
    required this.title,
    required this.description,
    required this.status,
    required this.energyConsumed,
    required this.priority,
    required this.timestamp,
    required this.logEntry,
    required this.icon,
    required this.color,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'],
      sourceAgent: json['sourceAgent'],
      targetAgent: json['targetAgent'],
      actionType: json['actionType'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      energyConsumed: json['energyConsumed'],
      priority: json['priority'],
      timestamp: DateTime.parse(json['timestamp']),
      logEntry: json['logEntry'],
      icon: json['icon'],
      color: json['color'],
    );
  }
}

class ActivityPagination {
  final int currentPage;
  final int totalPages;
  final int totalActivities;
  final bool hasNext;
  final bool hasPrev;

  ActivityPagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalActivities,
    required this.hasNext,
    required this.hasPrev,
  });

  factory ActivityPagination.fromJson(Map<String, dynamic> json) {
    return ActivityPagination(
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalActivities: json['totalActivities'],
      hasNext: json['hasNext'],
      hasPrev: json['hasPrev'],
    );
  }
}

class ActivityDashboard {
  final ActivityOverview overview;
  final List<AgentActivity> byAgent;
  final List<RecentActivity> recentActivities;

  ActivityDashboard({
    required this.overview,
    required this.byAgent,
    required this.recentActivities,
  });

  factory ActivityDashboard.fromJson(Map<String, dynamic> json) {
    return ActivityDashboard(
      overview: ActivityOverview.fromJson(json['overview']),
      byAgent: (json['byAgent'] as List)
          .map((item) => AgentActivity.fromJson(item))
          .toList(),
      recentActivities: (json['recentActivities'] as List)
          .map((item) => RecentActivity.fromJson(item))
          .toList(),
    );
  }
}

class ActivityOverview {
  final int totalActivities;
  final int activitiesLast24h;
  final int successfulActivities;
  final int failedActivities;
  final int successRate;
  final int totalEnergyConsumed;

  ActivityOverview({
    required this.totalActivities,
    required this.activitiesLast24h,
    required this.successfulActivities,
    required this.failedActivities,
    required this.successRate,
    required this.totalEnergyConsumed,
  });

  factory ActivityOverview.fromJson(Map<String, dynamic> json) {
    return ActivityOverview(
      totalActivities: json['totalActivities'],
      activitiesLast24h: json['activitiesLast24h'],
      successfulActivities: json['successfulActivities'],
      failedActivities: json['failedActivities'],
      successRate: json['successRate'],
      totalEnergyConsumed: json['totalEnergyConsumed'],
    );
  }
}

class AgentActivity {
  final String agent;
  final int activities;
  final int energyConsumed;

  AgentActivity({
    required this.agent,
    required this.activities,
    required this.energyConsumed,
  });

  factory AgentActivity.fromJson(Map<String, dynamic> json) {
    return AgentActivity(
      agent: json['agent'],
      activities: json['activities'],
      energyConsumed: json['energyConsumed'],
    );
  }
}

class RecentActivity {
  final String id;
  final String logEntry;
  final String title;
  final String status;
  final DateTime timestamp;
  final int energyConsumed;

  RecentActivity({
    required this.id,
    required this.logEntry,
    required this.title,
    required this.status,
    required this.timestamp,
    required this.energyConsumed,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: json['id'],
      logEntry: json['logEntry'],
      title: json['title'],
      status: json['status'],
      timestamp: DateTime.parse(json['timestamp']),
      energyConsumed: json['energyConsumed'],
    );
  }
}