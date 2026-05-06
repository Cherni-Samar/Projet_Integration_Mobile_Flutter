import 'package:flutter/material.dart';

import 'package:e_team/presentation/widgets/hera/hera_shared_widgets.dart';

/// Energy tab — shows AI task costs vs current energy balance.
/// All state lives in [_HeraDashboardPageState]; this widget is pure UI.
class HeraEnergyTab extends StatelessWidget {
  final int energyBalance;

  const HeraEnergyTab({super.key, required this.energyBalance});

  static const _tasks = [
    ('Demande de congé', 10, Icons.event_note_rounded, HeraPalette.violet),
    ('Congé urgent', 15, Icons.flash_on_rounded, Color(0xFFEC4899)),
    (
      'Onboarding employé',
      25,
      Icons.person_add_alt_1_rounded,
      Color(0xFF8B5CF6),
    ),
    ('Promotion', 20, Icons.trending_up_rounded, Color(0xFF06B6D4)),
    (
      'Évaluation performance',
      18,
      Icons.workspace_premium,
      HeraPalette.warning,
    ),
    ('Offboarding', 30, Icons.exit_to_app_rounded, HeraPalette.danger),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        const Text(
          'Coût des tâches IA',
          style: TextStyle(
            color: HeraPalette.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        ..._tasks.map((task) {
          final (label, cost, icon, taskColor) = task;
          final canAfford = energyBalance >= cost;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HeraPalette.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: canAfford
                    ? HeraPalette.border
                    : HeraPalette.danger.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: taskColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: taskColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: HeraPalette.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '$cost ⚡ points',
                        style: TextStyle(
                          color: taskColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!canAfford)
                  const HeraBadge(
                    label: 'INSUFFISANT',
                    color: HeraPalette.danger,
                  )
                else
                  HeraBadge(
                    label: '${energyBalance - cost} restants',
                    color: taskColor,
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),
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
                  'L\'énergie se recharge chaque jour. Chaque action IA consomme des points selon sa complexité.',
                  style: TextStyle(color: HeraPalette.textMuted, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
