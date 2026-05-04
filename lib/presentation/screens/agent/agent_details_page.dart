import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/../l10n/app_localizations.dart';

import '../../providers/cart_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import 'package:e_team/data/services/hera_service.dart';
import 'package:e_team/presentation/screens/hera/hera_dashboard_page.dart';
import '../../widgets/agent/agent_swipe_dots.dart';
import '../../widgets/agent/agent_avatar_hero.dart';
import '../../widgets/agent/agent_description_bubble.dart';
import '../../widgets/agent/agent_multi_scenario_card.dart';
import '../../widgets/agent/agent_energy_pack_sheet.dart';
import '../../widgets/agent/agent_hire_fab.dart';
import '../../widgets/agent/agent_appbar_actions.dart';
import '../../widgets/agent/agent_skills_section.dart';
import '../../widgets/agent/agent_energy_costs_section.dart';
import '../../widgets/agent/agent_name_header.dart';
import '/data/services/agent_metadata_service.dart';

class AgentDetailsPage extends StatefulWidget {
  // ✅ Legacy single agent (optionnel)
  final String? title;
  final Color? color;
  final String? illustration;
  final List<String>? description;
  final String? timesSaved;
  final String? price;

  // ✅ Swipe mode
  final List<Map<String, dynamic>>? agents;
  final int initialIndex;

  const AgentDetailsPage({
    super.key,

    // legacy
    this.title,
    this.color,
    this.illustration,
    this.description,
    this.timesSaved,
    this.price,

    // swipe
    this.agents,
    this.initialIndex = 0,
  });

  @override
  State<AgentDetailsPage> createState() => _AgentDetailsPageState();
}

class _AgentDetailsPageState extends State<AgentDetailsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late final PageController _pageController;
  late int _currentIndex;

  bool get _isSwipeMode => widget.agents != null && widget.agents!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(
      0,
      _isSwipeMode ? widget.agents!.length - 1 : 0,
    );
    _pageController = PageController(initialPage: _currentIndex);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  double _pageValue() {
    if (!_pageController.hasClients) return _currentIndex.toDouble();
    return _pageController.page ?? _currentIndex.toDouble();
  }

  // ---------------------------
  // Agent resolving helpers
  // ---------------------------
  Map<String, dynamic> _agentAt(int index) {
    if (_isSwipeMode) return widget.agents![index];
    return {
      'name': widget.title ?? '',
      'color': widget.color ?? Colors.black,
      'icon': widget.illustration ?? '',
      'description': (widget.description ?? <String>[]).join('\n\n'),
      'stats': {'response': widget.timesSaved ?? ''},
      'price': widget.price ?? '',
    };
  }

  String _agentName(Map<String, dynamic> agent) =>
      (agent['name'] ?? '').toString();

  Color _agentColor(Map<String, dynamic> agent) =>
      agent['color'] as Color? ?? Colors.black;

  String _agentIcon(Map<String, dynamic> agent) =>
      (agent['icon'] ?? '').toString();

  List<String> _agentDescriptionLines(Map<String, dynamic> agent) {
    final desc = agent['description'];
    if (desc is List<String>) return desc;
    if (desc is String) return [desc];
    return widget.description ?? <String>[];
  }

  // ---------------------------
  // Skills
  // ---------------------------
  List<String> _getSkillsForAgent(AppLocalizations l10n, String agentName) {
    return AgentMetadataService.getSkillsForAgent(l10n, agentName);
  }

  // ---------------------------
  // Energy Costs
  // ---------------------------
  List<Map<String, dynamic>> _getEnergyCostsForAgent(String agentName) {
    return AgentMetadataService.getEnergyCostsForAgent(agentName);
  }

  List<Map<String, dynamic>> _getMultiAgentScenarios(String agentName) {
    return AgentMetadataService.getMultiAgentScenarios(agentName);
  }

  List<Map<String, dynamic>> _getEnergyPacksForAgent(String agentName) {
    return AgentMetadataService.getEnergyPacksForAgent(agentName);
  }

  String _getVersionForAgent(AppLocalizations l10n, String agentName) {
    return AgentMetadataService.getVersionForAgent(l10n, agentName);
  }

  // ---------------------------
  // Build
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    if (!_isSwipeMode) {
      return _buildAgentDetailsScaffold(
        context: context,
        l10n: l10n,
        isDark: isDark,
        agent: _agentAt(0),
        swipeDiff: 0.0,
      );
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: widget.agents!.length,
      physics: const BouncingScrollPhysics(),
      onPageChanged: (i) => setState(() => _currentIndex = i),
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, _) {
            final page = _pageValue();
            final diff = index - page;
            return _buildAgentDetailsScaffold(
              context: context,
              l10n: l10n,
              isDark: isDark,
              agent: _agentAt(index),
              swipeDiff: diff,
            );
          },
        );
      },
    );
  }

  Widget _buildAgentDetailsScaffold({
    required BuildContext context,
    required AppLocalizations l10n,
    required bool isDark,
    required Map<String, dynamic> agent,
    required double swipeDiff,
  }) {
    final name = _agentName(agent);
    final color = _agentColor(agent);
    final icon = _agentIcon(agent);

    final userProvider = context.watch<UserProvider>();
    final agentId = name.trim().toLowerCase();
    final isActive = userProvider.isAgentActive(agentId);
    final energyCosts = _getEnergyCostsForAgent(name);
    final multiScenarios = _getMultiAgentScenarios(name);
    final skills = _getSkillsForAgent(l10n, name);

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
              // ── AppBar ──────────────────────────────────────────────────
              SliverAppBar(
                backgroundColor: isDark
                    ? const Color(0xFF0A0A0A)
                    : Colors.white,
                pinned: true,
                elevation: 0,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
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
                        onCartPressed: () => Navigator.pushNamed(context, '/cart'),
                        onSharePressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.share, color: Colors.white),
                                  const SizedBox(width: 12),
                                  Text(l10n.agentDetailsShareSnack(name)),
                                ],
                              ),
                              backgroundColor: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.black87,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: isDark
                                    ? BorderSide(
                                        color: Colors.white.withValues(alpha: 0.1),
                                        width: 1,
                                      )
                                    : BorderSide.none,
                              ),
                            ),
                          );
                        },
                        isDark: isDark,
                      );
                    },
                  ),
                ],
              ),

              // ── Content ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Opacity(
                    opacity: contentOpacity,
                    child: Transform.translate(
                      offset: Offset(0, contentDy),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          AgentAvatarHero(
                            agentIcon: icon,
                            agentColor: color,
                            pulseController: _animationController,
                            avatarDx: avatarDx,
                          ),

                          const SizedBox(height: 24),

                          // Name
                          AgentNameHeader(
                            agentName: name,
                            version: _getVersionForAgent(l10n, name),
                            isDark: isDark,
                          ),

                          const SizedBox(height: 24),

                          // Description bubble
                          AgentDescriptionBubble(
                            description: _agentDescriptionLines(agent).join('\n\n'),
                            agentColor: color,
                            isDark: isDark,
                          ),

                          const SizedBox(height: 32),

                          // Skills
                          AgentSkillsSection(
                            title: l10n.agentDetailsCoreSkills,
                            skills: skills,
                            isDark: isDark,
                          ),

                          const SizedBox(height: 32),

                          // Energy Cost per Task
                          AgentEnergyCostsSection(
                            title: 'ENERGY COST PER TASK',
                            energyCosts: energyCosts,
                            agentColor: color,
                            isDark: isDark,
                          ),

                          // Multi-Agent Scenarios
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
                              (s) => AgentMultiScenarioCard(
                                scenario: s,
                                agentColor: color,
                                isDark: isDark,
                              ),
                            ),
                          ],

                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Dots overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 10,
            left: 0,
            right: 0,
            child: Center(
              child: _isSwipeMode
                  ? AgentSwipeDots(
                      itemCount: widget.agents!.length,
                      pageController: _pageController,
                      currentIndex: _currentIndex,
                      isDark: isDark,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(
        context: context,
        isDark: isDark,
        name: name,
        color: color,
        icon: icon,
        isActive: isActive,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ---------------------------
  // ✅ FAB — Hire ou Buy Energy
  // ---------------------------
  Widget _buildFab({
    required BuildContext context,
    required bool isDark,
    required String name,
    required Color color,
    required String icon,
    required bool isActive,
  }) {
    final isHera = name.trim().toLowerCase() == 'hera';
    final canOpenDashboard = isHera && isActive;

    return AgentHireFab(
      isDark: isDark,
      agentName: name,
      isActive: isActive,
      onPressed: () {
        if (canOpenDashboard) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HeraDashboardPage(),
            ),
          );
          return;
        }
        _handleHireAgent(context, isDark, name, color, icon);
      },
    );
  }

  // ---------------------------
  // ✅ NOUVELLE méthode — Handle Hire Agent
  // ---------------------------
  Future<void> _handleHireAgent(
    BuildContext context,
    bool isDark,
    String name,
    Color color,
    String icon,
  ) async {
    if (name == 'Hera') {
      // 1. Loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
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
        ),
      );

      try {
        // 2. Appelle N8N
        await HeraService.hello(username: 'Samar');

        if (!context.mounted) return;

        // 3. Ferme loading
        Navigator.pop(context);

        // 4. ✅ Navigate vers HeraDashboardPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const HeraDashboardPage(),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;

        // Ferme loading
        Navigator.pop(context);

        // Affiche erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.wifi_off, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Hera indisponible. Lance N8N sur le port 5678.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // ✅ Autres agents → Energy pack sheet (inchangé)
    _showEnergyPackSheet(context, isDark, name, color, icon);
  }

  // ---------------------------
  // Energy Pack Sheet (inchangé)
  // ---------------------------
  void _showEnergyPackSheet(
    BuildContext ctx,
    bool isDark,
    String agentName,
    Color agentColor,
    String agentIcon,
  ) {
    final packs = _getEnergyPacksForAgent(agentName);
    showAgentEnergyPackSheet(
      context: ctx,
      agentName: agentName,
      agentColor: agentColor,
      agentIcon: agentIcon,
      isDark: isDark,
      energyPacks: packs,
    );
  }

}

