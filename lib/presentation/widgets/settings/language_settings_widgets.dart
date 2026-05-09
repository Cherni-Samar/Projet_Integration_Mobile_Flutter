import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/models/settings/language_option.dart';

class LanguageSettingsHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isDark;
  final VoidCallback onBackPressed;

  const LanguageSettingsHeader({
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
                  l10n.languageTitle,
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
                  l10n.languageSubtitle,
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

class LanguageInfoBanner extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isDark;

  const LanguageInfoBanner({
    super.key,
    required this.l10n,
    required this.isDark,
  });

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

class LanguageOptionsList extends StatelessWidget {
  final bool isDark;
  final List<LanguageOption> languages;
  final String selectedLanguageCode;
  final ValueChanged<LanguageOption> onLanguageSelected;

  const LanguageOptionsList({
    super.key,
    required this.isDark,
    required this.languages,
    required this.selectedLanguageCode,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: languages.length,
      itemBuilder: (context, index) {
        final language = languages[index];
        final isSelected = selectedLanguageCode == language.code;

        return LanguageOptionCard(
          isDark: isDark,
          language: language,
          isSelected: isSelected,
          onTap: () => onLanguageSelected(language),
        );
      },
    );
  }
}

class LanguageOptionCard extends StatelessWidget {
  final bool isDark;
  final LanguageOption language;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageOptionCard({
    super.key,
    required this.isDark,
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFFCDFF00).withValues(alpha: 0.15),
                        const Color(0xFFAADD00).withValues(alpha: 0.1),
                      ]
                    : [
                        const Color(0xFFCDFF00).withValues(alpha: 0.2),
                        const Color(0xFFAADD00).withValues(alpha: 0.15),
                      ],
              )
            : null,
        color: isSelected
            ? null
            : isDark
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? const Color(0xFFCDFF00)
              : isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? const Color(0xFFCDFF00).withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: isSelected ? 20 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                LanguageFlagBox(
                  flag: language.flag,
                  isDark: isDark,
                  isSelected: isSelected,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LanguageOptionText(
                    language: language,
                    isDark: isDark,
                    isSelected: isSelected,
                  ),
                ),
                LanguageSelectionIndicator(
                  isDark: isDark,
                  isSelected: isSelected,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LanguageFlagBox extends StatelessWidget {
  final String flag;
  final bool isDark;
  final bool isSelected;

  const LanguageFlagBox({
    super.key,
    required this.flag,
    required this.isDark,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFFCDFF00) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Center(child: Text(flag, style: const TextStyle(fontSize: 32))),
    );
  }
}

class LanguageOptionText extends StatelessWidget {
  final LanguageOption language;
  final bool isDark;
  final bool isSelected;

  const LanguageOptionText({
    super.key,
    required this.language,
    required this.isDark,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          language.nativeName,
          style: TextStyle(
            color: isSelected
                ? (isDark ? const Color(0xFFCDFF00) : Colors.black)
                : (isDark ? Colors.white : Colors.black),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          language.name,
          style: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.5),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class LanguageSelectionIndicator extends StatelessWidget {
  final bool isDark;
  final bool isSelected;

  const LanguageSelectionIndicator({
    super.key,
    required this.isDark,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFCDFF00), Color(0xFFAADD00)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFCDFF00).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.check, color: Colors.black, size: 20),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}

class LanguageApplyButton extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isDark;
  final VoidCallback onPressed;

  const LanguageApplyButton({
    super.key,
    required this.l10n,
    required this.isDark,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
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
                  l10n.languageApplyButton,
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
      ),
    );
  }
}

class LanguageConfirmationDialog extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isDark;
  final LanguageOption selectedLanguage;
  final VoidCallback onCancel;
  final VoidCallback onApply;

  const LanguageConfirmationDialog({
    super.key,
    required this.l10n,
    required this.isDark,
    required this.selectedLanguage,
    required this.onCancel,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Text(selectedLanguage.flag, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.languageChangeDialogTitle,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        l10n.languageChangeDialogMessage(selectedLanguage.nativeName),
        style: TextStyle(
          color: isDark
              ? Colors.white.withValues(alpha: 0.7)
              : Colors.black.withValues(alpha: 0.7),
          fontSize: 15,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(
            l10n.commonCancel,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.5),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onApply,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFFCDFF00) : Colors.black,
            foregroundColor: isDark ? Colors.black : const Color(0xFFCDFF00),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(l10n.commonApply),
        ),
      ],
    );
  }
}
