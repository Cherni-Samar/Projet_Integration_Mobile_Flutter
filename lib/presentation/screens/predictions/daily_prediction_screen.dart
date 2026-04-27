import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/predictions_provider.dart';
import '../../providers/theme_provider.dart';

class DailyPredictionScreen extends StatefulWidget {
  const DailyPredictionScreen({super.key});

  @override
  State<DailyPredictionScreen> createState() =>
      _DailyPredictionScreenState();
}

class _DailyPredictionScreenState extends State<DailyPredictionScreen> {
  int selectedOption = -1;
  String chosenAgent = 'hera';

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
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final p = context.watch<PredictionsProvider>();

    final daily = p.daily;
    final challenge = daily?.challenge;

    final bg = isDark ? const Color(0xFF09090B) : const Color(0xFFF8F9FA);
    final surface = isDark ? const Color(0xFF141417) : Colors.white;
    final surface2 =
    isDark ? const Color(0xFF1F1F24) : const Color(0xFFF2F2F5);
    final border =
    isDark ? const Color(0xFF2B2B32) : const Color(0xFFE4E4EA);

    final textHigh = isDark ? Colors.white : const Color(0xFF141417);
    final textMid = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final textLow = isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);

    const accent = Color(0xFF7C3AED);
    const green = Color(0xFF22C55E);
    const warning = Color(0xFFF59E0B);
    const red = Color(0xFFEF4444);

    final canPlay = daily?.canPlay ?? false;
    final alreadyAnswered = daily?.alreadyAnswered == true;

    if (challenge == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: bg,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ALERT
          if (alreadyAnswered || !canPlay)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: warning, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      daily?.error ?? "Déjà répondu aujourd’hui",
                      style: TextStyle(color: textHigh, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          // QUESTION
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Text(
              challenge.question,
              style: TextStyle(
                color: textHigh,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // OPTIONS
          ...List.generate(challenge.options.length, (i) {
            final selected = selectedOption == i;

            return GestureDetector(
              onTap:
              canPlay ? () => setState(() => selectedOption = i) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected ? accent.withOpacity(0.08) : surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? accent : border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: selected ? accent : textLow,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        challenge.options[i],
                        style: TextStyle(
                          color: selected ? textHigh : textMid,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // 🤖 AGENTS - CLEAN CHIPS
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _agents.map((a) {
                final (id, name, emoji) = a;
                final active = chosenAgent == id;
                final energy = agentEnergy[id] ?? 0;

                return GestureDetector(
                  onTap: canPlay
                      ? () => setState(() => chosenAgent = id)
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: active ? accent : surface2,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: active ? accent : border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emoji),
                        const SizedBox(width: 6),
                        Text(
                          name,
                          style: TextStyle(
                            color:
                            active ? Colors.white : textMid,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "$energy%",
                          style: TextStyle(
                            color: active
                                ? Colors.white70
                                : textLow,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // BUTTON
          GestureDetector(
            onTap: (p.submitting ||
                selectedOption < 0 ||
                !canPlay)
                ? null
                : () async {
              await p.submitAnswer(
                predictionId: challenge.id,
                answer: selectedOption,
                chosenAgent: chosenAgent,
              );
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: (p.submitting ||
                    selectedOption < 0 ||
                    !canPlay)
                    ? surface2
                    : accent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  canPlay ? "Soumettre la réponse" : "Déjà répondu",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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