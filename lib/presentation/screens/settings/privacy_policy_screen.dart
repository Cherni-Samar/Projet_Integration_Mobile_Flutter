import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/models/settings/privacy_policy_section.dart';
import 'package:e_team/presentation/providers/theme_provider.dart';
import 'package:e_team/presentation/widgets/settings/privacy_policy_widgets.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  String? _expandedSection;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final l10n = AppLocalizations.of(context)!;
    final sections = _buildSections(l10n);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            PrivacyPolicyHeader(
              l10n: l10n,
              isDark: isDark,
              onBackPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: PrivacyPolicyContent(
                l10n: l10n,
                isDark: isDark,
                sections: sections,
                expandedSection: _expandedSection,
                onSectionPressed: _toggleSection,
                onDownloadPressed: () => _showDownloadSnackBar(
                  context: context,
                  l10n: l10n,
                  isDark: isDark,
                ),
                onAcceptPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PrivacyPolicySection> _buildSections(AppLocalizations l10n) {
    return [
      PrivacyPolicySection(
        icon: Icons.info_outline,
        iconColor: const Color(0xFF3B82F6),
        title: l10n.privacySectionDataCollectedTitle,
        summary: l10n.privacySectionDataCollectedSummary,
        content: l10n.privacySectionDataCollectedContent,
      ),
      PrivacyPolicySection(
        icon: Icons.visibility_outlined,
        iconColor: const Color(0xFF10B981),
        title: l10n.privacySectionDataUsageTitle,
        summary: l10n.privacySectionDataUsageSummary,
        content: l10n.privacySectionDataUsageContent,
      ),
      PrivacyPolicySection(
        icon: Icons.security_outlined,
        iconColor: const Color(0xFFF59E0B),
        title: l10n.privacySectionSecurityTitle,
        summary: l10n.privacySectionSecuritySummary,
        content: l10n.privacySectionSecurityContent,
      ),
      PrivacyPolicySection(
        icon: Icons.verified_user_outlined,
        iconColor: const Color(0xFF14B8A6),
        title: l10n.privacySectionRightsTitle,
        summary: l10n.privacySectionRightsSummary,
        content: l10n.privacySectionRightsContent,
      ),
      PrivacyPolicySection(
        icon: Icons.contact_support_outlined,
        iconColor: const Color(0xFFCDFF00),
        title: l10n.privacySectionContactDpoTitle,
        summary: l10n.privacySectionContactDpoSummary,
        content: l10n.privacySectionContactDpoContent,
      ),
    ];
  }

  void _toggleSection(String title) {
    setState(() {
      _expandedSection = _expandedSection == title ? null : title;
    });
  }

  void _showDownloadSnackBar({
    required BuildContext context,
    required AppLocalizations l10n,
    required bool isDark,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.download, color: Colors.white),
            const SizedBox(width: 12),
            Text(l10n.privacyDownloadSnack),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
