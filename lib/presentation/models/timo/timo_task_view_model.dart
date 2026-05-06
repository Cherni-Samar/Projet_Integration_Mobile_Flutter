import 'package:flutter/material.dart';

import 'package:e_team/presentation/widgets/timo/timo_design_system.dart';

enum TaskType { interview, onboarding, offboarding, other }

class TimoTask {
  final String raw;
  final String employeeName;
  final TaskType type;
  final String status;
  final DateTime? deadline;
  final String id;

  TimoTask({
    required this.raw,
    required this.employeeName,
    required this.type,
    required this.status,
    required this.deadline,
    required this.id,
  });

  factory TimoTask.fromMap(Map<String, dynamic> m) {
    final title = m['title'] as String? ?? '';
    final status = m['status'] as String? ?? 'todo';
    final id = m['_id']?.toString() ?? '';

    DateTime? deadline;
    try {
      deadline = DateTime.parse(m['deadline']);
    } catch (_) {}

    TaskType type = TaskType.other;
    String employeeName = title;

    final lowerTitle = title.toLowerCase();

    if (lowerTitle.contains('démission') ||
        lowerTitle.contains('départ') ||
        lowerTitle.contains('offboarding')) {
      type = TaskType.offboarding;
    } else if (lowerTitle.contains('intégration') ||
        lowerTitle.contains('onboarding')) {
      type = TaskType.onboarding;
    } else if (lowerTitle.contains('entretien') ||
        lowerTitle.contains('interview')) {
      type = TaskType.interview;
    }

    if (title.contains(':')) {
      final parts = title.split(':');
      if (parts.length > 1) {
        employeeName = parts[1].trim();
      }
    }

    return TimoTask(
      raw: title,
      employeeName: employeeName,
      type: type,
      status: status,
      deadline: deadline,
      id: id,
    );
  }

  bool get isDone => status == 'done';

  IconData get icon => switch (type) {
    TaskType.interview => Icons.record_voice_over_rounded,
    TaskType.onboarding => Icons.person_add_alt_1_rounded,
    TaskType.offboarding => Icons.exit_to_app_rounded,
    TaskType.other => Icons.event_rounded,
  };

  Color get color => switch (type) {
    TaskType.interview => TimoDesignSystem.interview,
    TaskType.onboarding => TimoDesignSystem.onboarding,
    TaskType.offboarding => TimoDesignSystem.offboarding,
    TaskType.other => TimoDesignSystem.other,
  };

  String get typeLabel => switch (type) {
    TaskType.interview => 'INTERVIEW',
    TaskType.onboarding => 'ONBOARDING',
    TaskType.offboarding => 'OFFBOARDING',
    TaskType.other => 'TÂCHE',
  };
}
