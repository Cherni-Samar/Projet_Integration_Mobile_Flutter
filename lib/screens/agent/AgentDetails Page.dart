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
  // Energy Costs
  // ---------------------------
  List<Map<String, dynamic>> _getEnergyCostsForAgent(String agentName) {
    switch (agentName) {
      case 'Hera':
        return [
          {'task': 'Approve leave', 'cost': 10},
          {'task': 'Employee onboarding', 'cost': 15},
          {'task': 'Team coordination', 'cost': 12},
        ];
      case 'Kash':
        return [
          {'task': 'Add expense', 'cost': 15},
          {'task': 'Generate report', 'cost': 20},
          {'task': 'Track budget', 'cost': 12},
        ];
      case 'Dexo':
        return [
          {'task': 'Upload document', 'cost': 8},
          {'task': 'Classify files', 'cost': 10},
          {'task': 'Manage access', 'cost': 12},
        ];
      case 'Timo':
        return [
          {'task': 'Plan meeting', 'cost': 20},
          {'task': 'Prioritize tasks', 'cost': 15},
          {'task': 'Deadline reminder', 'cost': 8},
        ];
      case 'Echo':
        return [
          {'task': 'Summarize email', 'cost': 5},
          {'task': 'Filter messages', 'cost': 8},
          {'task': 'Smart notification', 'cost': 6},
        ];
      default:
        return [
          {'task': 'Basic task', 'cost': 10},
        ];
    }
  }

  List<Map<String, dynamic>> _getMultiAgentScenarios(String agentName) {
    switch (agentName) {
      case 'Hera':
        return [
          {'scenario': 'Leave + schedule update', 'agents': 'Hera + Timo', 'cost': 25},
        ];
      case 'Kash':
        return [
          {'scenario': 'Invoice + storage + analysis', 'agents': 'Kash + Dexo', 'cost': 30},
        ];
      case 'Dexo':
        return [
          {'scenario': 'Invoice + storage + analysis', 'agents': 'Kash + Dexo', 'cost': 30},
        ];
      case 'Timo':
        return [
          {'scenario': 'Leave + schedule update', 'agents': 'Hera + Timo', 'cost': 25},
          {'scenario': 'Meeting + summary + tasks', 'agents': 'Timo + Echo', 'cost': 35},
        ];
      case 'Echo':
        return [
          {'scenario': 'Meeting + summary + tasks', 'agents': 'Timo + Echo', 'cost': 35},
        ];
      default:
        return [];
    }
  }

  List<Map<String, dynamic>> _getEnergyPacksForAgent(String agentName) {
    switch (agentName) {
      case 'Hera':
        return [
          {'title': 'Starter', 'energy': 1000, 'price': 10.0, 'color': 0xFF10B981},
          {'title': 'Pro', 'energy': 6000, 'price': 45.0, 'color': 0xFF8B5CF6},
          {'title': 'Business', 'energy': 15000, 'price': 100.0, 'color': 0xFFF59E0B},
        ];
      case 'Kash':
        return [
          {'title': 'Starter', 'energy': 1000, 'price': 15.0, 'color': 0xFF10B981},
          {'title': 'Pro', 'energy': 6000, 'price': 55.0, 'color': 0xFF8B5CF6},
          {'title': 'Business', 'energy': 15000, 'price': 120.0, 'color': 0xFFF59E0B},
        ];
      case 'Dexo':
        return [
          {'title': 'Starter', 'energy': 1000, 'price': 8.0, 'color': 0xFF10B981},
          {'title': 'Pro', 'energy': 6000, 'price': 35.0, 'color': 0xFF8B5CF6},
          {'title': 'Business', 'energy': 15000, 'price': 80.0, 'color': 0xFFF59E0B},
        ];
      case 'Timo':
        return [
          {'title': 'Starter', 'energy': 1000, 'price': 12.0, 'color': 0xFF10B981},
          {'title': 'Pro', 'energy': 6000, 'price': 50.0, 'color': 0xFF8B5CF6},
          {'title': 'Business', 'energy': 15000, 'price': 110.0, 'color': 0xFFF59E0B},
        ];
      case 'Echo':
        return [
          {'title': 'Starter', 'energy': 1000, 'price': 5.0, 'color': 0xFF10B981},
          {'title': 'Pro', 'energy': 6000, 'price': 25.0, 'color': 0xFF8B5CF6},
          {'title': 'Business', 'energy': 15000, 'price': 60.0, 'color': 0xFFF59E0B},
        ];
      default:
        return [
          {'title': 'Starter', 'energy': 1000, 'price': 10.0, 'color': 0xFF10B981},
          {'title': 'Pro', 'energy': 6000, 'price': 45.0, 'color': 0xFF8B5CF6},
          {'title': 'Business', 'energy': 15000, 'price': 100.0, 'color': 0xFFF59E0B},
        ];
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
    final energyCosts = _getEnergyCostsForAgent(name);
    final multiScenarios = _getMultiAgentScenarios(name);
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

                          // ── Energy Cost per Task ──
                          Text(
                            'ENERGY COST PER TASK',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Column(
                              children: energyCosts.asMap().entries.map((entry) {
                                final i = entry.key;
                                final task = entry.value;
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    border: i < energyCosts.length - 1
                                        ? Border(bottom: BorderSide(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.06)
                                          : Colors.black.withValues(alpha: 0.06),
                                    ))
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        task['task'] as String,
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white.withValues(alpha: 0.8)
                                              : Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.bolt, color: color, size: 16),
                                            const SizedBox(width: 2),
                                            Text(
                                              '${task['cost']}',
                                              style: TextStyle(
                                                color: color,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          // ── Multi-Agent Scenarios ──
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
                            ...multiScenarios.map((s) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    color.withValues(alpha: 0.08),
                                    color.withValues(alpha: 0.02),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s['scenario'] as String,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        s['agents'] as String,
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white.withValues(alpha: 0.6)
                                              : Colors.black54,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.bolt, color: Color(0xFFF59E0B), size: 16),
                                            const SizedBox(width: 2),
                                            Text(
                                              '${s['cost']}',
                                              style: const TextStyle(
                                                color: Color(0xFFF59E0B),
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )),
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ---------------------------
  // FAB — Buy Energy
  // ---------------------------
  Widget _buildFab({
    required BuildContext context,
    required bool isDark,
    required String name,
    required Color color,
    required String icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showEnergyPackSheet(context, isDark, name, color, icon),
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
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bolt, size: 22),
              SizedBox(width: 10),
              Text(
                'Buy Energy',
                style: TextStyle(
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

  void _showEnergyPackSheet(
      BuildContext ctx,
      bool isDark,
      String agentName,
      Color agentColor,
      String agentIcon,
      ) {
    final cart = Provider.of<CartProvider>(ctx, listen: false);
    final packs = _getEnergyPacksForAgent(agentName);
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Energy for $agentName',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a pack to power $agentName ⚡',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ...packs.map((pack) {
                final packColor = Color(pack['color'] as int);
                final title = pack['title'] as String;
                final energy = pack['energy'] as int;
                final price = pack['price'] as double;
                final isBest = title == 'Pro';
                return GestureDetector(
                  onTap: () {
                    final item = CartItem(
                      id: 'agent-$agentName',
                      agentName: agentName,
                      agentIllustration: agentIcon,
                      agentColor: agentColor,
                      packTitle: title,
                      energy: energy,
                      price: price,
                    );
                    final added = cart.addToCart(item);
                    Navigator.pop(sheetCtx);
                    if (added) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.bolt, color: agentColor, size: 20),
                              const SizedBox(width: 10),
                              Text('$agentName ($title) added to cart!'),
                            ],
                          ),
                          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.black,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          action: SnackBarAction(
                            label: 'VIEW CART',
                            textColor: const Color(0xFFCDFF00),
                            onPressed: () => Navigator.pushNamed(ctx, '/cart'),
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text('$agentName is already in your cart!'),
                          backgroundColor: Colors.orange.shade700,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF252525) : const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isBest ? packColor : (isDark ? Colors.white12 : Colors.black12),
                        width: isBest ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: packColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.bolt, color: packColor, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (isBest) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: packColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'BEST VALUE',
                                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_fmtEnergy(energy)} ⚡',
                                style: TextStyle(
                                  color: packColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${price.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  static String _fmtEnergy(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    return n.toString();
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