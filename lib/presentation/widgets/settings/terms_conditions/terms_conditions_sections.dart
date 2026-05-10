import 'package:flutter/material.dart';

import 'package:e_team/presentation/models/settings/terms_conditions_section.dart';

class TermsExpandableSectionCard extends StatelessWidget {
  const TermsExpandableSectionCard({
    super.key,
    required this.isDark,
    required this.section,
    required this.isExpanded,
    required this.onTap,
  });

  final bool isDark;
  final TermsConditionsSection section;
  final bool isExpanded;
  final VoidCallback onTap;

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
  const TermsSectionHeader({
    super.key,
    required this.isDark,
    required this.section,
    required this.isExpanded,
  });

  final bool isDark;
  final TermsConditionsSection section;
  final bool isExpanded;

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
