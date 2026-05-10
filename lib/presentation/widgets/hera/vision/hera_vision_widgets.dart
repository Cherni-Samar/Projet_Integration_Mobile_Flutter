import 'package:flutter/material.dart';

import 'package:e_team/presentation/widgets/hera/hera_shared_widgets.dart';

class HeraVisionHeaderCard extends StatelessWidget {
  final int employeeCount;
  final int departmentCount;

  const HeraVisionHeaderCard({
    super.key,
    required this.employeeCount,
    required this.departmentCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: HeraPalette.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: HeraPalette.mauve.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: HeraPalette.mauve.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.radar_rounded,
              color: HeraPalette.mauve,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Analyse de Densité',
                  style: TextStyle(
                    color: HeraPalette.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '$employeeCount collaborateurs · $departmentCount départements',
                  style: const TextStyle(
                    color: HeraPalette.textMuted,
                    fontSize: 12,
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

class HeraDepartmentDensityBar extends StatelessWidget {
  final String department;
  final int count;
  final int max;

  const HeraDepartmentDensityBar({
    super.key,
    required this.department,
    required this.count,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (count / max).clamp(0.0, 1.0);
    final isFull = pct >= 0.8;
    final color = isFull ? HeraPalette.mauve : const Color(0xFFB971FF);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: HeraPalette.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HeraPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                department,
                style: const TextStyle(
                  color: HeraPalette.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '$count / $max',
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class HeraVisionInfoFooter extends StatelessWidget {
  const HeraVisionInfoFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HeraPalette.cardSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HeraPalette.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: HeraPalette.mauve),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Mauve = département à ≥ 80% de capacité. Orange = sous-effectif, recrutement recommandé.',
              style: TextStyle(color: HeraPalette.textMuted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
