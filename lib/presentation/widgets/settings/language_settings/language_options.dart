import 'package:flutter/material.dart';

import 'package:e_team/presentation/models/settings/language_option.dart';

class LanguageOptionsList extends StatelessWidget {
  const LanguageOptionsList({
    super.key,
    required this.isDark,
    required this.languages,
    required this.selectedLanguageCode,
    required this.onLanguageSelected,
  });

  final bool isDark;
  final List<LanguageOption> languages;
  final String selectedLanguageCode;
  final ValueChanged<LanguageOption> onLanguageSelected;

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
  const LanguageOptionCard({
    super.key,
    required this.isDark,
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final bool isDark;
  final LanguageOption language;
  final bool isSelected;
  final VoidCallback onTap;

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
  const LanguageFlagBox({
    super.key,
    required this.flag,
    required this.isDark,
    required this.isSelected,
  });

  final String flag;
  final bool isDark;
  final bool isSelected;

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
  const LanguageOptionText({
    super.key,
    required this.language,
    required this.isDark,
    required this.isSelected,
  });

  final LanguageOption language;
  final bool isDark;
  final bool isSelected;

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
  const LanguageSelectionIndicator({
    super.key,
    required this.isDark,
    required this.isSelected,
  });

  final bool isDark;
  final bool isSelected;

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
