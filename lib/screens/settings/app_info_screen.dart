import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: isDark
                    ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1E1E1E),
                    const Color(0xFF2A2A2A),
                  ],
                )
                    : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    const Color(0xFFF9FAFB),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1),
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
                          l10n.appInfoTitle,
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
                          l10n.appInfoSubtitle,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withOpacity(0.5)
                                : Colors.black.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // App Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFCDFF00),
                            const Color(0xFFAADD00),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFCDFF00).withOpacity(0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '🤖',
                          style: const TextStyle(fontSize: 60),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // App Name
                    Text(
                      'E-Team',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tagline
                    Text(
                      l10n.appInfoTagline,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withOpacity(0.6)
                            : Colors.black.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Version badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                            const Color(0xFFCDFF00).withOpacity(0.2),
                            const Color(0xFFAADD00).withOpacity(0.15),
                          ]
                              : [
                            const Color(0xFFCDFF00).withOpacity(0.3),
                            const Color(0xFFAADD00).withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFCDFF00).withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        l10n.appInfoVersion('1.0.0'),
                        style: TextStyle(
                          color: isDark ? const Color(0xFFCDFF00) : Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // App Description
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFFCDFF00),
                                      const Color(0xFFAADD00),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.info_outline,
                                  color: Colors.black,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.appInfoAboutSectionTitle,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.appInfoAboutDescription,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.black.withOpacity(0.7),
                              fontSize: 15,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),



                    const SizedBox(height: 20),

                    // Features Section
                    _buildInfoCard(
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

                    // Tech Stack
                    _buildInfoCard(
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

                    // Social Links
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
                        _buildSocialButton(
                          isDark: isDark,
                          icon: Icons.email_outlined,
                          label: l10n.appInfoEmailLabel,
                          color: const Color(0xFF3B82F6),
                          onTap: () => _showComingSoon(context, isDark),
                        ),


                      ],
                    ),

                    const SizedBox(height: 32),

                    // Legal Links
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        _buildLegalLink(
                          isDark: isDark,
                          label: l10n.appInfoLegalTerms,
                          onTap: () => Navigator.pushNamed(context, '/terms'),
                        ),
                        Text(
                          '•',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withOpacity(0.3)
                                : Colors.black.withOpacity(0.3),
                          ),
                        ),
                        _buildLegalLink(
                          isDark: isDark,
                          label: l10n.appInfoLegalPrivacy,
                          onTap: () => Navigator.pushNamed(context, '/privacy'),
                        ),
                        Text(
                          '•',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withOpacity(0.3)
                                : Colors.black.withOpacity(0.3),
                          ),
                        ),
                        _buildLegalLink(
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

                    // Copyright
                    Text(
                      l10n.appInfoCopyright,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withOpacity(0.5)
                            : Colors.black.withOpacity(0.5),
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      l10n.appInfoMadeWith,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withOpacity(0.5)
                            : Colors.black.withOpacity(0.5),
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

  Widget _buildInfoCard({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: iconColor.withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withOpacity(0.5)
                            : Colors.black.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withOpacity(0.8)
                            : Colors.black.withOpacity(0.8),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required bool isDark,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withOpacity(0.7)
                  : Colors.black.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalLink({
    required bool isDark,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? const Color(0xFFCDFF00) : Colors.black,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}