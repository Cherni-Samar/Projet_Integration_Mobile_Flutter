import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/models/settings/terms_conditions_section.dart';
import 'package:e_team/presentation/providers/theme_provider.dart';
import 'package:e_team/presentation/widgets/settings/terms_conditions/terms_conditions_content.dart';
import 'package:e_team/presentation/widgets/settings/terms_conditions/terms_conditions_header.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
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
            TermsConditionsHeader(
              l10n: l10n,
              isDark: isDark,
              onBackPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: TermsConditionsContent(
                l10n: l10n,
                isDark: isDark,
                sections: sections,
                expandedSection: _expandedSection,
                onSectionPressed: _toggleSection,
                onAcceptPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TermsConditionsSection> _buildSections(AppLocalizations l10n) {
    return [
      TermsConditionsSection(
        icon: Icons.check_circle_outline,
        iconColor: const Color(0xFF10B981),
        title: l10n.termsSectionAcceptanceTitle,
        summary: l10n.termsSectionAcceptanceSummary,
        content: l10n.termsSectionAcceptanceContent,
      ),
      TermsConditionsSection(
        icon: Icons.smart_toy_outlined,
        iconColor: const Color(0xFFA855F7),
        title: l10n.termsSectionAiUsageTitle,
        summary: l10n.termsSectionAiUsageSummary,
        content: l10n.termsSectionAiUsageContent,
      ),
      TermsConditionsSection(
        icon: Icons.payments_outlined,
        iconColor: const Color(0xFFEC4899),
        title: l10n.termsSectionPaymentTitle,
        summary: l10n.termsSectionPaymentSummary,
        content: l10n.termsSectionPaymentContent,
      ),
      TermsConditionsSection(
        icon: Icons.shield_outlined,
        iconColor: const Color(0xFF6366F1),
        title: l10n.termsSectionLiabilityTitle,
        summary: l10n.termsSectionLiabilitySummary,
        content: l10n.termsSectionLiabilityContent,
      ),
      TermsConditionsSection(
        icon: Icons.contact_support_outlined,
        iconColor: const Color(0xFFCDFF00),
        title: l10n.termsSectionContactTitle,
        summary: l10n.termsSectionContactSummary,
        content: l10n.termsSectionContactContent,
      ),
    ];
  }

  void _toggleSection(String title) {
    setState(() {
      _expandedSection = _expandedSection == title ? null : title;
    });
  }
}
