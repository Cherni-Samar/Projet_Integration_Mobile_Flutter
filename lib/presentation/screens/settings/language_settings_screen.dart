import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/models/settings/language_option.dart';
import 'package:e_team/presentation/providers/locale_provider.dart';
import 'package:e_team/presentation/providers/theme_provider.dart';
import 'package:e_team/presentation/widgets/settings/language_settings/language_actions.dart';
import 'package:e_team/presentation/widgets/settings/language_settings/language_header.dart';
import 'package:e_team/presentation/widgets/settings/language_settings/language_info_banner.dart';
import 'package:e_team/presentation/widgets/settings/language_settings/language_options.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguage = 'en'; // Par défaut: Anglais
  bool _didInitFromProvider = false;

  final List<LanguageOption> _languages = [
    const LanguageOption(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇬🇧',
    ),
    const LanguageOption(
      code: 'fr',
      name: 'French',
      nativeName: 'Français',
      flag: '🇫🇷',
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitFromProvider) return;

    final localeProvider = Provider.of<LocaleProvider>(context);
    final code = localeProvider.locale?.languageCode;
    if (code != null && code.isNotEmpty && code != _selectedLanguage) {
      _selectedLanguage = code;
    }
    _didInitFromProvider = true;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            LanguageSettingsHeader(
              l10n: l10n,
              isDark: isDark,
              onBackPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 24),
            LanguageInfoBanner(l10n: l10n, isDark: isDark),
            const SizedBox(height: 24),
            Expanded(
              child: LanguageOptionsList(
                isDark: isDark,
                languages: _languages,
                selectedLanguageCode: _selectedLanguage,
                onLanguageSelected: (language) {
                  setState(() => _selectedLanguage = language.code);
                },
              ),
            ),
            LanguageApplyButton(
              l10n: l10n,
              isDark: isDark,
              onPressed: () => _showConfirmationDialog(isDark),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(bool isDark) {
    final selectedLang = _languages.firstWhere(
      (lang) => lang.code == _selectedLanguage,
    );

    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => LanguageConfirmationDialog(
        l10n: l10n,
        isDark: isDark,
        selectedLanguage: selectedLang,
        onCancel: () => Navigator.pop(context),
        onApply: () => _applyLanguage(selectedLang, l10n),
      ),
    );
  }

  Future<void> _applyLanguage(
    LanguageOption selectedLanguage,
    AppLocalizations l10n,
  ) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    await localeProvider.setLocale(Locale(_selectedLanguage));
    if (!context.mounted) return;

    navigator.pop(); // Fermer dialog
    navigator.pop(); // Retour à settings

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(selectedLanguage.flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.languageChangedSnack(selectedLanguage.nativeName),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
