import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';
import '../../providers/predictions_provider.dart';
import 'daily_prediction_screen.dart';
import 'predictions_history_screen.dart';

class PredictionsHomeScreen extends StatefulWidget {
  const PredictionsHomeScreen({super.key});

  @override
  State<PredictionsHomeScreen> createState() => _PredictionsHomeScreenState();
}

class _PredictionsHomeScreenState extends State<PredictionsHomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    Future.microtask(() {
      final p = context.read<PredictionsProvider>();
      p.fetchDaily();
      p.fetchHistory();
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final p = context.watch<PredictionsProvider>();

    final bg = isDark ? const Color(0xFF080809) : const Color(0xFFFAFAFC);
    final surface = isDark ? const Color(0xFF111113) : Colors.white;
    final border = isDark ? const Color(0xFF242428) : const Color(0xFFE4E4E8);
    final border2 = isDark ? const Color(0xFF2E2E33) : const Color(0xFFDCDCE2);
    final textHigh = isDark ? const Color(0xFFF2F2F5) : const Color(0xFF111113);
    final textMid = isDark ? const Color(0xFF8B8B99) : const Color(0xFF6B6B7B);
    final textLow = isDark ? const Color(0xFF4A4A55) : const Color(0xFFAAAAAB);
    const accent = Color(0xFF7C5CFC);
    const green = Color(0xFF3ECF8E);
    const gold = Color(0xFFE8B84B);

    final streak = p.daily?.streak ?? p.historyRes?.stats.currentStreak ?? 0;
    final answered = p.daily?.alreadyAnswered == true;
    final badgeCount = p.historyRes?.stats.badges.length ?? 0;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              color: bg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Daily Challenge",
                              style: TextStyle(
                                color: textHigh,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "Prédis · Gagne · Progresse",
                              style: TextStyle(
                                color: textMid,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final prov = context.read<PredictionsProvider>();
                          await prov.fetchDaily();
                          await prov.fetchHistory();
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: border),
                          ),
                          child: Icon(
                            Icons.refresh_rounded,
                            color: textMid,
                            size: 17,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Stats row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      children: [
                        _HeaderStat(
                          value: "$streak",
                          label: "Jours",
                          color: accent,
                          textMid: textMid,
                        ),
                        Container(width: 1, height: 28, color: border2),
                        _HeaderStat(
                          value: answered ? "✓" : "—",
                          label: answered ? "Complété" : "À jouer",
                          color: answered ? green : textMid,
                          textMid: textMid,
                        ),
                        if (badgeCount > 0) ...[
                          Container(width: 1, height: 28, color: border2),
                          _HeaderStat(
                            value: "$badgeCount",
                            label: "Badges",
                            color: gold,
                            textMid: textMid,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Tab bar
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                    ),
                    child: TabBar(
                      controller: _tab,
                      indicator: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: textMid,
                      dividerColor: Colors.transparent,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: -0.1,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                      tabs: const [
                        Tab(text: "Défi du jour"),
                        Tab(text: "Historique"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 1),
                ],
              ),
            ),

            // ── CONTENT ─────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: const [
                  DailyPredictionScreen(),
                  PredictionsHistoryScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.value,
    required this.label,
    required this.color,
    required this.textMid,
  });
  final String value, label;
  final Color color, textMid;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
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
          ),
        ],
      ),
    );
  }
}
