import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/models/settings/terms_conditions_section.dart';
import 'package:e_team/presentation/widgets/settings/terms_conditions/terms_conditions_actions.dart';
import 'package:e_team/presentation/widgets/settings/terms_conditions/terms_conditions_sections.dart';

class TermsConditionsContent extends StatelessWidget {
  const TermsConditionsContent({
    super.key,
    required this.l10n,
    required this.isDark,
    required this.sections,
    required this.expandedSection,
    required this.onSectionPressed,
    required this.onAcceptPressed,
  });

  final AppLocalizations l10n;
  final bool isDark;
  final List<TermsConditionsSection> sections;
  final String? expandedSection;
  final ValueChanged<String> onSectionPressed;
  final VoidCallback onAcceptPressed;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TermsConditionsBadge(l10n: l10n, isDark: isDark),
          const SizedBox(height: 24),
          ...sections.map(
            (section) => TermsExpandableSectionCard(
              isDark: isDark,
              section: section,
              isExpanded: expandedSection == section.title,
              onTap: () => onSectionPressed(section.title),
            ),
          ),
          const SizedBox(height: 32),
          TermsAcceptButton(
            l10n: l10n,
            isDark: isDark,
            onPressed: onAcceptPressed,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class TermsConditionsBadge extends StatelessWidget {
  const TermsConditionsBadge({
    super.key,
    required this.l10n,
    required this.isDark,
  });

  final AppLocalizations l10n;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFFCDFF00).withValues(alpha: 0.2),
                    const Color(0xFFA855F7).withValues(alpha: 0.2),
                  ]
                : [
                    const Color(0xFFCDFF00).withValues(alpha: 0.3),
                    const Color(0xFFA855F7).withValues(alpha: 0.2),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? const Color(0xFFCDFF00).withValues(alpha: 0.3)
                : const Color(0xFFCDFF00).withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule,
              size: 16,
              color: isDark ? const Color(0xFFCDFF00) : Colors.black,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.termsBadge,
              style: TextStyle(
                color: isDark ? const Color(0xFFCDFF00) : Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
