import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HeraHistoryTheme {
  const HeraHistoryTheme._();

  static const lime = Color(0xFFB57BFF);
  static const purple = Color(0xFF7C3AED);
}

class HeraHistoryHeader extends StatelessWidget {
  const HeraHistoryHeader({
    super.key,
    required this.isDark,
    required this.actionCount,
    required this.onBack,
  });

  final bool isDark;
  final int actionCount;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final headerColor = isDark ? const Color(0xFF141414) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark
        ? const Color(0xFF888888)
        : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: headerColor,
        border: Border(
          bottom: BorderSide(
            color: HeraHistoryTheme.lime.withValues(alpha: 0.12),
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: textColor,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: HeraHistoryTheme.lime.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: HeraHistoryTheme.lime,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historique complet',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Toutes les actions de Hera',
                  style: TextStyle(color: mutedColor, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: HeraHistoryTheme.lime.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: HeraHistoryTheme.lime.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              '$actionCount',
              style: const TextStyle(
                color: HeraHistoryTheme.lime,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HeraHistoryItem extends StatelessWidget {
  const HeraHistoryItem({
    super.key,
    required this.action,
    required this.isDark,
  });

  final Map<String, dynamic> action;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final config = getHeraHistoryConfig(action);
    final accent = config.color;
    final employeeName = action['employee_name'] ?? 'Employé';
    final createdAt = action['created_at'] != null
        ? DateTime.tryParse(action['created_at'].toString())
        : null;
    final cardColor = isDark ? const Color(0xFF141414) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark
        ? const Color(0xFF888888)
        : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(config.icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employeeName,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  config.label,
                  style: TextStyle(color: mutedColor, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  config.badge,
                  style: TextStyle(
                    color: accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (createdAt != null) ...[
                const SizedBox(height: 5),
                Text(
                  formatHeraHistoryTimeAgo(createdAt),
                  style: TextStyle(color: mutedColor, fontSize: 10),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class HeraHistoryDismissBackground extends StatelessWidget {
  const HeraHistoryDismissBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.25),
        ),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Row(
        children: [
          Icon(
            Icons.delete_outline_rounded,
            color: Color(0xFFEF4444),
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            'Supprimer',
            style: TextStyle(
              color: Color(0xFFEF4444),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class HeraHistoryEmptyState extends StatelessWidget {
  const HeraHistoryEmptyState({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark
        ? const Color(0xFF888888)
        : const Color(0xFF64748B);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: HeraHistoryTheme.lime.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: HeraHistoryTheme.lime,
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Aucune action',
            style: TextStyle(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'L\'historique Hera apparaîtra ici',
            style: TextStyle(color: mutedColor, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class HeraHistoryLoadingMoreIndicator extends StatelessWidget {
  const HeraHistoryLoadingMoreIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(color: HeraHistoryTheme.lime),
      ),
    );
  }
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
