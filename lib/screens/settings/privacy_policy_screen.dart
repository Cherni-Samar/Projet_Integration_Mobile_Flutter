import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  String? _expandedSection;

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
                          l10n.privacyTitle,
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
                          l10n.privacySubtitle,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Last updated badge
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                              const Color(0xFF8B5CF6).withOpacity(0.2),
                              const Color(0xFFEC4899).withOpacity(0.2),
                            ]
                                : [
                              const Color(0xFF8B5CF6).withOpacity(0.2),
                              const Color(0xFFEC4899).withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF8B5CF6).withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 16,
                              color: const Color(0xFF8B5CF6),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.privacyBadge,
                              style: TextStyle(
                                color: isDark ? const Color(0xFF8B5CF6) : const Color(0xFF8B5CF6),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Intro text
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF8B5CF6).withOpacity(0.3)
                              : const Color(0xFF8B5CF6).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF8B5CF6),
                                  const Color(0xFFEC4899),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.lock_outline,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              l10n.privacyIntro,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ✅ Sections minimisées - Gardez seulement celles-ci :

                    _buildExpandableSection(
                      isDark: isDark,
                      icon: Icons.info_outline,
                      iconColor: const Color(0xFF3B82F6),
                      title: l10n.privacySectionDataCollectedTitle,
                      summary: l10n.privacySectionDataCollectedSummary,
                      content: l10n.privacySectionDataCollectedContent,
                    ),

                    _buildExpandableSection(
                      isDark: isDark,
                      icon: Icons.visibility_outlined,
                      iconColor: const Color(0xFF10B981),
                      title: l10n.privacySectionDataUsageTitle,
                      summary: l10n.privacySectionDataUsageSummary,
                      content: l10n.privacySectionDataUsageContent,
                    ),

                    _buildExpandableSection(
                      isDark: isDark,
                      icon: Icons.security_outlined,
                      iconColor: const Color(0xFFF59E0B),
                      title: l10n.privacySectionSecurityTitle,
                      summary: l10n.privacySectionSecuritySummary,
                      content: l10n.privacySectionSecurityContent,
                    ),

                    _buildExpandableSection(
                      isDark: isDark,
                      icon: Icons.verified_user_outlined,
                      iconColor: const Color(0xFF14B8A6),
                      title: l10n.privacySectionRightsTitle,
                      summary: l10n.privacySectionRightsSummary,
                      content: l10n.privacySectionRightsContent,
                    ),

                    _buildExpandableSection(
                      isDark: isDark,
                      icon: Icons.contact_support_outlined,
                      iconColor: const Color(0xFFCDFF00),
                      title: l10n.privacySectionContactDpoTitle,
                      summary: l10n.privacySectionContactDpoSummary,
                      content: l10n.privacySectionContactDpoContent,
                    ),

                    const SizedBox(height: 32),

                    // Download button
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? const Color(0xFF8B5CF6).withOpacity(0.3)
                                : Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.download, color: Colors.white),
                                    const SizedBox(width: 12),
                                    Text(l10n.privacyDownloadSnack),
                                  ],
                                ),
                                backgroundColor: isDark
                                    ? const Color(0xFF2A2A2A)
                                    : Colors.black87,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.download_outlined, size: 24),
                          label: Text(
                            l10n.privacyDownloadButton,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? const Color(0xFF8B5CF6)
                                : Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Accept button
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? const Color(0xFFCDFF00).withOpacity(0.3)
                                : Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? const Color(0xFFCDFF00)
                                : Colors.black,
                            foregroundColor: isDark ? Colors.black : const Color(0xFFCDFF00),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                l10n.privacyUnderstandButton,
                                style: TextStyle(
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

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String summary,
    required String content,
  }) {
    final isExpanded = _expandedSection == title;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isDark
              ? isExpanded
              ? const Color(0xFF1E1E1E)
              : Colors.white.withOpacity(0.05)
              : isExpanded
              ? Colors.white
              : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded
                ? iconColor.withOpacity(0.5)
                : isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            width: isExpanded ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isExpanded
                  ? iconColor.withOpacity(isDark ? 0.2 : 0.1)
                  : Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: isExpanded ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _expandedSection = isExpanded ? null : title;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              summary,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white.withOpacity(0.6)
                                    : Colors.black.withOpacity(0.6),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        turns: isExpanded ? 0.5 : 0,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: isDark
                              ? Colors.white.withOpacity(0.5)
                              : Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 16, left: 52),
                      child: Text(
                        content,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withOpacity(0.8)
                              : Colors.black.withOpacity(0.7),
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}