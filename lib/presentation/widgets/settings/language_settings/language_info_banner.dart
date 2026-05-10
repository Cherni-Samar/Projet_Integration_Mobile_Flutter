import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';

class LanguageInfoBanner extends StatelessWidget {
  const LanguageInfoBanner({
    super.key,
    required this.l10n,
    required this.isDark,
  });

  final AppLocalizations l10n;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFFCDFF00).withValues(alpha: 0.15),
                    const Color(0xFFAADD00).withValues(alpha: 0.1),
                  ]
                : [
                    const Color(0xFFCDFF00).withValues(alpha: 0.2),
                    const Color(0xFFAADD00).withValues(alpha: 0.15),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFCDFF00).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFCDFF00).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.language,
                color: isDark ? const Color(0xFFCDFF00) : Colors.black,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.languageInfoBanner,
                style: TextStyle(
                  color: isDark ? const Color(0xFFCDFF00) : Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
