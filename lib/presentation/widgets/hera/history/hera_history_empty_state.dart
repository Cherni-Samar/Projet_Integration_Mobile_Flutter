import 'package:flutter/material.dart';

import 'package:e_team/presentation/widgets/hera/history/hera_history_config.dart';

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
