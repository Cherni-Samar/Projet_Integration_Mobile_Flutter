import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e_team/data/services/agent_service.dart';
import 'package:e_team/data/services/auth_service.dart';
import 'package:e_team/data/services/agent_metadata_service.dart';
import 'package:e_team/domain/models/user_model.dart';
import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/providers/cart_provider.dart';
import 'package:e_team/presentation/providers/theme_provider.dart';
import 'package:e_team/presentation/providers/user_provider.dart';
import 'package:e_team/presentation/screens/activity/activity_logs_screen.dart';
import 'package:e_team/presentation/screens/agent/agent_details_page.dart';
import 'package:e_team/presentation/screens/agent/agent_inter_flow_page.dart';
import 'package:e_team/presentation/screens/agent/my_agents_page.dart';
import 'package:e_team/presentation/screens/auth/user_profile_page.dart';
import 'package:e_team/presentation/screens/pricing_page.dart';
import 'package:e_team/presentation/utils/domain_model_color_extensions.dart';
import 'package:e_team/presentation/widgets/agent/agent_marketplace_card.dart';
import 'package:e_team/presentation/widgets/common/app_bottom_nav_bar.dart';
import 'package:e_team/presentation/widgets/common/round_icon_button.dart';

class AgentMarketplacePage extends StatefulWidget {
  const AgentMarketplacePage({Key? key}) : super(key: key);

  @override
  State<AgentMarketplacePage> createState() => _AgentMarketplacePageState();
}

class _AgentMarketplacePageState extends State<AgentMarketplacePage>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();

  User? _currentUser;
  bool _isLoading = true;
  bool _isHiring = false;

  late PageController _pageController;
  double _currentPage = 2.0;
  late AnimationController _headerAnimationController;

  List<Map<String, dynamic>> _agents = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _pageController = PageController(initialPage: 2, viewportFraction: 0.8);
    _pageController.addListener(() {
      if (!mounted) return;
      setState(() => _currentPage = _pageController.page ?? 2.0);
    });
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final savedUser = await _authService.getSavedUserModel();

      if (savedUser != null) {
        if (!mounted) return;
        setState(() {
          _currentUser = savedUser;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
      }

      // Single authoritative refresh from API — updates both local state
      // and UserProvider in one call.
      await context.read<UserProvider>().refreshFromApi();
      if (mounted) {
        setState(() => _currentUser = context.read<UserProvider>().user);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _agentIdFromName(String name) {
    return name.trim().toLowerCase();
  }

  Future<void> _hireAgent(String agentId) async {
    if (_isHiring) return;

    final user = _currentUser;
    if (user == null) return;

    setState(() => _isHiring = true);

    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('You must be logged in');
      }

      final resp = await AgentService.hireAgent(agentId: agentId, token: token);

      if (resp['success'] == true) {
        if (mounted) {
          // Refresh from API to get the authoritative updated user state.
          await context.read<UserProvider>().refreshFromApi();
          setState(() => _currentUser = context.read<UserProvider>().user);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isHiring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final l10n = AppLocalizations.of(context)!;

    _agents = AgentMetadataService.getAllAgentsAsMap(l10n);

    final currentIndex = _currentPage.round().clamp(0, _agents.length - 1);
    final currentAgent = _agents[currentIndex];

    final currentAgentId = _agentIdFromName(currentAgent['name'] as String);
    final user = _currentUser;
    final activeAgents = user?.activeAgents ?? const <String>[];
    final maxAgentsAllowed = user?.maxAgentsAllowed ?? 1;
    final isActive = activeAgents.contains(currentAgentId);
    final hasSlots = activeAgents.length < maxAgentsAllowed;
    final buttonFg = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _headerAnimationController,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                          decoration: BoxDecoration(
                            gradient: isDark
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF1A1A1A),
                                      const Color(0xFF2D2D2D),
                                      Color.lerp(
                                        const Color(0xFF2D2D2D),
                                        const Color(
                                          0xFFCDFF00,
                                        ).withValues(alpha: 0.05),
                                        _headerAnimationController.value,
                                      )!,
                                    ],
                                  )
                                : LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white,
                                      const Color(0xFFFAFAFA),
                                      Color.lerp(
                                        const Color(0xFFFAFAFA),
                                        const Color(
                                          0xFFCDFF00,
                                        ).withValues(alpha: 0.03),
                                        _headerAnimationController.value,
                                      )!,
                                    ],
                                  ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withValues(alpha: 0.5)
                                    : Colors.black.withValues(alpha: 0.08),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(32),
                              bottomRight: Radius.circular(32),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UserProfilePage(user: _currentUser),
                                      ),
                                    ).then((_) => _loadUserData());
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFA855F7),
                                              Color(0xFF8B5CF6),
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFFA855F7,
                                              ).withValues(alpha: 0.5),
                                              blurRadius: 20,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: isDark
                                                ? const Color(
                                                    0xFFCDFF00,
                                                  ).withValues(alpha: 0.3)
                                                : Colors.white,
                                            width: 2.5,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _userInitial(_currentUser),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              l10n.agentMarketplaceWelcomeBack,
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.white.withValues(
                                                        alpha: 0.5,
                                                      )
                                                    : Colors.black.withValues(
                                                        alpha: 0.5,
                                                      ),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _userDisplayName(_currentUser),
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: -0.5,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Consumer<CartProvider>(
                                builder: (context, cart, child) {
                                  return Stack(
                                    children: [
                                      RoundIconButton(
                                        isDark: isDark,
                                        icon: Icons.shopping_cart_outlined,
                                        onPressed: () => Navigator.pushNamed(
                                          context,
                                          '/cart',
                                        ),
                                      ),
                                      if (cart.itemCount > 0)
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.red.withValues(
                                                    alpha: 0.8,
                                                  ),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              Stack(
                                children: [
                                  RoundIconButton(
                                    isDark: isDark,
                                    icon: Icons.notifications_outlined,
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(
                                                Icons.notifications_active,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  l10n.agentMarketplaceNoNewNotifications,
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: isDark
                                              ? const Color(0xFF2A2A2A)
                                              : Colors.black87,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFCDFF00),
                                            Color(0xFFAADD00),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFFCDFF00,
                                            ).withValues(alpha: 0.8),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 28,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFCDFF00),
                                      Color(0xFFAADD00),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.agentMarketplaceTitle,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.touch_app,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : Colors.black.withValues(alpha: 0.5),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.agentMarketplaceSwipeToExplore(
                                  _agents.length,
                                ),
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.5)
                                      : Colors.black.withValues(alpha: 0.5),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 400,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _agents.length,
                        itemBuilder: (context, index) {
                          return AgentMarketplaceCard(
                            agent: _agents[index],
                            index: index,
                            pageController: _pageController,
                            currentPage: _currentPage,
                            isDark: isDark,
                            onTap: () {
                              final isCenter =
                                  (_currentPage - index).abs() < 0.5;
                              if (!isCenter) {
                                _pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                final currentIndex = _currentPage.round().clamp(
                                  0,
                                  _agents.length - 1,
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AgentDetailsPage(
                                      agents: _agents,
                                      initialIndex: currentIndex,
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _buildAgentInfo(currentAgent, isDark),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.15)
                                        : Colors.black.withValues(alpha: 0.1),
                                    width: 2,
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    if (_currentPage.round() <
                                        _agents.length - 1) {
                                      _pageController.nextPage(
                                        duration: const Duration(
                                          milliseconds: 400,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    Icons.arrow_forward_ios,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.7)
                                        : Colors.black.withValues(alpha: 0.7),
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: isDark
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xFFCDFF00),
                                              Color(0xFFAADD00),
                                            ],
                                          )
                                        : const LinearGradient(
                                            colors: [
                                              Colors.black,
                                              Color(0xFF1A1A1A),
                                            ],
                                          ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDark
                                            ? const Color(
                                                0xFFCDFF00,
                                              ).withValues(alpha: 0.4)
                                            : Colors.black.withValues(
                                                alpha: 0.15,
                                              ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: (user == null || _isHiring)
                                        ? null
                                        : isActive
                                        ? null
                                        : hasSlots
                                        ? () => _hireAgent(currentAgentId)
                                        : () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const PricingPage(),
                                              ),
                                            ).then((result) {
                                              if (result == true) {
                                                _loadUserData();
                                              }
                                            });
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: buttonFg,
                                      disabledForegroundColor: buttonFg,
                                      disabledBackgroundColor:
                                          Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (_isHiring)
                                          SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.2,
                                              color: buttonFg,
                                            ),
                                          )
                                        else ...[
                                          Icon(
                                            isActive
                                                ? Icons.verified
                                                : hasSlots
                                                ? Icons.person_add_alt_1
                                                : Icons.workspace_premium,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 10),
                                          Flexible(
                                            child: Text(
                                              isActive
                                                  ? 'Actif'
                                                  : hasSlots
                                                  ? 'Hire'
                                                  : 'Plan plein - Améliorer mon offre',
                                              style: TextStyle(
                                                color: buttonFg,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        isDark: isDark,
        onMarketTap: () {
          // Already on market page
        },
        onAgentsTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyAgentsPage()),
          );
        },
        onActivityTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ActivityLogsScreen()),
          );
        },
        onStatsTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AgentInterFlowPage()),
          );
        },
        onSettingsTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfilePage(user: _currentUser),
            ),
          ).then((_) => _loadUserData());
        },
      ),
    );
  }

  String _userInitial(User? user) {
    final name = user?.name;
    if (name != null && name.isNotEmpty) return name[0].toUpperCase();
    final email = user?.email;
    if (email != null && email.isNotEmpty) return email[0].toUpperCase();
    return 'U';
  }

  String _userDisplayName(User? user) {
    final name = user?.name;
    if (name != null && name.isNotEmpty) return name;
    final email = user?.email;
    if (email != null && email.isNotEmpty) return email.split('@').first;
    return 'User';
  }

  Widget _buildAgentInfo(Map<String, dynamic> agent, bool isDark) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      key: ValueKey(agent['name']),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            agent['description'],
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.75)
                  : Colors.black.withValues(alpha: 0.75),
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat(
                icon: Icons.flash_on,
                label: l10n.agentMarketplaceStatResponse,
                value: agent['stats']['response'],
                color: const Color(0xFFCDFF00),
                isDark: isDark,
              ),
              _buildStat(
                icon: Icons.check_circle,
                label: l10n.agentMarketplaceStatAccuracy,
                value: agent['stats']['accuracy'],
                color: const Color(0xFFA855F7),
                isDark: isDark,
              ),
              _buildStat(
                icon: Icons.language,
                label: l10n.agentMarketplaceStatLanguages,
                value: agent['stats']['languages'],
                color: colorFromValue(agent['color']),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.05),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.black.withValues(alpha: 0.6),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
