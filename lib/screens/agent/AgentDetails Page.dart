import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../providers/cart_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/hr_agent_service.dart';
import '../../screens/agent/hr/hr_dashboard_page.dart';

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
  String _selectedPlan = 'free';

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

  Widget _buildSwipeDots({required bool isDark}) {
    if (!_isSwipeMode) return const SizedBox.shrink();
    final count = widget.agents!.length;
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, _) {
        final page = _pageValue();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(count, (i) {
            final dist = (page - i).abs().clamp(0.0, 1.0);
            final t = 1.0 - dist;
            final width = 6.0 + (10.0 - 6.0) * t;
            const height = 6.0;
            final opacity = 0.35 + (1.0 - 0.35) * t;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(
                  alpha: opacity,
                ),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        );
      },
    );
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

  String _agentTimesSaved(Map<String, dynamic> agent) =>
      (agent['stats']?['response'] ?? widget.timesSaved ?? '').toString();

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
    switch (agentName) {
      case 'Hera':
        return [
          l10n.skillRecruitmentOnboarding,
          l10n.skillEmployeeRecords,
          l10n.skillPayrollManagement,
          l10n.skillLeaveTracking,
          l10n.skillPerformanceReviews,
        ];
      case 'Kash':
        return [
          l10n.skillInvoiceProcessing,
          l10n.skillExpenseTracking,
          l10n.skillFinancialReports,
          l10n.skillBudgetPlanning,
          l10n.skillTaxCompliance,
        ];
      case 'Dexo':
        return [
          l10n.skillDocumentManagement,
          l10n.skillFileOrganization,
          l10n.skillDataEntry,
          l10n.skillMeetingScheduling,
          l10n.skillEmailManagement,
        ];
      case 'Timo':
        return [
          l10n.skillProjectPlanning,
          l10n.skillTaskManagement,
          l10n.skillResourceAllocation,
          l10n.skillDeadlineTracking,
          l10n.skillTeamCoordination,
        ];
      case 'Echo':
        return [
          l10n.skillEmailCampaigns,
          l10n.skillTeamCommunications,
          l10n.skillNotifications,
          l10n.skillAnnouncementDistribution,
          l10n.skillChatManagement,
        ];
      default:
        return [
          l10n.skillNaturalLanguage,
          l10n.skillApiIntegration,
          l10n.skillMultilingualSupport,
          l10n.skillDataAnalysis,
          l10n.skillAutomation,
        ];
    }
  }

  // ---------------------------
  // Pricing
  // ---------------------------
  Map<String, dynamic> _getPricingForAgent(
    AppLocalizations l10n,
    String agentName,
  ) {
    switch (agentName) {
      case 'Hera':
        return {
          'free': {
            'price': '€0',
            'description': l10n.pricingRequestsPerMonth(50),
          },
          'hourly': {'price': '€3.50', 'description': l10n.pricingPayAsYouGo},
          'monthly': {
            'price': '€29',
            'description': l10n.pricingUnlimitedHrTasks,
          },
        };
      case 'Kash':
        return {
          'free': {
            'price': '€0',
            'description': l10n.pricingRequestsPerMonth(30),
          },
          'hourly': {'price': '€4.50', 'description': l10n.pricingPayAsYouGo},
          'monthly': {
            'price': '€39',
            'description': l10n.pricingFullFinancialSuite,
          },
        };
      case 'Dexo':
        return {
          'free': {
            'price': '€0',
            'description': l10n.pricingRequestsPerMonth(100),
          },
          'hourly': {'price': '€2.50', 'description': l10n.pricingPayAsYouGo},
          'monthly': {
            'price': '€25',
            'description': l10n.pricingCompleteAdminSupport,
          },
        };
      case 'Timo':
        return {
          'free': {
            'price': '€0',
            'description': l10n.pricingRequestsPerMonth(75),
          },
          'hourly': {'price': '€2.00', 'description': l10n.pricingPayAsYouGo},
          'monthly': {
            'price': '€19',
            'description': l10n.pricingProjectManagementTools,
          },
        };
      case 'Echo':
        return {
          'free': {
            'price': '€0',
            'description': l10n.pricingRequestsPerMonth(100),
          },
          'hourly': {'price': '€2.00', 'description': l10n.pricingPayAsYouGo},
          'monthly': {
            'price': '€19',
            'description': l10n.pricingCommunicationAutomation,
          },
        };
      default:
        return {
          'free': {
            'price': '€0',
            'description': l10n.pricingRequestsPerMonth(50),
          },
          'hourly': {'price': '€3.00', 'description': l10n.pricingPayAsYouGo},
          'monthly': {
            'price': '€29',
            'description': l10n.pricingFullFeaturesAccess,
          },
        };
    }
  }

  String _getVersionForAgent(AppLocalizations l10n, String agentName) {
    switch (agentName) {
      case 'Hera':
        return l10n.agentVersionAlpha;
      case 'Kash':
        return l10n.agentVersionFinanceWizard;
      case 'Dexo':
        return l10n.agentVersionAdminPro;
      case 'Timo':
        return l10n.agentVersionPlanningBot;
      case 'Echo':
        return l10n.agentVersionCommSync;
      default:
        return l10n.agentVersionDefault;
    }
  }

  Map<String, dynamic> _getRatingForAgent(String agentName) {
    switch (agentName) {
      case 'Hera':
        return {'stars': 4.9, 'hires': '1.2k'};
      case 'Kash':
        return {'stars': 4.8, 'hires': '980'};
      case 'Dexo':
        return {'stars': 5.0, 'hires': '2.1k'};
      case 'Timo':
        return {'stars': 4.7, 'hires': '850'};
      case 'Echo':
        return {'stars': 4.9, 'hires': '1.5k'};
      default:
        return {'stars': 4.8, 'hires': '1.2k'};
    }
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
      onPageChanged: (i) {
        setState(() {
          _currentIndex = i;
          _selectedPlan = 'free';
        });
      },
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
    final pricing = _getPricingForAgent(l10n, name);
    final rating = _getRatingForAgent(name);
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
                  // Cart icon with badge
                  Consumer<CartProvider>(
                    builder: (context, cart, child) {
                      return Stack(
                        children: [
                          IconButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/cart'),
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
                                Icons.shopping_cart_outlined,
                                color: isDark ? Colors.white : Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                          if (cart.itemCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '${cart.itemCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  // Share icon
                  IconButton(
                    onPressed: () {
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
                        Icons.share_outlined,
                        color: isDark ? Colors.white : Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                          // Avatar with parallax
                          Center(
                            child: Transform.translate(
                              offset: Offset(avatarDx, 0),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return CustomPaint(
                                        size: const Size(180, 180),
                                        painter: _PulsatingRingPainter(
                                          progress: _animationController.value,
                                          color: color,
                                        ),
                                      );
                                    },
                                  ),
                                  Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          color.withValues(alpha: 0.2),
                                          color.withValues(alpha: 0.1),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: color,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(70),
                                      child: Image.asset(
                                        icon,
                                        width: 140,
                                        height: 140,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFCDFF00),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 4,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFFCDFF00,
                                            ).withValues(alpha: 0.5),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Name
                          Center(
                            child: Text(
                              name,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Version
                          Center(
                            child: Text(
                              _getVersionForAgent(l10n, name),
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : Colors.black.withValues(alpha: 0.5),
                                fontSize: 14,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Stars
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ...List.generate(5, (index) {
                                  final stars = rating['stars'] as double;
                                  if (index < stars.floor()) {
                                    return const Icon(
                                      Icons.star,
                                      color: Color(0xFFFBBF24),
                                      size: 20,
                                    );
                                  } else if (index < stars) {
                                    return const Icon(
                                      Icons.star_half,
                                      color: Color(0xFFFBBF24),
                                      size: 20,
                                    );
                                  } else {
                                    return Icon(
                                      Icons.star_border,
                                      color: const Color(
                                        0xFFFBBF24,
                                      ).withValues(alpha: 0.3),
                                      size: 20,
                                    );
                                  }
                                }),
                                const SizedBox(width: 8),
                                Text(
                                  '${rating['stars']}',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  l10n.agentDetailsHires(rating['hires']),
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.5)
                                        : Colors.black.withValues(alpha: 0.5),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Description bubble
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: color.withValues(alpha: 0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.format_quote_rounded,
                                  color: color,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _agentDescriptionLines(agent).join('\n\n'),
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.8)
                                        : Colors.black.withValues(alpha: 0.8),
                                    fontSize: 16,
                                    height: 1.6,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Stats
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.flash_on,
                                  label: l10n.agentDetailsStatResponse,
                                  value: _agentTimesSaved(agent),
                                  color: const Color(0xFFCDFF00),
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.check_circle_outline,
                                  label: l10n.agentDetailsStatAccuracy,
                                  value: '99.4%',
                                  color: const Color(0xFFA855F7),
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.language,
                                  label: l10n.agentDetailsStatLanguages,
                                  value: '42+',
                                  color: color,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Skills
                          Text(
                            l10n.agentDetailsCoreSkills,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: skills
                                .map((skill) => _buildSkillChip(skill, isDark))
                                .toList(),
                          ),

                          const SizedBox(height: 32),

                          // Plans
                          Text(
                            l10n.agentDetailsDeploymentPlans,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildPlanCard(
                            title: l10n.agentDetailsPlanFreeTrial,
                            price: pricing['free']['price'],
                            period: '',
                            description: pricing['free']['description'],
                            badge: l10n.agentDetailsBadgeStarter,
                            badgeColor: const Color(0xFF6B7280),
                            isSelected: _selectedPlan == 'free',
                            onTap: () => setState(() => _selectedPlan = 'free'),
                            isDark: isDark,
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: _buildPlanCard(
                                  title: l10n.agentDetailsPlanHourly,
                                  price: pricing['hourly']['price'],
                                  period: l10n.commonPerHourShort,
                                  description: pricing['hourly']['description'],
                                  isSelected: _selectedPlan == 'hourly',
                                  onTap: () =>
                                      setState(() => _selectedPlan = 'hourly'),
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildPlanCard(
                                  title: l10n.agentDetailsPlanMonthly,
                                  price: pricing['monthly']['price'],
                                  period: l10n.commonPerMonthShort,
                                  description:
                                      pricing['monthly']['description'],
                                  badge: l10n.agentDetailsBadgeBestValue,
                                  badgeColor: const Color(0xFFCDFF00),
                                  isSelected: _selectedPlan == 'monthly',
                                  onTap: () =>
                                      setState(() => _selectedPlan = 'monthly'),
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),

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
            child: Center(child: _buildSwipeDots(isDark: isDark)),
          ),
        ],
      ),

      floatingActionButton: _buildFab(
        context: context,
        isDark: isDark,
        name: name,
        color: color,
        icon: icon,
        pricing: pricing,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ---------------------------
  // FAB — Hera → N8N, autres → Cart
  // ---------------------------
  Widget _buildFab({
    required BuildContext context,
    required bool isDark,
    required String name,
    required Color color,
    required String icon,
    required Map<String, dynamic> pricing,
  }) {
    // ✅ On récupère le CartProvider ici, hors du Consumer, pour éviter le
    //    ProviderNotFoundException quand le widget est dans un PageView.
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            if (name == 'Hera') {
              // ── Hera flow → N8N ──────────────────────────────────────
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
                ),
              );
              try {
                final response = await HrAgentService.hello(
                  username: 'Samar', // ← remplace par _currentUser.name
                );
                if (context.mounted) {
                  Navigator.pop(context); // ferme loading
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HrDashboardPage(
                        heraMessage: response['message'],
                        username: response['user'] ?? 'Samar',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // ferme loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Hera indisponible: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            } else {
              // ── Add to Cart pour les autres agents ───────────────────
              final planKey = _selectedPlan;
              final planDetails = pricing[planKey];

              final item = CartItem(
                id: '$name-${DateTime.now().millisecondsSinceEpoch}',
                title: name,
                plan: planKey,
                price:
                    double.tryParse(
                      planDetails['price'].toString().replaceAll('€', ''),
                    ) ??
                    0.0,
                color: color,
                illustration: icon,
              );

              cart.addToCart(item);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.shopping_cart_checkout,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text('$name added to cart!')),
                      ],
                    ),
                    backgroundColor: isDark
                        ? const Color(0xFF1E1E1E)
                        : Colors.black,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isDark
                          ? BorderSide(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1,
                            )
                          : BorderSide.none,
                    ),
                    action: SnackBarAction(
                      label: 'VIEW CART',
                      textColor: const Color(0xFFCDFF00),
                      onPressed: () => Navigator.pushNamed(context, '/cart'),
                    ),
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFFCDFF00) : Colors.black,
            foregroundColor: isDark ? Colors.black : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            shadowColor: Colors.black.withValues(alpha: 0.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                name == 'Hera' ? Icons.rocket_launch : Icons.add_shopping_cart,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                name == 'Hera' ? 'Hire Hera' : 'Add to Cart',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------
  // UI helpers
  // ---------------------------
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.5),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA855F7), width: 1.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFA855F7),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    required String description,
    String? badge,
    Color? badgeColor,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final selectedBgColor = isDark ? const Color(0xFFCDFF00) : Colors.black;
    final unselectedBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final selectedBorderColor = isDark ? const Color(0xFFCDFF00) : Colors.black;
    final unselectedBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.2);
    final selectedTextColor = isDark ? Colors.black : const Color(0xFFCDFF00);
    final unselectedTextColor = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? selectedBgColor : unselectedBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? selectedBorderColor : unselectedBorderColor,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedBgColor.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? selectedTextColor : unselectedTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor ?? const Color(0xFFCDFF00),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isSelected && badge == null)
                  Icon(Icons.check_circle, color: selectedTextColor, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: price,
                    style: TextStyle(
                      color: isSelected
                          ? selectedTextColor
                          : unselectedTextColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (period.isNotEmpty)
                    TextSpan(
                      text: period,
                      style: TextStyle(
                        color: isSelected
                            ? selectedTextColor.withValues(alpha: 0.7)
                            : unselectedTextColor.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: isSelected
                    ? selectedTextColor.withValues(alpha: 0.8)
                    : unselectedTextColor.withValues(alpha: 0.6),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------
// Custom painter — pulsating ring
// ---------------------------
class _PulsatingRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _PulsatingRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3 - progress * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius * (0.8 + progress * 0.2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
