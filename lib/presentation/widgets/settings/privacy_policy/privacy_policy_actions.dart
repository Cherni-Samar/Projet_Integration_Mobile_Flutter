import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';

class PrivacyDownloadButton extends StatelessWidget {
  const PrivacyDownloadButton({
    super.key,
    required this.l10n,
    required this.isDark,
    required this.onPressed,
  });

  final AppLocalizations l10n;
  final bool isDark;
  final VoidCallback onPressed;

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
  const PrivacyAcceptButton({
    super.key,
    required this.l10n,
    required this.isDark,
    required this.onPressed,
  });

  final AppLocalizations l10n;
  final bool isDark;
  final VoidCallback onPressed;

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
  const PrivacyShadowButtonFrame({
    super.key,
    required this.shadowColor,
    required this.child,
  });

  final Color shadowColor;
  final Widget child;

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
