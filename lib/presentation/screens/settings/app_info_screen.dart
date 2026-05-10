import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/providers/theme_provider.dart';
import 'package:e_team/presentation/widgets/settings/app_info/app_info_cards.dart';
import 'package:e_team/presentation/widgets/settings/app_info/app_info_header.dart';
import 'package:e_team/presentation/widgets/settings/app_info/app_info_hero.dart';
import 'package:e_team/presentation/widgets/settings/app_info/app_info_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

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
            AppInfoHeader(
              isDark: isDark,
              l10n: l10n,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    AppInfoHero(isDark: isDark, l10n: l10n),
                    const SizedBox(height: 32),
                    AppInfoAboutCard(isDark: isDark, l10n: l10n),
                    const SizedBox(height: 40),
                    AppInfoCard(
                      isDark: isDark,
                      icon: Icons.star_outline,
                      iconColor: const Color(0xFFFBBF24),
                      title: l10n.appInfoFeaturesTitle,
                      subtitle: l10n.appInfoFeaturesSubtitle,
                      items: [
                        l10n.appInfoFeatureMarketplace,
                        l10n.appInfoFeatureHr,
                        l10n.appInfoFeatureFinancial,
                        l10n.appInfoFeatureDocs,
                        l10n.appInfoFeaturePlanning,
                        l10n.appInfoFeatureCommunication,
                      ],
                    ),
                    const SizedBox(height: 20),
                    AppInfoCard(
                      isDark: isDark,
                      icon: Icons.code_outlined,
                      iconColor: const Color(0xFF3B82F6),
                      title: l10n.appInfoTechTitle,
                      subtitle: l10n.appInfoTechSubtitle,
                      items: [
                        l10n.appInfoTechFlutter,
                        l10n.appInfoTechNode,
                        l10n.appInfoTechMongo,
                        l10n.appInfoTechProvider,
                        l10n.appInfoTechJwt,
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      l10n.appInfoConnectWithUs,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        AppInfoSocialButton(
                          isDark: isDark,
                          icon: Icons.email_outlined,
                          label: l10n.appInfoEmailLabel,
                          color: const Color(0xFF3B82F6),
                          onTap: () => _showComingSoon(context, isDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        AppInfoLegalLink(
                          isDark: isDark,
                          label: l10n.appInfoLegalTerms,
                          onTap: () => Navigator.pushNamed(context, '/terms'),
                        ),
                        AppInfoLegalSeparator(isDark: isDark),
                        AppInfoLegalLink(
                          isDark: isDark,
                          label: l10n.appInfoLegalPrivacy,
                          onTap: () => Navigator.pushNamed(context, '/privacy'),
                        ),
                        AppInfoLegalSeparator(isDark: isDark),
                        AppInfoLegalLink(
                          isDark: isDark,
                          label: l10n.appInfoLegalLicenses,
                          onTap: () => showLicensePage(
                            context: context,
                            applicationName: 'E-Team',
                            applicationVersion: '1.0.0',
                            applicationLegalese: l10n.appInfoLegalese,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.appInfoCopyright,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.black.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.appInfoMadeWith,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.black.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 12),
            Text(l10n.appInfoComingSoon),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
