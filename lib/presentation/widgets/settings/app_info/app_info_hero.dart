import 'package:e_team/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class AppInfoHero extends StatelessWidget {
  const AppInfoHero({super.key, required this.isDark, required this.l10n});

  final bool isDark;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFCDFF00), Color(0xFFAADD00)],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFCDFF00).withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: const Center(
            child: Text('🤖', style: TextStyle(fontSize: 60)),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'E-Team',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.appInfoTagline,
          style: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.black.withValues(alpha: 0.6),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFFCDFF00).withValues(alpha: 0.2),
                      const Color(0xFFAADD00).withValues(alpha: 0.15),
                    ]
                  : [
                      const Color(0xFFCDFF00).withValues(alpha: 0.3),
                      const Color(0xFFAADD00).withValues(alpha: 0.2),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFCDFF00).withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            l10n.appInfoVersion('1.0.0'),
            style: TextStyle(
              color: isDark ? const Color(0xFFCDFF00) : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
