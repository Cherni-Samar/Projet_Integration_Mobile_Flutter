import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:e_team/l10n/app_localizations.dart';

class AgentMarketplaceCard extends StatelessWidget {
  final Map<String, dynamic> agent;
  final int index;
  final PageController pageController;
  final double currentPage;
  final bool isDark;
  final VoidCallback onTap;

  const AgentMarketplaceCard({
    Key? key,
    required this.agent,
    required this.index,
    required this.pageController,
    required this.currentPage,
    required this.isDark,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
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
                    vertical: 24,
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
                          ? (agent['color'] as Color).withOpacity(0.5)
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (agent['color'] as Color).withOpacity(
                          isCenter ? 0.35 : 0.15,
                        ),
                        blurRadius: isCenter ? 40 : 20,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              (agent['color'] as Color).withOpacity(0.25),
                              (agent['color'] as Color).withOpacity(0.08),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: agent['color'] as Color,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (agent['color'] as Color).withOpacity(0.4),
                              blurRadius: 25,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(55),
                            child: Image.asset(
                              agent['icon'],
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          agent['name'],
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              (agent['color'] as Color).withOpacity(0.15),
                              (agent['color'] as Color).withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (agent['color'] as Color).withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          agent['role'],
                          style: TextStyle(
                            color: agent['color'] as Color,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...List.generate(5, (i) {
                            return Icon(
                              i < (agent['rating'] as double).floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: const Color(0xFFFBBF24),
                              size: 18,
                            );
                          }),
                          const SizedBox(width: 6),
                          Text(
                            '${agent['rating']}',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: isDark
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFCDFF00),
                                    Color(0xFFAADD00),
                                  ],
                                )
                              : const LinearGradient(
                                  colors: [Colors.black, Color(0xFF1A1A1A)],
                                ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? const Color(0xFFCDFF00).withOpacity(0.4)
                                  : Colors.black.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          l10n.agentMarketplacePriceFrom(agent['price']),
                          style: TextStyle(
                            color: isDark
                                ? Colors.black
                                : const Color(0xFFCDFF00),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
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