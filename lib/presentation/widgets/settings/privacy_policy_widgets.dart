import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/models/settings/privacy_policy_section.dart';

class PrivacyPolicyHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isDark;
  final VoidCallback onBackPressed;

  const PrivacyPolicyHeader({
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
                  l10n.privacyTitle,
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
                  l10n.privacySubtitle,
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

class PrivacyPolicyContent extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isDark;
  final List<PrivacyPolicySection> sections;
  final String? expandedSection;
  final ValueChanged<String> onSectionPressed;
  final VoidCallback onDownloadPressed;
  final VoidCallback onAcceptPressed;

  const PrivacyPolicyContent({
    super.key,
    required this.l10n,
    required this.isDark,
    required this.sections,
    required this.expandedSection,
    required this.onSectionPressed,
    required this.onDownloadPressed,
    required this.onAcceptPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrivacyPolicyBadge(l10n: l10n, isDark: isDark),
          const SizedBox(height: 24),
          PrivacyPolicyIntro(l10n: l10n, isDark: isDark),
          const SizedBox(height: 24),
          ...sections.map(
            (section) => PrivacyExpandableSectionCard(
              isDark: isDark,
              section: section,
              isExpanded: expandedSection == section.title,
              onTap: () => onSectionPressed(section.title),
            ),
          ),
          const SizedBox(height: 32),
          PrivacyDownloadButton(
            l10n: l10n,
            isDark: isDark,
            onPressed: onDownloadPressed,
          ),
          const SizedBox(height: 12),
          PrivacyAcceptButton(
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

class PrivacyPolicyBadge extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isDark;

  const PrivacyPolicyBadge({
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
            colors: [
              const Color(0xFF8B5CF6).withValues(alpha: 0.2),
              const Color(0xFFEC4899).withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shield_outlined,
              size: 16,
              color: Color(0xFF8B5CF6),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.privacyBadge,
              style: const TextStyle(
                color: Color(0xFF8B5CF6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrivacyPolicyIntro extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isDark;

  const PrivacyPolicyIntro({
    super.key,
    required this.l10n,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF8B5CF6).withValues(alpha: 0.3)
              : const Color(0xFF8B5CF6).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lock_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              l10n.privacyIntro,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PrivacyExpandableSectionCard extends StatelessWidget {
  final bool isDark;
  final PrivacyPolicySection section;
  final bool isExpanded;
  final VoidCallback onTap;

  const PrivacyExpandableSectionCard({
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
        decoration: BoxDecoration(
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
                ? section.iconColor.withValues(alpha: 0.5)
                : isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            width: isExpanded ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isExpanded
                  ? section.iconColor.withValues(alpha: isDark ? 0.2 : 0.1)
                  : Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: isExpanded ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
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
                  PrivacyExpandableSectionHeader(
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

class PrivacyExpandableSectionHeader extends StatelessWidget {
  final bool isDark;
  final PrivacyPolicySection section;
  final bool isExpanded;

  const PrivacyExpandableSectionHeader({
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

class PrivacyDownloadButton extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isDark;
  final VoidCallback onPressed;

  const PrivacyDownloadButton({
    super.key,
    required this.l10n,
    required this.isDark,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return PrivacyShadowButtonFrame(
      shadowColor: isDark
          ? const Color(0xFF8B5CF6).withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.1),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.download_outlined, size: 24),
        label: Text(
          l10n.privacyDownloadButton,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? const Color(0xFF8B5CF6) : Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

class PrivacyAcceptButton extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isDark;
  final VoidCallback onPressed;

  const PrivacyAcceptButton({
    super.key,
    required this.l10n,
    required this.isDark,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return PrivacyShadowButtonFrame(
      shadowColor: isDark
          ? const Color(0xFFCDFF00).withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.1),
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
              l10n.privacyUnderstandButton,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrivacyShadowButtonFrame extends StatelessWidget {
  final Color shadowColor;
  final Widget child;

  const PrivacyShadowButtonFrame({
    super.key,
    required this.shadowColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(width: double.infinity, height: 56, child: child),
    );
  }
}
