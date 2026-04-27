import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_team/presentation/providers/predictions_provider.dart';
import '../../providers/theme_provider.dart';

class PredictionsHistoryScreen extends StatefulWidget {
  const PredictionsHistoryScreen({super.key});

  @override
  State<PredictionsHistoryScreen> createState() =>
      _PredictionsHistoryScreenState();
}

class _PredictionsHistoryScreenState extends State<PredictionsHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<PredictionsProvider>().fetchHistory());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final p = context.watch<PredictionsProvider>();

    final bg = isDark ? const Color(0xFF09090B) : const Color(0xFFF8F9FA);
    final surface = isDark ? const Color(0xFF141417) : Colors.white;
    final surface2 = isDark ? const Color(0xFF1F1F24) : const Color(0xFFF2F2F5);
    final border = isDark ? const Color(0xFF2B2B32) : const Color(0xFFE4E4EA);
    final textHigh = isDark ? Colors.white : const Color(0xFF141417);
    final textMid = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final textLow = isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);

    const accent = Color(0xFF7C3AED);
    const green = Color(0xFF22C55E);
    const red = Color(0xFFEF4444);
    const gold = Color(0xFFEAB308);

    if (p.loadingHistory) {
      return Container(
        color: bg,
        child: const Center(
          child: CircularProgressIndicator(color: accent),
        ),
      );
    }

    if (p.error != null || p.historyRes == null) {
      return Container(
        color: bg,
        child: Center(
          child: Text(
            p.error != null ? "Erreur: ${p.error}" : "Aucune donnée.",
            style: TextStyle(color: textMid, fontSize: 14),
          ),
        ),
      );
    }

    final stats = p.historyRes!.stats;
    final history = p.historyRes!.history;
    final winPct = stats.totalPlayed > 0 ? stats.wins / stats.totalPlayed : 0.0;

    return Container(
      color: bg,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.035),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Performance",
                      style: TextStyle(
                        color: textHigh,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    _SoftBadge(
                      label: "${stats.totalPlayed} parties",
                      color: accent,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Win rate",
                      style: TextStyle(color: textMid, fontSize: 13),
                    ),
                    Text(
                      "${stats.winRate}%",
                      style: TextStyle(
                        color: textHigh,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: winPct.toDouble(),
                    minHeight: 8,
                    backgroundColor: surface2,
                    valueColor: const AlwaysStoppedAnimation(green),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _MetricCard(
                      value: "${stats.wins}",
                      label: "Victoires",
                      color: green,
                      bg: surface2,
                    ),
                    const SizedBox(width: 8),
                    _MetricCard(
                      value: "${stats.losses}",
                      label: "Défaites",
                      color: red,
                      bg: surface2,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _MetricCard(
                      value: "${stats.totalEnergyEarned}⚡",
                      label: "Énergie",
                      color: gold,
                      bg: surface2,
                    ),
                    const SizedBox(width: 8),
                    _MetricCard(
                      value: "×${stats.bestStreak}",
                      label: "Best série",
                      color: accent,
                      bg: surface2,
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (stats.badges.isNotEmpty) ...[
            const SizedBox(height: 22),
            _SectionTitle("Badges", textHigh, textMid),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: stats.badges.map((b) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: border),
                  ),
                  child: Text(
                    "${b.emoji}  ${b.name}",
                    style: TextStyle(
                      color: textHigh,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 24),
          _SectionTitle("Historique", textHigh, textMid),
          const SizedBox(height: 10),

          ...history.map((h) {
            final isCorrect = h.isCorrect;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: (isCorrect ? green : red).withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCorrect
                          ? Icons.check_rounded
                          : Icons.close_rounded,
                      color: isCorrect ? green : red,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h.question,
                          style: TextStyle(
                            color: textHigh,
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _Tag(label: h.domain, bg: surface2, color: textLow),
                            _Tag(label: h.chosenAgent, bg: surface2, color: textLow),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "+${h.energyReward}",
                    style: TextStyle(
                      color: h.energyReward > 0 ? gold : textLow,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _SectionTitle(String title, Color textHigh, Color textMid) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: textHigh,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            color: textMid.withOpacity(0.18),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    required this.color,
    required this.bg,
  });

  final String value;
  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftBadge extends StatelessWidget {
  const _SoftBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.bg,
    required this.color,
  });

  final String label;
  final Color bg;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}