import 'package:flutter/material.dart';

import 'package:e_team/presentation/widgets/hera/hera_palette.dart';

class HeraBadge extends StatelessWidget {
  final String label;
  final Color color;

  const HeraBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
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

class HeraShimmerBox extends StatelessWidget {
  final double height;

  const HeraShimmerBox({super.key, required this.height});

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

class HeraEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;

  const HeraEmptyState({
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
                color: HeraPalette.mauve.withValues(alpha: 0.12),
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

class HeraSectionHeader extends StatelessWidget {
  final String label;
  final String? action;
  final VoidCallback? onAction;

  const HeraSectionHeader({
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
                color: HeraPalette.mauve.withValues(alpha: 0.12),
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

class HeraDismissBackground extends StatelessWidget {
  const HeraDismissBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: HeraPalette.danger.withValues(alpha: 0.1),
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

class HeraTimoBanner extends StatelessWidget {
  const HeraTimoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HeraPalette.timo.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HeraPalette.timo.withValues(alpha: 0.3)),
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
            color: HeraPalette.timo.withValues(alpha: 0.5),
            size: 16,
          ),
        ],
      ),
    );
  }
}

class HeraLegendChip extends StatelessWidget {
  final String label;
  final Color color;

  const HeraLegendChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
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
