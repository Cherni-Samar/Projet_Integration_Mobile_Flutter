import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  @override
  State<TermsAndConditionsScreen> createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
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
            // ✅ Header amélioré
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
                          l10n.termsTitle,
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
                          l10n.termsSubtitle,
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

            // ✅ Content avec sections expansibles
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
                              const Color(0xFFCDFF00).withOpacity(0.2),
                              const Color(0xFFA855F7).withOpacity(0.2),
                            ]
                                : [
                              const Color(0xFFCDFF00).withOpacity(0.3),
                              const Color(0xFFA855F7).withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFFCDFF00).withOpacity(0.3)
                                : const Color(0xFFCDFF00).withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: isDark ? const Color(0xFFCDFF00) : Colors.black,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.termsBadge,
                              style: TextStyle(
                                color: isDark ? const Color(0xFFCDFF00) : Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ✅ Sections minimisées - Gardez seulement celles-ci :

                    _buildExpandableSection(
                      isDark: isDark,
                      icon: Icons.check_circle_outline,
                      iconColor: const Color(0xFF10B981),
                      title: l10n.termsSectionAcceptanceTitle,
                      summary: l10n.termsSectionAcceptanceSummary,
                      content: l10n.termsSectionAcceptanceContent,
                    ),

                    _buildExpandableSection(
                      isDark: isDark,
                      icon: Icons.smart_toy_outlined,
                      iconColor: const Color(0xFFA855F7),
                      title: l10n.termsSectionAiUsageTitle,
                      summary: l10n.termsSectionAiUsageSummary,
                      content: l10n.termsSectionAiUsageContent,
                    ),

                    _buildExpandableSection(
                      isDark: isDark,
                      icon: Icons.payments_outlined,
                      iconColor: const Color(0xFFEC4899),
                      title: l10n.termsSectionPaymentTitle,
                      summary: l10n.termsSectionPaymentSummary,
                      content: l10n.termsSectionPaymentContent,
                    ),

                    _buildExpandableSection(
                      isDark: isDark,
                      icon: Icons.shield_outlined,
                      iconColor: const Color(0xFF6366F1),
                      title: l10n.termsSectionLiabilityTitle,
                      summary: l10n.termsSectionLiabilitySummary,
                      content: l10n.termsSectionLiabilityContent,
                    ),

                    _buildExpandableSection(
                      isDark: isDark,
                      icon: Icons.contact_support_outlined,
                      iconColor: const Color(0xFFCDFF00),
                      title: l10n.termsSectionContactTitle,
                      summary: l10n.termsSectionContactSummary,
                      content: l10n.termsSectionContactContent,
                    ),
                    const SizedBox(height: 32),

                    // ✅ Accept button amélioré
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
                              Icon(
                                Icons.check_circle,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.termsAcceptButton,
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

  // ✅ Section expansible avec animation
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
                      // Icône colorée
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
                      // Titre et résumé
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
                      // Icône expand/collapse
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
                  // Contenu expansible
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