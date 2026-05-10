import 'package:e_team/data/services/agent_metadata_service.dart';
import 'package:e_team/data/services/agent_service.dart';
import 'package:e_team/data/services/auth_service.dart';
import 'package:e_team/domain/models/user_model.dart';
import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/providers/theme_provider.dart';
import 'package:e_team/presentation/providers/user_provider.dart';
import 'package:e_team/presentation/screens/activity/activity_logs_screen.dart';
import 'package:e_team/presentation/screens/agent/agent_details_page.dart';
import 'package:e_team/presentation/screens/agent/agent_inter_flow_page.dart';
import 'package:e_team/presentation/screens/agent/my_agents_page.dart';
import 'package:e_team/presentation/screens/auth/user_profile_page.dart';
import 'package:e_team/presentation/screens/pricing_page.dart';
import 'package:e_team/presentation/widgets/agent/agent_marketplace_card.dart';
import 'package:e_team/presentation/widgets/agent/marketplace/agent_marketplace_actions.dart';
import 'package:e_team/presentation/widgets/agent/marketplace/agent_marketplace_header.dart';
import 'package:e_team/presentation/widgets/agent/marketplace/agent_marketplace_info.dart';
import 'package:e_team/presentation/widgets/common/app_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AgentMarketplacePage extends StatefulWidget {
  const AgentMarketplacePage({super.key});

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

      if (resp['success'] == true && mounted) {
        await context.read<UserProvider>().refreshFromApi();
        setState(() => _currentUser = context.read<UserProvider>().user);
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
                    AgentMarketplaceHeader(
                      isDark: isDark,
                      currentUser: _currentUser,
                      animation: _headerAnimationController,
                      l10n: l10n,
                      onProfileTap: _openUserProfile,
                      onCartTap: () => Navigator.pushNamed(context, '/cart'),
                      onNotificationsTap: () {
                        _showNotificationSnackBar(l10n, isDark);
                      },
                    ),
                    const SizedBox(height: 24),
                    AgentMarketplaceTitle(
                      isDark: isDark,
                      agentCount: _agents.length,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 24),
                    _buildAgentCarousel(isDark),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: AgentMarketplaceInfo(
                        agent: currentAgent,
                        isDark: isDark,
                        l10n: l10n,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AgentMarketplaceActions(
                      isDark: isDark,
                      isHiring: _isHiring,
                      isActive: isActive,
                      hasSlots: hasSlots,
                      canHire: user != null && !_isHiring,
                      onNext: _goToNextAgent,
                      onHire: () => _hireAgent(currentAgentId),
                      onUpgrade: _openPricing,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        isDark: isDark,
        onMarketTap: () {},
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
        onSettingsTap: _openUserProfile,
      ),
    );
  }

  Widget _buildAgentCarousel(bool isDark) {
    return SizedBox(
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
            onTap: () => _handleAgentTap(index),
          );
        },
      ),
    );
  }

  void _handleAgentTap(int index) {
    final isCenter = (_currentPage - index).abs() < 0.5;
    if (!isCenter) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      return;
    }

    final currentIndex = _currentPage.round().clamp(0, _agents.length - 1);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AgentDetailsPage(agents: _agents, initialIndex: currentIndex),
      ),
    );
  }

  void _goToNextAgent() {
    if (_currentPage.round() < _agents.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _openPricing() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PricingPage()),
    ).then((result) {
      if (result == true) _loadUserData();
    });
  }

  void _openUserProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfilePage(user: _currentUser),
      ),
    ).then((_) => _loadUserData());
  }

  void _showNotificationSnackBar(AppLocalizations l10n, bool isDark) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.agentMarketplaceNoNewNotifications)),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
