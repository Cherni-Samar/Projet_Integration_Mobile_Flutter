import 'package:flutter/material.dart';

import 'package:e_team/presentation/widgets/hera/hera_shared_widgets.dart';

class HeraAgendaLegend extends StatelessWidget {
  const HeraAgendaLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HeraPalette.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HeraPalette.border),
      ),
      child: const Wrap(
        spacing: 20,
        runSpacing: 8,
        children: [
          HeraLegendChip(label: 'Congé annuel', color: HeraPalette.mauve),
          HeraLegendChip(label: 'Maladie', color: HeraPalette.warning),
          HeraLegendChip(label: 'Urgent', color: HeraPalette.danger),
        ],
      ),
    );
  }
}
