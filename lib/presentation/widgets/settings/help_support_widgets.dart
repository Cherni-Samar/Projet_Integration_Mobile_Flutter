import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';

class HelpSupportHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isDark;
  final VoidCallback onBackPressed;

  const HelpSupportHeader({
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
                  l10n.helpSupportTitle,
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
                  l10n.helpSupportSubtitle,
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

class HelpSupportContent extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isDark;
  final VoidCallback onEmailSupportPressed;

  const HelpSupportContent({
    super.key,
    required this.l10n,
    required this.isDark,
    required this.onEmailSupportPressed,
  });

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

class HelpSupportHero extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isDark;

  const HelpSupportHero({super.key, required this.l10n, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, const Color(0xFFF9FAFB)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? const Color(0xFFCDFF00).withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFFCDFF00).withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFCDFF00), Color(0xFFAADD00)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFCDFF00).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.support_agent,
              size: 40,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.helpSupportNeedHelpTitle,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.helpSupportNeedHelpDesc,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.6),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class HelpSupportSectionTitle extends StatelessWidget {
  final bool isDark;
  final String title;

  const HelpSupportSectionTitle({
    super.key,
    required this.title,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class HelpSupportFaqItem extends StatelessWidget {
  final bool isDark;
  final String question;
  final String answer;

  const HelpSupportFaqItem({
    super.key,
    required this.isDark,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: helpSupportCardDecoration(isDark),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFCDFF00).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.help_outline,
              color: Color(0xFFCDFF00),
              size: 20,
            ),
          ),
          title: Text(
            question,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(68, 0, 16, 16),
              child: Text(
                answer,
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.black.withValues(alpha: 0.7),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HelpSupportContactCard extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String description;
  final VoidCallback onTap;

  const HelpSupportContactCard({
    super.key,
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: helpSupportCardDecoration(isDark),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: iconColor.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: iconColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.copy,
          color: isDark
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.3),
          size: 20,
        ),
      ),
    );
  }
}

BoxDecoration helpSupportCardDecoration(bool isDark) {
  return BoxDecoration(
    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.1),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
