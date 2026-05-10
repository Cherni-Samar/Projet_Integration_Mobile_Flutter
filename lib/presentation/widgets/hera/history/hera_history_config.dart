import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HeraHistoryTheme {
  const HeraHistoryTheme._();

  static const lime = Color(0xFFB57BFF);
  static const purple = Color(0xFF7C3AED);
}

class HeraHistoryConfig {
  const HeraHistoryConfig({
    required this.icon,
    required this.color,
    required this.label,
    required this.badge,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String badge;
}

HeraHistoryConfig getHeraHistoryConfig(Map<String, dynamic> action) {
  switch (action['action_type']) {
    case 'onboarding_started':
      return const HeraHistoryConfig(
        icon: Icons.person_add_rounded,
        color: HeraHistoryTheme.lime,
        label: 'Onboarding démarré',
        badge: 'NOUVEAU',
      );
    case 'onboarding_completed':
      return const HeraHistoryConfig(
        icon: Icons.check_circle_rounded,
        color: Color(0xFF10B981),
        label: 'Onboarding complété',
        badge: 'ACTIF',
      );
    case 'leave_approved':
      return const HeraHistoryConfig(
        icon: Icons.event_available_rounded,
        color: Color(0xFF10B981),
        label: 'Congé approuvé',
        badge: 'APPROUVÉ',
      );
    case 'leave_refused':
      return const HeraHistoryConfig(
        icon: Icons.event_busy_rounded,
        color: Color(0xFFEF4444),
        label: 'Congé refusé',
        badge: 'REFUSÉ',
      );
    case 'offboarding_started':
      return const HeraHistoryConfig(
        icon: Icons.logout_rounded,
        color: Color(0xFFF59E0B),
        label: 'Offboarding démarré',
        badge: 'DÉPART',
      );
    case 'offboarding_completed':
      return const HeraHistoryConfig(
        icon: Icons.exit_to_app_rounded,
        color: Color(0xFFEF4444),
        label: 'Offboarding complété',
        badge: 'INACTIF',
      );
    case 'promotion':
      return const HeraHistoryConfig(
        icon: Icons.trending_up_rounded,
        color: HeraHistoryTheme.purple,
        label: 'Promotion',
        badge: 'PROMU',
      );
    case 'absence_alert':
      return const HeraHistoryConfig(
        icon: Icons.warning_amber_rounded,
        color: Color(0xFFF59E0B),
        label: 'Alerte absences',
        badge: 'ALERTE',
      );
    default:
      return const HeraHistoryConfig(
        icon: Icons.auto_awesome_rounded,
        color: HeraHistoryTheme.purple,
        label: 'Action Hera',
        badge: 'INFO',
      );
  }
}

String formatHeraHistoryTimeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'À l\'instant';
  if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes}min';
  if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
  if (diff.inDays < 7) return 'il y a ${diff.inDays}j';
  return DateFormat('d MMM yyyy', 'fr_FR').format(date);
}
