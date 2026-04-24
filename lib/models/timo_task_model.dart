import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
//  TIMO DESIGN SYSTEM
// ─────────────────────────────────────────────────────────────
class TimoDesignSystem {
  // White SaaS Theme Colors
  static const Color bg = Color(0xFFFFFFFF);           // Fond blanc pur
  static const Color card = Color(0xFFFFFFFF);         // Cartes blanches
  static const Color border = Color(0xFFF1F5F9);       // Bordures ultra-fines gris-bleu
  static const Color textPrimary = Color(0xFF0F172A);  // Texte principal
  static const Color textSecondary = Color(0xFF64748B); // Texte secondaire
  static const Color textMuted = Color(0xFF94A3B8);    // Texte atténué
  
  // Task Type Colors
  static const Color interview = Color(0xFF06B6D4);    // Cyan pour interviews
  static const Color onboarding = Color(0xFF10B981);   // Emerald pour onboarding
  static const Color offboarding = Color(0xFFF87171);  // Rouge Corail pour offboarding
  static const Color other = Color(0xFFFF9800);        // Orange pour autres
  
  // Status Colors
  static const Color success = Color(0xFF10B981);      // Vert succès
  static const Color warning = Color(0xFFF59E0B);      // Orange warning
  static const Color neonGreen = Color(0xFFCCFF00);    // Point de vie pulsant
  
  // Shadows & Effects
  static const Color shadowLight = Color(0x08000000);  // Ombre ultra-légère
}

// ─────────────────────────────────────────────────────────────
//  TASK CLASSIFICATION - LOGIQUE CORRIGÉE PAR MOTS-CLÉS
// ─────────────────────────────────────────────────────────────
enum TaskType { interview, onboarding, offboarding, other }

class TimoTask {
  final String    raw;
  final String    employeeName;
  final TaskType  type;
  final String    status;
  final DateTime? deadline;
  final String    id;

  TimoTask({
    required this.raw,
    required this.employeeName,
    required this.type,
    required this.status,
    required this.deadline,
    required this.id,
  });

  factory TimoTask.fromMap(Map<String, dynamic> m) {
    final title  = m['title'] as String? ?? '';
    final status = m['status'] as String? ?? 'todo';
    final id     = m['_id']?.toString() ?? '';

    DateTime? deadline;
    try { deadline = DateTime.parse(m['deadline']); } catch (_) {}

    // ✅ NOUVELLE LOGIQUE DE CLASSIFICATION PAR MOTS-CLÉS
    TaskType type = TaskType.other;
    String employeeName = title;

    final lowerTitle = title.toLowerCase();
    
    // Classification par mots-clés
    if (lowerTitle.contains('démission') || lowerTitle.contains('départ') || lowerTitle.contains('offboarding')) {
      type = TaskType.offboarding;
    } else if (lowerTitle.contains('intégration') || lowerTitle.contains('onboarding')) {
      type = TaskType.onboarding;
    } else if (lowerTitle.contains('entretien') || lowerTitle.contains('interview')) {
      type = TaskType.interview;
    }

    // Extraction du nom après les deux points
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
      id: id
    );
  }

  bool get isDone => status == 'done';

  // Configuration visuelle selon le type
  IconData get icon => switch (type) {
    TaskType.interview   => Icons.record_voice_over_rounded,
    TaskType.onboarding  => Icons.person_add_alt_1_rounded,
    TaskType.offboarding => Icons.exit_to_app_rounded,
    TaskType.other       => Icons.event_rounded,
  };

  Color get color => switch (type) {
    TaskType.interview   => TimoDesignSystem.interview,
    TaskType.onboarding  => TimoDesignSystem.onboarding,
    TaskType.offboarding => TimoDesignSystem.offboarding,
    TaskType.other       => TimoDesignSystem.other,
  };

  String get typeLabel => switch (type) {
    TaskType.interview   => 'INTERVIEW',
    TaskType.onboarding  => 'ONBOARDING',
    TaskType.offboarding => 'OFFBOARDING',
    TaskType.other       => 'TÂCHE',
  };
}
