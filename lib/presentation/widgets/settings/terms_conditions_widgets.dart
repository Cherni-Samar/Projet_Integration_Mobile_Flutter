import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/models/settings/terms_conditions_section.dart';

class TermsConditionsHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isDark;
  final VoidCallback onBackPressed;

  const TermsConditionsHeader({
    super.key,
    required this.l10n,
    required this.isDark,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E1E1E), Color(0xFF2A2A2A)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFF9FAFB)],
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBackPressed,
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1),
                ),
              ),
              child: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : Colors.black,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  l10n.termsTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.termsSubtitle,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class TermsConditionsContent extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isDark;
  final List<TermsConditionsSection> sections;
  final String? expandedSection;
  final ValueChanged<String> onSectionPressed;
  final VoidCallback onAcceptPressed;

  const TermsConditionsContent({
    super.key,
    required this.l10n,
    required this.isDark,
    required this.sections,
    required this.expandedSection,
    required this.onSectionPressed,
    required this.onAcceptPressed,
  });

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
  final AppLocalizations l10n;
  final bool isDark;

  const TermsConditionsBadge({
    super.key,
    required this.l10n,
    required this.isDark,
  });

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

class TermsExpandableSectionCard extends StatelessWidget {
  final bool isDark;
  final TermsConditionsSection section;
  final bool isExpanded;
  final VoidCallback onTap;

  const TermsExpandableSectionCard({
    super.key,
    required this.isDark,
    required this.section,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: termsSectionDecoration(
          isDark: isDark,
          isExpanded: isExpanded,
          iconColor: section.iconColor,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TermsSectionHeader(
                    isDark: isDark,
                    section: section,
                    isExpanded: isExpanded,
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 16, left: 52),
                      child: Text(
                        section.content,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.8)
                              : Colors.black.withValues(alpha: 0.7),
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TermsSectionHeader extends StatelessWidget {
  final bool isDark;
  final TermsConditionsSection section;
  final bool isExpanded;

  const TermsSectionHeader({
    super.key,
    required this.isDark,
    required this.section,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: section.iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: section.iconColor.withValues(alpha: 0.3)),
          ),
          child: Icon(section.icon, color: section.iconColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                section.summary,
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : Colors.black.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        AnimatedRotation(
          duration: const Duration(milliseconds: 300),
          turns: isExpanded ? 0.5 : 0,
          child: Icon(
            Icons.keyboard_arrow_down,
            color: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class TermsAcceptButton extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isDark;
  final VoidCallback onPressed;

  const TermsAcceptButton({
    super.key,
    required this.l10n,
    required this.isDark,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFFCDFF00).withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFFCDFF00) : Colors.black,
            foregroundColor: isDark ? Colors.black : const Color(0xFFCDFF00),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 24),
              const SizedBox(width: 12),
              Text(
                l10n.termsAcceptButton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration termsSectionDecoration({
  required bool isDark,
  required bool isExpanded,
  required Color iconColor,
}) {
  return BoxDecoration(
    color: isDark
        ? isExpanded
              ? const Color(0xFF1E1E1E)
              : Colors.white.withValues(alpha: 0.05)
        : isExpanded
        ? Colors.white
        : Colors.white.withValues(alpha: 0.7),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: isExpanded
          ? iconColor.withValues(alpha: 0.5)
          : isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.1),
      width: isExpanded ? 2 : 1,
    ),
    boxShadow: [
      BoxShadow(
        color: isExpanded
            ? iconColor.withValues(alpha: isDark ? 0.2 : 0.1)
            : Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
        blurRadius: isExpanded ? 20 : 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
