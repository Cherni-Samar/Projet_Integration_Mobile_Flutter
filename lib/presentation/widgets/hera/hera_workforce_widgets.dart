import 'package:flutter/material.dart';

import 'package:e_team/domain/models/hera_models.dart';
import 'package:e_team/presentation/widgets/hera/hera_palette.dart';

class HeraWorkforcePulse extends StatelessWidget {
  final HeraStats? stats;
  final AnimationController pulseCtrl;

  const HeraWorkforcePulse({
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
              const Color(
                0xFF7C3AED,
              ).withValues(alpha: 0.13 + 0.04 * pulseCtrl.value),
              const Color(0xFFB57BFF).withValues(alpha: 0.07),
              HeraPalette.bg,
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(
              0xFF7C3AED,
            ).withValues(alpha: 0.45 + 0.1 * pulseCtrl.value),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF7C3AED,
              ).withValues(alpha: 0.10 + 0.04 * pulseCtrl.value),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
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
            color: color.withValues(alpha: 0.15),
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
