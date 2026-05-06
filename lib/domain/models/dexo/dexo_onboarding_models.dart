// ─── Chat message types ───────────────────────────────────────────────────────

enum ChatMessageType { bot, user, blueprint }

class ChatMessage {
  final ChatMessageType type;
  final String text;
  final WorkforcePlan? blueprintPlan;

  const ChatMessage._({required this.type, this.text = '', this.blueprintPlan});

  factory ChatMessage.bot(String text) {
    return ChatMessage._(type: ChatMessageType.bot, text: text);
  }

  factory ChatMessage.user(String text) {
    return ChatMessage._(type: ChatMessageType.user, text: text);
  }

  factory ChatMessage.blueprint(WorkforcePlan plan) {
    return ChatMessage._(type: ChatMessageType.blueprint, blueprintPlan: plan);
  }
}

// ─── Strategic advice API response ───────────────────────────────────────────

class StrategicAdviceResult {
  final bool isFinished;
  final String? nextQuestion;
  final WorkforcePlan plan;

  StrategicAdviceResult({
    required this.isFinished,
    required this.nextQuestion,
    required this.plan,
  });

  factory StrategicAdviceResult.fromJson(Map<String, dynamic> json) {
    return StrategicAdviceResult(
      isFinished: json['isFinished'] == true,
      nextQuestion: json['nextQuestion']?.toString(),
      plan: WorkforcePlan.fromJson(json),
    );
  }
}

// ─── Workforce planning models ────────────────────────────────────────────────

class WorkforceDepartment {
  String name;
  int targetCount;
  final String reason;

  WorkforceDepartment({
    required this.name,
    required this.targetCount,
    required this.reason,
  });

  factory WorkforceDepartment.fromJson(Map<String, dynamic> json) {
    return WorkforceDepartment(
      name:
          json['name']?.toString() ??
          json['department']?.toString() ??
          'Department',
      targetCount: WorkforcePlan._toInt(
        json['targetCount'] ?? json['count'] ?? json['employees'],
        1,
      ),
      reason: json['reason']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'department': name,
      'targetCount': targetCount,
      'currentCount': 0,
      'reason': reason,
    };
  }
}

class WorkforcePlan {
  List<WorkforceDepartment> departments;
  String explanation;
  List<RecommendedAgent> recommendedAgents;

  WorkforcePlan({
    required this.departments,
    required this.explanation,
    required this.recommendedAgents,
  });

  factory WorkforcePlan.fromJson(Map<String, dynamic> json) {
    final proposal = json['proposal'] is Map
        ? Map<String, dynamic>.from(json['proposal'])
        : json;

    final departmentsRaw = proposal['departments'] ?? json['departments'] ?? [];

    List<WorkforceDepartment> parsedDepartments = [];

    if (departmentsRaw is List) {
      parsedDepartments = departmentsRaw
          .whereType<Map>()
          .map(
            (e) => WorkforceDepartment.fromJson(Map<String, dynamic>.from(e)),
          )
          .where((d) => d.name.trim().isNotEmpty)
          .toList();
    }

    if (parsedDepartments.isEmpty) {
      parsedDepartments = [
        WorkforceDepartment(
          name: 'Operations',
          targetCount: 2,
          reason: 'Manage daily company operations.',
        ),
        WorkforceDepartment(
          name: 'Marketing',
          targetCount: 2,
          reason: 'Acquire customers and grow the brand.',
        ),
        WorkforceDepartment(
          name: 'Administration',
          targetCount: 1,
          reason: 'Coordinate internal organization.',
        ),
      ];
    }

    final agentsRaw =
        json['recommendedAgents'] ?? proposal['recommendedAgents'] ?? [];

    return WorkforcePlan(
      departments: parsedDepartments,
      explanation:
          proposal['explanation']?.toString() ??
          'Dexo generated this organization structure from your company vision.',
      recommendedAgents: (agentsRaw as List? ?? [])
          .whereType<Map>()
          .map((e) => RecommendedAgent.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  List<Map<String, dynamic>> toApiList() {
    return departments.map((d) => d.toJson()).toList();
  }

  static int _toInt(dynamic value, int fallback) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }
}

// ─── Recommended agent ────────────────────────────────────────────────────────

class RecommendedAgent {
  final String id;
  final String name;
  final String reason;

  RecommendedAgent({
    required this.id,
    required this.name,
    required this.reason,
  });

  factory RecommendedAgent.fromJson(Map<String, dynamic> json) {
    return RecommendedAgent(
      id: json['id']?.toString().toLowerCase() ?? '',
      name: json['name']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'reason': reason};
  }
}
