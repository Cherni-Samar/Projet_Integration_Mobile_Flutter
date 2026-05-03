import 'package:flutter/material.dart';

import 'package:e_team/domain/models/hera_models.dart';
import '../hr_shared_widgets.dart';

/// Vision tab — department density radar / staffing analysis.
/// All state lives in [_HrDashboardPageState]; this widget is pure UI.
class HrVisionTab extends StatelessWidget {
  final List<HeraEmployee> employees;

  const HrVisionTab({super.key, required this.employees});

  // Static config — department capacity targets.
  static const Map<String, int> _deptMax = {
    'Tech': 20,
    'Design': 10,
    'Marketing': 15,
    'RH': 5,
    'Finance': 8,
    'Support': 12,
  };

  // Pure helper — no state access needed.
  int _countInDept(String dept) {
    return employees.where((emp) {
      return emp.department.toLowerCase() == dept.toLowerCase() &&
          emp.status == 'active';
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        // ── Header card ──────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: HeraPalette.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: HeraPalette.mauve.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: HeraPalette.mauve.withOpacity(0.10),
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
                      '${employees.length} collaborateurs · ${_deptMax.length} départements',
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
        ),
        const SizedBox(height: 24),
        const Text(
          'Densité par département',
          style: TextStyle(
            color: HeraPalette.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 16),

        // ── Department bars ──────────────────────────────────────────────────
        ..._deptMax.entries.map((entry) {
          final count = _countInDept(entry.key);
          final pct = (count / entry.value).clamp(0.0, 1.0);
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
                      entry.key,
                      style: const TextStyle(
                        color: HeraPalette.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$count / ${entry.value}',
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
                    backgroundColor: color.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),

        // ── Info footer ──────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: HeraPalette.cardSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HeraPalette.border),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: HeraPalette.mauve,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Mauve = département à ≥ 80% de capacité. Orange = sous-effectif, recrutement recommandé.',
                  style: TextStyle(
                    color: HeraPalette.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
