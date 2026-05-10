import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/widgets/settings/help_support/help_support_cards.dart';

class HelpSupportContent extends StatelessWidget {
  const HelpSupportContent({
    super.key,
    required this.l10n,
    required this.isDark,
    required this.onEmailSupportPressed,
  });

  final AppLocalizations l10n;
  final bool isDark;
  final VoidCallback onEmailSupportPressed;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          HelpSupportHero(l10n: l10n, isDark: isDark),
          const SizedBox(height: 24),
          HelpSupportSectionTitle(
            title: l10n.helpSupportFaqSectionTitle,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          HelpSupportFaqItem(
            isDark: isDark,
            question: l10n.helpSupportFaqHireQuestion,
            answer: l10n.helpSupportFaqHireAnswer,
          ),
          HelpSupportFaqItem(
            isDark: isDark,
            question: l10n.helpSupportFaqPaymentQuestion,
            answer: l10n.helpSupportFaqPaymentAnswer,
          ),
          HelpSupportFaqItem(
            isDark: isDark,
            question: l10n.helpSupportFaqCancelQuestion,
            answer: l10n.helpSupportFaqCancelAnswer,
          ),
          HelpSupportFaqItem(
            isDark: isDark,
            question: l10n.helpSupportFaqUpdateProfileQuestion,
            answer: l10n.helpSupportFaqUpdateProfileAnswer,
          ),
          HelpSupportFaqItem(
            isDark: isDark,
            question: l10n.helpSupportFaqDataSecureQuestion,
            answer: l10n.helpSupportFaqDataSecureAnswer,
          ),
          const SizedBox(height: 32),
          HelpSupportSectionTitle(
            title: l10n.helpSupportContactSectionTitle,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          HelpSupportContactCard(
            isDark: isDark,
            icon: Icons.email_outlined,
            iconColor: const Color(0xFF3B82F6),
            title: l10n.helpSupportEmailSupportTitle,
            subtitle: 'e-team@e-team.com',
            description: l10n.helpSupportEmailSupportDesc,
            onTap: onEmailSupportPressed,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
