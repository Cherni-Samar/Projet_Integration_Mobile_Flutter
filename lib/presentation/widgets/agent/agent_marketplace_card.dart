import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:e_team/presentation/widgets/agent/agent_marketplace_card_stats.dart';
import 'package:e_team/presentation/utils/domain_model_color_extensions.dart';

class AgentMarketplaceCard extends StatelessWidget {
  final Map<String, dynamic> agent;
  final int index;
  final PageController pageController;
  final double currentPage;
  final bool isDark;
  final VoidCallback onTap;

  const AgentMarketplaceCard({
    super.key,
    required this.agent,
    required this.index,
    required this.pageController,
    required this.currentPage,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final agentColor = colorFromValue(agent['color']);

    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        double value = 0.0;
        if (pageController.position.haveDimensions) {
          value = index - currentPage;
          value = (value * 0.038).clamp(-1, 1);
        }

        final isCenter = (currentPage - index).abs() < 0.5;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(value * math.pi),
          alignment: Alignment.center,
          child: Opacity(
            opacity: isCenter ? 1.0 : 0.6,
            child: Transform.scale(
              scale: isCenter ? 1.0 : 0.88,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
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
                            colors: [Colors.white, Color(0xFFFAFAFA)],
                          ),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: isCenter
                          ? agentColor.withValues(alpha: 0.3)
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: agentColor.withValues(
                          alpha: isCenter ? 0.25 : 0.12,
                        ),
                        blurRadius: isCenter ? 30 : 15,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 20,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Avatar - Reduced from 90 to 75
                            Container(
                              width: 75,
                              height: 75,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    agentColor.withValues(alpha: 0.2),
                                    agentColor.withValues(alpha: 0.05),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: agentColor,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: agentColor.withValues(alpha: 0.3),
                                    blurRadius: 18,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(37.5),
                                  child: Image.asset(
                                    agent['icon'],
                                    width: 75,
                                    height: 75,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12), // Reduced from 16
                            // Agent Name
                            Text(
                              agent['name'],
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 22, // Reduced from 24
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6), // Reduced from 8
                            // Role Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10, // Reduced from 12
                                vertical: 4, // Reduced from 5
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    agentColor.withValues(alpha: 0.15),
                                    agentColor.withValues(alpha: 0.08),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: agentColor.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                agent['role'],
                                style: TextStyle(
                                  color: agentColor,
                                  fontSize: 9, // Reduced from 10
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 10), // Reduced from 12
                            // Description
                            Text(
                              agent['description'],
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : Colors.black.withValues(alpha: 0.6),
                                fontSize: 11, // Reduced from 12
                                fontWeight: FontWeight.w500,
                                height: 1.3, // Reduced from 1.4
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12), // Reduced from 16
                            // Stats Section
                            Container(
                              padding: const EdgeInsets.all(
                                10,
                              ), // Reduced from 12
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.08),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Activity Today',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.5)
                                          : Colors.black.withValues(alpha: 0.5),
                                      fontSize: 9, // Reduced from 10
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8), // Reduced from 10
                                  AgentMarketplaceStatsRow(
                                    agentName: agent['name'] as String,
                                    agentColor: agentColor,
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10), // Reduced from 14
                            // Active Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14, // Reduced from 16
                                vertical: 6, // Reduced from 8
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(
                                      0xFF10B981,
                                    ).withValues(alpha: 0.15),
                                    const Color(
                                      0xFF10B981,
                                    ).withValues(alpha: 0.08),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7, // Reduced from 8
                                    height: 7, // Reduced from 8
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF10B981,
                                          ).withValues(alpha: 0.6),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6), // Reduced from 8
                                  Text(
                                    'Active',
                                    style: TextStyle(
                                      color: const Color(0xFF10B981),
                                      fontSize: 11, // Reduced from 12
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
