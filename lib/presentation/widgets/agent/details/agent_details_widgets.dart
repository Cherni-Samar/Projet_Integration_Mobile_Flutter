import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/providers/cart_provider.dart';
import 'package:e_team/presentation/widgets/agent/agent_appbar_actions.dart';
import 'package:e_team/presentation/widgets/agent/agent_avatar_hero.dart';
import 'package:e_team/presentation/widgets/agent/agent_description_bubble.dart';
import 'package:e_team/presentation/widgets/agent/agent_energy_costs_section.dart';
import 'package:e_team/presentation/widgets/agent/agent_hire_fab.dart';
import 'package:e_team/presentation/widgets/agent/agent_multi_scenario_card.dart';
import 'package:e_team/presentation/widgets/agent/agent_name_header.dart';
import 'package:e_team/presentation/widgets/agent/agent_skills_section.dart';
import 'package:e_team/presentation/widgets/agent/agent_swipe_dots.dart';

class AgentDetailsScaffold extends StatelessWidget {
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

class AgentDetailsAppBar extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isDark;
  final VoidCallback onBackPressed;
  final VoidCallback onCartPressed;
  final VoidCallback onSharePressed;

  const AgentDetailsAppBar({
    super.key,
    required this.l10n,
    required this.isDark,
    required this.onBackPressed,
    required this.onCartPressed,
    required this.onSharePressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
      pinned: true,
      elevation: 0,
      leading: IconButton(
        onPressed: onBackPressed,
        icon: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xFFF5F5F5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
            size: 20,
          ),
        ),
      ),
      title: Text(
        l10n.agentDetailsTitle,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Consumer<CartProvider>(
          builder: (context, cart, child) {
            return AgentAppBarActions(
              cartItemCount: cart.itemCount,
              onCartPressed: onCartPressed,
              onSharePressed: onSharePressed,
              isDark: isDark,
            );
          },
        ),
      ],
    );
  }
}

class AgentDetailsBody extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isDark;
  final String agentName;
  final Color agentColor;
  final String agentIcon;
  final String description;
  final String version;
  final List<String> skills;
  final List<Map<String, dynamic>> energyCosts;
  final List<Map<String, dynamic>> multiScenarios;
  final AnimationController pulseController;
  final double avatarDx;

  const AgentDetailsBody({
    super.key,
    required this.l10n,
    required this.isDark,
    required this.agentName,
    required this.agentColor,
    required this.agentIcon,
    required this.description,
    required this.version,
    required this.skills,
    required this.energyCosts,
    required this.multiScenarios,
    required this.pulseController,
    required this.avatarDx,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AgentAvatarHero(
          agentIcon: agentIcon,
          agentColor: agentColor,
          pulseController: pulseController,
          avatarDx: avatarDx,
        ),
        const SizedBox(height: 24),
        AgentNameHeader(agentName: agentName, version: version, isDark: isDark),
        const SizedBox(height: 24),
        AgentDescriptionBubble(
          description: description,
          agentColor: agentColor,
          isDark: isDark,
        ),
        const SizedBox(height: 32),
        AgentSkillsSection(
          title: l10n.agentDetailsCoreSkills,
          skills: skills,
          isDark: isDark,
        ),
        const SizedBox(height: 32),
        AgentEnergyCostsSection(
          title: 'ENERGY COST PER TASK',
          energyCosts: energyCosts,
          agentColor: agentColor,
          isDark: isDark,
        ),
        if (multiScenarios.isNotEmpty) ...[
          const SizedBox(height: 32),
          Text(
            'MULTI-AGENT SCENARIOS',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ...multiScenarios.map(
            (scenario) => AgentMultiScenarioCard(
              scenario: scenario,
              agentColor: agentColor,
              isDark: isDark,
            ),
          ),
        ],
        const SizedBox(height: 120),
      ],
    );
  }
}

class AgentDetailsSwipeDotsOverlay extends StatelessWidget {
  final bool isVisible;
  final int itemCount;
  final PageController pageController;
  final int currentIndex;
  final bool isDark;

  const AgentDetailsSwipeDotsOverlay({
    super.key,
    required this.isVisible,
    required this.itemCount,
    required this.pageController,
    required this.currentIndex,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Positioned(
      top: MediaQuery.of(context).padding.top + kToolbarHeight + 10,
      left: 0,
      right: 0,
      child: Center(
        child: AgentSwipeDots(
          itemCount: itemCount,
          pageController: pageController,
          currentIndex: currentIndex,
          isDark: isDark,
        ),
      ),
    );
  }
}

class AgentConnectionDialog extends StatelessWidget {
  final bool isDark;

  const AgentConnectionDialog({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF8B5CF6)),
            const SizedBox(height: 16),
            Text(
              'Connexion à Hera...',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
