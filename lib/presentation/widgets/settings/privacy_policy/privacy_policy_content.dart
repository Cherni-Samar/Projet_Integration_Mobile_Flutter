import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/models/settings/privacy_policy_section.dart';
import 'package:e_team/presentation/widgets/settings/privacy_policy/privacy_policy_actions.dart';
import 'package:e_team/presentation/widgets/settings/privacy_policy/privacy_policy_sections.dart';

class PrivacyPolicyContent extends StatelessWidget {
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

  final AppLocalizations l10n;
  final bool isDark;
  final List<PrivacyPolicySection> sections;
  final String? expandedSection;
  final ValueChanged<String> onSectionPressed;
  final VoidCallback onDownloadPressed;
  final VoidCallback onAcceptPressed;

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
  const PrivacyPolicyBadge({
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
  const PrivacyPolicyIntro({
    super.key,
    required this.l10n,
    required this.isDark,
  });

  final AppLocalizations l10n;
  final bool isDark;

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
