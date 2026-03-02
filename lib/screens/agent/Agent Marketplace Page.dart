import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../providers/theme_provider.dart';
import '../../providers/cart_provider.dart';
import '../../l10n/app_localizations.dart';

import '../../screens/agent/AgentDetails Page.dart';
import '../../screens/agent/my_agents_page.dart';
import '../../screens/pricing_page.dart';
import '../auth/user_profile_page.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

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

  List<Map<String, dynamic>> _buildAgents(AppLocalizations l10n) {
    return [
      {
        'name': 'Hera',
        'role': l10n.agentRoleHrSpecialist,
        'description': l10n.agentDescAlpha,
        'icon': 'assets/images/hera.png',
        'color': const Color(0xFF8B5CF6),
        'stats': {
          'response': '< 1.2s',
          'accuracy': '99.4%',
          'languages': '42+',
        },
        'rating': 4.9,
        'hires': '1.2k',
        'price': '10 ⚡/task',
      },
      {
        'name': 'Kash',
        'role': l10n.agentRoleFinancialExpert,
        'description': l10n.agentDescFinanceWizard,
        'icon': 'assets/images/kash.png',
        'color': const Color(0xFFF59E0B),
        'stats': {
          'response': '< 0.8s',
          'accuracy': '98.9%',
          'languages': '35+',
        },
        'rating': 4.8,
        'hires': '980',
        'price': '15 ⚡/task',
      },
      {
        'name': 'Dexo',
        'role': l10n.agentRoleAdminAssistant,
        'description': l10n.agentDescAdminPro,
        'icon': 'assets/images/dexo.png',
        'color': const Color(0xFF10B981),
        'stats': {
          'response': '< 1.5s',
          'accuracy': '97.8%',
          'languages': '28+',
        },
        'rating': 5.0,
        'hires': '2.1k',
        'price': '8 ⚡/task',
      },
      {
        'name': 'Timo',
        'role': l10n.agentRolePlanningManager,
        'description': l10n.agentDescPlanningBot,
        'icon': 'assets/images/krono.png',
        'color': const Color(0xFFEC4899),
        'stats': {
          'response': '< 1.0s',
          'accuracy': '96.5%',
          'languages': '30+',
        },
        'rating': 4.7,
        'hires': '850',
        'price': '20 ⚡/task',
      },
      {
        'name': 'Echo',
        'role': l10n.agentRoleCommunicationPro,
        'description': l10n.agentDescCommSync,
        'icon': 'assets/images/voxi.png',
        'color': const Color(0xFFA855F7),
        'stats': {
          'response': '< 0.9s',
          'accuracy': '98.2%',
          'languages': '45+',
        },
        'rating': 4.9,
        'hires': '1.5k',
        'price': '5 ⚡/task',
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _pageController = PageController(initialPage: 2, viewportFraction: 0.8);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 2.0;
      });
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
      final user = await _authService.getSavedUser();
      if (user != null) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      } else {
        final apiUser = await _authService.getMe();
        setState(() {
          _currentUser = apiUser;
          _isLoading = false;
        });
      }

      // Refresh from API to keep subscription/agents in sync
      final fresh = await _authService.getMe();
      if (fresh != null && mounted) {
        setState(() => _currentUser = fresh);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading user: $e');
      setState(() => _isLoading = false);
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

      final resp = await ApiService.post(
        endpoint: ApiConstants.hireAgent,
        body: {'agentId': agentId},
        token: token,
      );

      if (resp['success'] == true) {
        final nextActive = (resp['activeAgents'] is List)
            ? (resp['activeAgents'] as List).map((e) => e.toString()).toList()
            : user.activeAgents;

        final nextMax = (resp['maxAgentsAllowed'] is num)
            ? (resp['maxAgentsAllowed'] as num).toInt()
            : user.maxAgentsAllowed;

        final updated = user.copyWith(
          activeAgents: nextActive,
          maxAgentsAllowed: nextMax,
        );

        // Persist by saving via AuthService private helper isn't accessible;
        // so we just keep it in memory and rely on /me refresh.
        if (mounted) {
          setState(() => _currentUser = updated);
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

    _agents = _buildAgents(l10n);

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
        child: SingleChildScrollView(
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
                            const Color(0xFFCDFF00).withOpacity(0.05),
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
                            const Color(0xFFCDFF00).withOpacity(0.03),
                            _headerAnimationController.value,
                          )!,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.5)
                              : Colors.black.withOpacity(0.08),
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
                                        ).withOpacity(0.5),
                                        blurRadius: 20,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(
                                        0xFFCDFF00,
                                      ).withOpacity(0.3)
                                          : Colors.white,
                                      width: 2.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _currentUser?.name
                                          ?.substring(0, 1)
                                          .toUpperCase() ??
                                          _currentUser?.email
                                              .substring(0, 1)
                                              .toUpperCase() ??
                                          'U',
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
                                              ? Colors.white.withOpacity(0.5)
                                              : Colors.black.withOpacity(0.5),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _currentUser?.name ??
                                            _currentUser?.email
                                                .split('@')
                                                .first ??
                                            'User',
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
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.08)
                                        : Colors.black.withOpacity(0.05),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.15)
                                          : Colors.black.withOpacity(0.1),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: () =>
                                        Navigator.pushNamed(context, '/cart'),
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      Icons.shopping_cart_outlined,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                      size: 22,
                                    ),
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
                                            color: Colors.red.withOpacity(0.8),
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
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.black.withOpacity(0.05),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.15)
                                      : Colors.black.withOpacity(0.1),
                                  width: 1.5,
                                ),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
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
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.notifications_outlined,
                                  color: isDark ? Colors.white : Colors.black,
                                  size: 22,
                                ),
                              ),
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
                                      ).withOpacity(0.8),
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
                              colors: [Color(0xFFCDFF00), Color(0xFFAADD00)],
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
                              ? Colors.white.withOpacity(0.5)
                              : Colors.black.withOpacity(0.5),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.agentMarketplaceSwipeToExplore(_agents.length),
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withOpacity(0.5)
                                : Colors.black.withOpacity(0.5),
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
                    return _build3DCard(index, isDark);
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
                                ? Colors.white.withOpacity(0.08)
                                : Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.black.withOpacity(0.1),
                              width: 2,
                            ),
                          ),
                          child: IconButton(
                            onPressed: () {
                              if (_currentPage.round() < _agents.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              color: isDark
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.black.withOpacity(0.7),
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
                                colors: [Colors.black, Color(0xFF1A1A1A)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? const Color(0xFFCDFF00).withOpacity(0.4)
                                      : Colors.black.withOpacity(0.15),
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
                                disabledBackgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                        Text(
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

      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              Icons.storefront_outlined,
              l10n.agentMarketplaceNavMarket,
              true,
              isDark,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyAgentsPage(),
                  ),
                );
              },
              child: _buildNavItem(
                Icons.people_outline,
                l10n.agentMarketplaceNavAgents,
                false,
                isDark,
              ),
            ),
            _buildNavItem(
              Icons.bar_chart_rounded,
              l10n.agentMarketplaceNavStats,
              false,
              isDark,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfilePage(user: _currentUser),
                  ),
                ).then((_) => _loadUserData());
              },
              child: _buildNavItem(
                Icons.settings_outlined,
                l10n.agentMarketplaceNavSettings,
                false,
                isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DCard(int index, bool isDark) {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 0.0;
        if (_pageController.position.haveDimensions) {
          value = index - _currentPage;
          value = (value * 0.038).clamp(-1, 1);
        }

        final agent = _agents[index];
        final isCenter = (_currentPage - index).abs() < 0.5;
        final currentIndex = _currentPage.round().clamp(0, _agents.length - 1);

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
                onTap: () {
                  if (!isCenter) {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  } else {
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
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
                          ],
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

  Widget _buildNavItem(
      IconData icon,
      String label,
      bool isActive,
      bool isDark,
      ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive
              ? (isDark ? const Color(0xFFCDFF00) : Colors.black)
              : (isDark
              ? Colors.white.withOpacity(0.4)
              : Colors.black.withOpacity(0.4)),
          size: 26,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isActive
                ? (isDark ? const Color(0xFFCDFF00) : Colors.black)
                : (isDark
                ? Colors.white.withOpacity(0.4)
                : Colors.black.withOpacity(0.4)),
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
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
                  ? Colors.white.withOpacity(0.75)
                  : Colors.black.withOpacity(0.75),
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
                color: agent['color'],
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
              colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
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
                ? Colors.white.withOpacity(0.6)
                : Colors.black.withOpacity(0.6),
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