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

    final bg = isDark ? const Color(0xFF080809) : const Color(0xFFFAFAFC);
    final surface = isDark ? const Color(0xFF111113) : Colors.white;
    final surface2 = isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F6);
    final border = isDark ? const Color(0xFF242428) : const Color(0xFFE4E4E8);
    final border2 = isDark ? const Color(0xFF2E2E33) : const Color(0xFFDCDCE2);
    final textHigh = isDark ? const Color(0xFFF2F2F5) : const Color(0xFF111113);
    final textMid = isDark ? const Color(0xFF8B8B99) : const Color(0xFF6B6B7B);
    final textLow = isDark ? const Color(0xFF4A4A55) : const Color(0xFFAAAAAB);
    const accent = Color(0xFF7C5CFC);
    const green = Color(0xFF3ECF8E);
    const red = Color(0xFFFF4D6A);
    const gold = Color(0xFFE8B84B);

    if (p.loadingHistory) {
      return Container(
        color: bg,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: accent),
          ),
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
    final winPct = stats.totalPlayed > 0
        ? (stats.wins / stats.totalPlayed)
        : 0.0;

    return Container(
      color: bg,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── PERFORMANCE CARD ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Row(
                      children: [
                        Text(
                          "Performance",
                          style: TextStyle(
                            color: textHigh,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: accent.withOpacity(0.20)),
                          ),
                          child: Text(
                            "${stats.totalPlayed} parties",
                            style: TextStyle(
                              color: accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Win rate",
                              style: TextStyle(
                                color: textMid,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "${stats.winRate}%",
                              style: TextStyle(
                                color: textHigh,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            height: 5,
                            child: LinearProgressIndicator(
                              value: winPct.toDouble(),
                              backgroundColor: surface2,
                              valueColor: const AlwaysStoppedAnimation(green),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: border),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        _Metric(
                          value: "${stats.wins}",
                          label: "Victoires",
                          valueColor: green,
                          textMid: textMid,
                        ),
                        _VertDivider(color: border2),
                        _Metric(
                          value: "${stats.losses}",
                          label: "Défaites",
                          valueColor: red,
                          textMid: textMid,
                        ),
                        _VertDivider(color: border2),
                        _Metric(
                          value: "${stats.totalEnergyEarned}⚡",
                          label: "Énergie",
                          valueColor: gold,
                          textMid: textMid,
                        ),
                        _VertDivider(color: border2),
                        _Metric(
                          value: "×${stats.bestStreak}",
                          label: "Best série",
                          valueColor: accent,
                          textMid: textMid,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── BADGES ───────────────────────────────────────
          if (stats.badges.isNotEmpty) ...[
            _SectionLabel(label: "Badges", textLow: textLow),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: stats.badges
                    .map(
                      (b) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: border),
                        ),
                        child: Text(
                          "${b.emoji}  ${b.name}",
                          style: TextStyle(
                            color: textHigh,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],

          // ── HISTORY ───────────────────────────────────────
          _SectionLabel(label: "Historique", textLow: textLow),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: border),
                itemBuilder: (context, i) {
                  final h = history[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: h.isCorrect ? green : red,
                            ),
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
                                  fontWeight: FontWeight.w500,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _Tag(
                                    label: h.domain,
                                    color: textLow,
                                    bg: surface2,
                                    border: border,
                                  ),
                                  const SizedBox(width: 4),
                                  _Tag(
                                    label: h.chosenAgent,
                                    color: textLow,
                                    bg: surface2,
                                    border: border,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "+${h.energyReward}",
                          style: TextStyle(
                            color: h.energyReward > 0 ? gold : textLow,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.label,
    required this.valueColor,
    required this.textMid,
  });
  final String value, label;
  final Color valueColor, textMid;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: textMid,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class _VertDivider extends StatelessWidget {
  const _VertDivider({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 30, color: color);
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.textLow});
  final String label;
  final Color textLow;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
    child: Text(
      label.toUpperCase(),
      style: TextStyle(
        color: textLow,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      ),
    ),
  );
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.color,
    required this.bg,
    required this.border,
  });
  final String label;
  final Color color, bg, border;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: border),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
    ),
  );
}
