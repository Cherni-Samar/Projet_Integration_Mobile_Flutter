import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/widgets/agent/agent_hire_fab.dart';
import 'package:e_team/presentation/widgets/agent/details/agent_details_app_bar.dart';
import 'package:e_team/presentation/widgets/agent/details/agent_details_body.dart';
import 'package:e_team/presentation/widgets/agent/details/agent_details_swipe_overlay.dart';
import 'package:flutter/material.dart';

class AgentDetailsScaffold extends StatelessWidget {
  const AgentDetailsScaffold({
    super.key,
    required this.l10n,
    required this.isDark,
    required this.isSwipeMode,
    required this.swipeItemCount,
    required this.currentIndex,
    required this.pageController,
    required this.pulseController,
    required this.agentName,
    required this.agentColor,
    required this.agentIcon,
    required this.description,
    required this.version,
    required this.isActive,
    required this.swipeDiff,
    required this.skills,
    required this.energyCosts,
    required this.multiScenarios,
    required this.onBackPressed,
    required this.onCartPressed,
    required this.onSharePressed,
    required this.onPrimaryActionPressed,
  });

  final AppLocalizations l10n;
  final bool isDark;
  final bool isSwipeMode;
  final int swipeItemCount;
  final int currentIndex;
  final PageController pageController;
  final AnimationController pulseController;
  final String agentName;
  final Color agentColor;
  final String agentIcon;
  final String description;
  final String version;
  final bool isActive;
  final double swipeDiff;
  final List<String> skills;
  final List<Map<String, dynamic>> energyCosts;
  final List<Map<String, dynamic>> multiScenarios;
  final VoidCallback onBackPressed;
  final VoidCallback onCartPressed;
  final VoidCallback onSharePressed;
  final VoidCallback onPrimaryActionPressed;

  @override
  Widget build(BuildContext context) {
    final abs = swipeDiff.abs().clamp(0.0, 1.0);
    final avatarDx = -swipeDiff * 28.0;
    final contentDy = 16.0 * abs;
    final contentOpacity = (1.0 - 0.25 * abs).clamp(0.75, 1.0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              AgentDetailsAppBar(
                l10n: l10n,
                isDark: isDark,
                onBackPressed: onBackPressed,
                onCartPressed: onCartPressed,
                onSharePressed: onSharePressed,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Opacity(
                    opacity: contentOpacity,
                    child: Transform.translate(
                      offset: Offset(0, contentDy),
                      child: AgentDetailsBody(
                        l10n: l10n,
                        isDark: isDark,
                        agentName: agentName,
                        agentColor: agentColor,
                        agentIcon: agentIcon,
                        description: description,
                        version: version,
                        skills: skills,
                        energyCosts: energyCosts,
                        multiScenarios: multiScenarios,
                        pulseController: pulseController,
                        avatarDx: avatarDx,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          AgentDetailsSwipeDotsOverlay(
            isVisible: isSwipeMode,
            itemCount: swipeItemCount,
            pageController: pageController,
            currentIndex: currentIndex,
            isDark: isDark,
          ),
        ],
      ),
      floatingActionButton: AgentHireFab(
        isDark: isDark,
        agentName: agentName,
        isActive: isActive,
        onPressed: onPrimaryActionPressed,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
