/// Shared widgets and palette used across all HR dashboard tab files.
/// Extracted from hr_dashboard_page.dart to allow import by tab files.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:e_team/domain/models/hera_models.dart';

// ─── Palette ────────────────────────────────────────────────────────────────

class HeraPalette {
  static const bg = Colors.white;
  static const card = Color(0xFFF7F7F9);
  static const cardSoft = Color(0xFFEEEEF3);
  static const border = Color(0xFFE4E4EC);
  static const mauve = Color(0xFF904FF1);
  static const lime = Color(0xFF8940FB);
  static const violet = Color(0xFF6D28D9);
  static const timo = Color(0xFFB845FF);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFFFB74D);
  static const danger = Color(0xFFEF4444);
  static const textPrimary = Color(0xFF0D0D0D);
  static const textMuted = Color(0xFF9CA3AF);
  static const textSoft = Color(0xFFB0B0C0);
}

// ─── Shared small widgets ────────────────────────────────────────────────────

class HrBadge extends StatelessWidget {
  final String label;
  final Color color;

  const HrBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class HrShimmerBox extends StatelessWidget {
  final double height;

  const HrShimmerBox({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: HeraPalette.card,
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}

class HrEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;

  const HrEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: HeraPalette.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: HeraPalette.border),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: HeraPalette.mauve.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: HeraPalette.mauve, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: HeraPalette.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: HeraPalette.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HrSectionHeader extends StatelessWidget {
  final String label;
  final String? action;
  final VoidCallback? onAction;

  const HrSectionHeader({
    super.key,
    required this.label,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: HeraPalette.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: HeraPalette.mauve.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                action!,
                style: const TextStyle(
                  color: HeraPalette.mauve,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class HrDismissBackground extends StatelessWidget {
  const HrDismissBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: HeraPalette.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      child: const Row(
        children: [
          Icon(
            Icons.delete_outline_rounded,
            color: HeraPalette.danger,
            size: 20,
          ),
          SizedBox(width: 6),
          Text(
            'Supprimer',
            style: TextStyle(
              color: HeraPalette.danger,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class HrTimoBanner extends StatelessWidget {
  const HrTimoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HeraPalette.timo.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HeraPalette.timo.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: HeraPalette.timo, size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'L\'agent Timo a confirmé un planning — calendrier mis à jour.',
              style: TextStyle(
                color: HeraPalette.timo,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Icon(
            Icons.check_circle,
            color: HeraPalette.timo.withOpacity(0.5),
            size: 16,
          ),
        ],
      ),
    );
  }
}

class HrLegendChip extends StatelessWidget {
  final String label;
  final Color color;

  const HrLegendChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color, width: 1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class HrWorkforcePulse extends StatelessWidget {
  final HeraStats? stats;
  final AnimationController pulseCtrl;

  const HrWorkforcePulse({
    super.key,
    required this.stats,
    required this.pulseCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final total = stats?.totalEmployees ?? 0;
    final onLeave = stats?.onLeaveToday ?? 0;
    final active = total - onLeave;
    final monthly = stats?.monthlyLeaveDays ?? 0;

    return AnimatedBuilder(
      animation: pulseCtrl,
      builder: (_, child) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF7C3AED).withOpacity(
                0.13 + 0.04 * pulseCtrl.value,
              ),
              const Color(0xFFB57BFF).withOpacity(0.07),
              HeraPalette.bg,
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFF7C3AED).withOpacity(
              0.45 + 0.1 * pulseCtrl.value,
            ),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(
                0.10 + 0.04 * pulseCtrl.value,
              ),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: child,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'WORKFORCE PULSE',
                style: TextStyle(
                  color: Color(0xFF7C3AED),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.8,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Color(0xFF7C3AED),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _PulseItem(
                  value: '$total',
                  label: 'Effectif total',
                  icon: Icons.groups_2_rounded,
                  color: HeraPalette.mauve,
                ),
              ),
              const _VertDivider(),
              Expanded(
                child: _PulseItem(
                  value: '$active',
                  label: 'Actifs',
                  icon: Icons.person_rounded,
                  color: HeraPalette.success,
                ),
              ),
              const _VertDivider(),
              Expanded(
                child: _PulseItem(
                  value: '$onLeave',
                  label: 'En congé',
                  icon: Icons.beach_access_rounded,
                  color: HeraPalette.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: HeraPalette.cardSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  size: 14,
                  color: HeraPalette.textMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  '$monthly jours de congé ce mois',
                  style: const TextStyle(
                    color: HeraPalette.textSoft,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _PulseItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: HeraPalette.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: HeraPalette.textMuted, fontSize: 10),
        ),
      ],
    );
  }
}

class _VertDivider extends StatelessWidget {
  const _VertDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 60, width: 1, color: HeraPalette.border);
  }
}

// ─── Employee card widgets (used by HrTeamTab) ───────────────────────────────

class HrActiveCard extends StatelessWidget {
  final HeraEmployee employee;

  const HrActiveCard({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    String getBalance(String type) {
      final data = employee.balances[type];
      if (data is! Map) return '0/0';
      return '${data['remaining'] ?? 0}/${data['total'] ?? 0}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HeraPalette.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HeraPalette.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: HeraPalette.mauve.withOpacity(0.15),
            child: Text(
              employee.name.isNotEmpty ? employee.name[0] : '?',
              style: const TextStyle(
                color: HeraPalette.mauve,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: const TextStyle(
                    color: HeraPalette.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  employee.role.isEmpty ? 'Employé' : employee.role,
                  style: const TextStyle(
                    color: HeraPalette.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _MiniBadge(
                      icon: Icons.beach_access,
                      value: getBalance('annual'),
                    ),
                    const SizedBox(width: 6),
                    _MiniBadge(
                      icon: Icons.medical_services,
                      value: getBalance('sick'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: HeraPalette.textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final IconData icon;
  final String value;

  const _MiniBadge({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: HeraPalette.cardSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: HeraPalette.textMuted),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: HeraPalette.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class HrOnboardingCard extends StatelessWidget {
  final HeraEmployee employee;

  const HrOnboardingCard({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    String? rawDate;
    final contract = employee.contract;
    if (contract != null) rawDate = contract['start']?.toString();

    String dateText = 'Date non définie';
    String countdown = '';

    if (rawDate != null && rawDate.isNotEmpty) {
      try {
        final start = DateTime.parse(rawDate);
        dateText = DateFormat('d MMMM yyyy', 'fr_FR').format(start);
        final today = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );
        final diff = start.difference(today).inDays;
        if (diff == 0) {
          countdown = 'Arrive aujourd\'hui';
        } else if (diff == 1) {
          countdown = 'Arrive demain';
        } else if (diff > 0) {
          countdown = 'Dans $diff jours';
        } else {
          countdown = 'Arrivé';
        }
      } catch (_) {
        dateText = 'Format date invalide';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HeraPalette.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HeraPalette.mauve.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: HeraPalette.mauve.withOpacity(0.1),
                child: Text(
                  employee.name.isNotEmpty
                      ? employee.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: HeraPalette.mauve,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${employee.role} · ${employee.department}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const HrBadge(label: 'NOUVEAU', color: HeraPalette.mauve),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date de début prévue',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateText,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                if (countdown.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: HeraPalette.mauve.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      countdown,
                      style: const TextStyle(
                        color: HeraPalette.mauve,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
