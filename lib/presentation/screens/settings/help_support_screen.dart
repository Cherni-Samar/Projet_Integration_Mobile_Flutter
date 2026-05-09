import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/providers/theme_provider.dart';
import 'package:e_team/presentation/widgets/settings/help_support_widgets.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  void _copyToClipboard(BuildContext context, String text, String label) {
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(l10n.helpSupportCopiedToClipboard(label)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
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
            HelpSupportHeader(
              l10n: l10n,
              isDark: isDark,
              onBackPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: HelpSupportContent(
                l10n: l10n,
                isDark: isDark,
                onEmailSupportPressed: () => _copyToClipboard(
                  context,
                  'e-team@e-team.com',
                  l10n.authEmailLabel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
