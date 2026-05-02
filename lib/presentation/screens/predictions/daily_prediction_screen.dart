import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_team/presentation/providers/predictions_provider.dart';
import '../../providers/theme_provider.dart';

class DailyPredictionScreen extends StatefulWidget {
  const DailyPredictionScreen({super.key});

  @override
  State<DailyPredictionScreen> createState() => _DailyPredictionScreenState();
}

class _DailyPredictionScreenState extends State<DailyPredictionScreen> {
  int selectedOption = -1;
  String chosenAgent = 'hera';

  // 🔋 ENERGY SYSTEM
  Map<String, int> agentEnergy = {
    'hera': 80,
    'echo': 60,
    'kash': 90,
    'dexo': 70,
    'timo': 50,
  };

  static const _agents = [
    ('hera', 'Héra', '🔮'),
    ('echo', 'Écho', '⚡'),
    ('kash', 'Kash', '🎯'),
    ('dexo', 'Dexo', '🛡️'),
    ('timo', 'Timo', '🌪️'),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<PredictionsProvider>().fetchDaily());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final p = context.watch<PredictionsProvider>();
    final daily = p.daily;
    final challenge = daily?.challenge;

    final bg = isDark ? const Color(0xFF080809) : const Color(0xFFFAFAFC);
    final surface = isDark ? const Color(0xFF111113) : Colors.white;
    final surface2 = isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F6);
    final border = isDark ? const Color(0xFF242428) : const Color(0xFFE4E4E8);
    final textHigh = isDark ? const Color(0xFFF2F2F5) : const Color(0xFF111113);
    final textMid = isDark ? const Color(0xFF8B8B99) : const Color(0xFF6B6B7B);
    final textLow = isDark ? const Color(0xFF4A4A55) : const Color(0xFFAAAAAB);

    const accent = Color(0xFF7C5CFC);
    const green = Color(0xFF3ECF8E);
    const red = Color(0xFFFF4D6A);
    const warning = Color(0xFFF59E0B);

    final canPlay = daily?.canPlay ?? false;
    final alreadyAnswered = daily?.alreadyAnswered == true;

    if (p.loadingDaily) {
      return Container(
        color: bg,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (p.error != null) {
      return Container(
        color: bg,
        child: Center(
          child: Text("Erreur: ${p.error}", style: TextStyle(color: textMid)),
        ),
      );
    }

    if (challenge == null) {
      return Container(
        color: bg,
        child: Center(
          child: Text(
            "Aucun défi disponible.",
            style: TextStyle(color: textMid),
          ),
        ),
      );
    }

    return Container(
      color: bg,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ⚠️ ALERT
          if (alreadyAnswered || !canPlay)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: warning.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: warning.withOpacity(0.25)),
              ),
              child: Text(
                daily?.error ?? "Déjà répondu !",
                style: TextStyle(color: textHigh),
              ),
            ),

          // 📌 QUESTION
          Text(
            challenge.question,
            style: TextStyle(
              color: textHigh,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 20),

          // 🧠 OPTIONS
          ...List.generate(challenge.options.length, (i) {
            final selected = selectedOption == i;

            return GestureDetector(
              onTap: canPlay ? () => setState(() => selectedOption = i) : null,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected ? accent.withOpacity(0.1) : surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selected ? accent : border),
                ),
                child: Text(
                  challenge.options[i],
                  style: TextStyle(color: selected ? textHigh : textMid),
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // 🤖 AGENTS + ENERGY
          Text("Agent", style: TextStyle(color: textLow, fontSize: 12)),

          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _agents.map((a) {
                final (id, name, emoji) = a;
                final active = chosenAgent == id;
                final energy = agentEnergy[id] ?? 0;

                return GestureDetector(
                  onTap: canPlay
                      ? () => setState(() => chosenAgent = id)
                      : null,
                  child: Container(
                    width: 130,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: active ? accent.withOpacity(0.15) : surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: active ? accent : border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(emoji),
                            const SizedBox(width: 6),
                            Text(
                              name,
                              style: TextStyle(
                                color: active ? textHigh : textMid,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // ENERGY BAR
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: border,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: FractionallySizedBox(
                            widthFactor: energy / 100,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                color: energy > 60
                                    ? green
                                    : energy > 30
                                    ? warning
                                    : red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          "$energy%",
                          style: TextStyle(color: textMid, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 25),

          // 🚀 SUBMIT
          GestureDetector(
            onTap: (p.submitting || selectedOption < 0 || !canPlay)
                ? null
                : () async {
                    await p.submitAnswer(
                      predictionId: challenge.id,
                      answer: selectedOption,
                      chosenAgent: chosenAgent,
                    );

                    // 🔋 consume energy
                    setState(() {
                      agentEnergy[chosenAgent] =
                          (agentEnergy[chosenAgent]! - 10).clamp(0, 100);
                    });
                  },
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: (p.submitting || selectedOption < 0 || !canPlay)
                    ? surface2
                    : accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  canPlay ? "Soumettre la réponse" : "Déjà répondu",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
