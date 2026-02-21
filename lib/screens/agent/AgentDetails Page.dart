import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../l10n/app_localizations.dart';

class AgentDetailsPage extends StatefulWidget {
  final String title;
  final Color color;
  final String illustration;
  final List<String> description;
  final String timesSaved;
  final String price;

  const AgentDetailsPage({
    Key? key,
    required this.title,
    required this.color,
    required this.illustration,
    required this.description,
    required this.timesSaved,
    required this.price,
  }) : super(key: key);

  @override
  State<AgentDetailsPage> createState() => _AgentDetailsPageState();
}

class _AgentDetailsPageState extends State<AgentDetailsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedPlan = 'free'; // ✅ Free par défaut

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ✅ Fonction pour obtenir les skills selon l'agent
  List<String> _getSkillsForAgent(AppLocalizations l10n) {
    switch (widget.title) {
      case 'Agent Alpha':
        return [
          l10n.skillRecruitmentOnboarding,
          l10n.skillEmployeeRecords,
          l10n.skillPayrollManagement,
          l10n.skillLeaveTracking,
          l10n.skillPerformanceReviews,
        ];
      case 'FinanceWizard':
        return [
          l10n.skillInvoiceProcessing,
          l10n.skillExpenseTracking,
          l10n.skillFinancialReports,
          l10n.skillBudgetPlanning,
          l10n.skillTaxCompliance,
        ];
      case 'AdminPro':
        return [
          l10n.skillDocumentManagement,
          l10n.skillFileOrganization,
          l10n.skillDataEntry,
          l10n.skillMeetingScheduling,
          l10n.skillEmailManagement,
        ];
      case 'PlanningBot':
        return [
          l10n.skillProjectPlanning,
          l10n.skillTaskManagement,
          l10n.skillResourceAllocation,
          l10n.skillDeadlineTracking,
          l10n.skillTeamCoordination,
        ];
      case 'CommSync':
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

  // ✅ Fonction pour obtenir les prix avec plan Free
  Map<String, dynamic> _getPricingForAgent(AppLocalizations l10n) {
    switch (widget.title) {
      case 'Agent Alpha':
        return {
          'free': {
            'price': '€0',
            'description': l10n.pricingRequestsPerMonth(50)
          },
          'hourly': {'price': '€3.50', 'description': l10n.pricingPayAsYouGo},
          'monthly': {
            'price': '€29',
            'description': l10n.pricingUnlimitedHrTasks
          }
        };
      case 'FinanceWizard':
        return {
          'free': {
            'price': '€0',
            'description': l10n.pricingRequestsPerMonth(30)
          },
          'hourly': {'price': '€4.50', 'description': l10n.pricingPayAsYouGo},
          'monthly': {
            'price': '€39',
            'description': l10n.pricingFullFinancialSuite
          }
        };
      case 'AdminPro':
        return {
          'free': {
            'price': '€0',
            'description': l10n.pricingRequestsPerMonth(100)
          },
          'hourly': {'price': '€2.50', 'description': l10n.pricingPayAsYouGo},
          'monthly': {
            'price': '€25',
            'description': l10n.pricingCompleteAdminSupport
          }
        };
      case 'PlanningBot':
        return {
          'free': {
            'price': '€0',
            'description': l10n.pricingRequestsPerMonth(75)
          },
          'hourly': {'price': '€2.00', 'description': l10n.pricingPayAsYouGo},
          'monthly': {
            'price': '€19',
            'description': l10n.pricingProjectManagementTools
          }
        };
      case 'CommSync':
        return {
          'free': {
            'price': '€0',
            'description': l10n.pricingRequestsPerMonth(100)
          },
          'hourly': {'price': '€2.00', 'description': l10n.pricingPayAsYouGo},
          'monthly': {
            'price': '€19',
            'description': l10n.pricingCommunicationAutomation
          }
        };
      default:
        return {
          'free': {
            'price': '€0',
            'description': l10n.pricingRequestsPerMonth(50)
          },
          'hourly': {'price': '€3.00', 'description': l10n.pricingPayAsYouGo},
          'monthly': {'price': '€29', 'description': l10n.pricingFullFeaturesAccess}
        };
    }
  }

  // ✅ Fonction pour obtenir la version selon l'agent
  String _getVersionForAgent(AppLocalizations l10n) {
    switch (widget.title) {
      case 'Agent Alpha':
        return l10n.agentVersionAlpha;
      case 'FinanceWizard':
        return l10n.agentVersionFinanceWizard;
      case 'AdminPro':
        return l10n.agentVersionAdminPro;
      case 'PlanningBot':
        return l10n.agentVersionPlanningBot;
      case 'CommSync':
        return l10n.agentVersionCommSync;
      default:
        return l10n.agentVersionDefault;
    }
  }

  // ✅ Fonction pour obtenir le rating selon l'agent
  Map<String, dynamic> _getRatingForAgent() {
    switch (widget.title) {
      case 'Agent Alpha':
        return {'stars': 4.9, 'hires': '1.2k'};
      case 'FinanceWizard':
        return {'stars': 4.8, 'hires': '980'};
      case 'AdminPro':
        return {'stars': 5.0, 'hires': '2.1k'};
      case 'PlanningBot':
        return {'stars': 4.7, 'hires': '850'};
      case 'CommSync':
        return {'stars': 4.9, 'hires': '1.5k'};
      default:
        return {'stars': 4.8, 'hires': '1.2k'};
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pricing = _getPricingForAgent(l10n);
    final rating = _getRatingForAgent();
    final skills = _getSkillsForAgent(l10n);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: Colors.white,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
            title: Text(
              l10n.agentDetailsTitle,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.share, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(l10n.agentDetailsShareSnack(widget.title)),
                        ],
                      ),
                      backgroundColor: Colors.black87,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.share_outlined,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with animation
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Animated ring
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(180, 180),
                              painter: _PulsatingRingPainter(
                                progress: _animationController.value,
                                color: widget.color,
                              ),
                            );
                          },
                        ),
                        // Avatar
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.color.withOpacity(0.2),
                                widget.color.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.color,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.color.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.illustration,
                              style: const TextStyle(fontSize: 70),
                            ),
                          ),
                        ),
                        // Online indicator
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
                                  color: const Color(0xFFCDFF00).withOpacity(0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Name
                  Center(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Version dynamique
                  Center(
                    child: Text(
                      _getVersionForAgent(l10n),
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Rating dynamique
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
                              color: const Color(0xFFFBBF24).withOpacity(0.3),
                              size: 20,
                            );
                          }
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '${rating['stars']}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.agentDetailsHires(rating['hires']),
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.flash_on,
                          label: l10n.agentDetailsStatResponse,
                          value: widget.timesSaved,
                          color: const Color(0xFFCDFF00),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.check_circle_outline,
                          label: l10n.agentDetailsStatAccuracy,
                          value: '99.4%',
                          color: const Color(0xFFA855F7),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.language,
                          label: l10n.agentDetailsStatLanguages,
                          value: '42+',
                          color: widget.color,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Core Skills dynamiques
                  Text(
                    l10n.agentDetailsCoreSkills,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: skills.map((skill) => _buildSkillChip(skill)).toList(),
                  ),

                  const SizedBox(height: 32),

                  // Performance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.agentDetailsPerformanceEfficiency,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCDFF00).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n.agentDetailsPerformanceThisWeek,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Performance Graph Placeholder
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.black.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.show_chart,
                        color: widget.color.withOpacity(0.5),
                        size: 40,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ✅ Deployment Plans avec Free
                  Text(
                    l10n.agentDetailsDeploymentPlans,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ✅ Plan Free
                  _buildPlanCard(
                    title: l10n.agentDetailsPlanFreeTrial,
                    price: pricing['free']['price'],
                    period: '',
                    description: pricing['free']['description'],
                    badge: l10n.agentDetailsBadgeStarter,
                    badgeColor: const Color(0xFF6B7280),
                    isSelected: _selectedPlan == 'free',
                    onTap: () => setState(() => _selectedPlan = 'free'),
                  ),

                  const SizedBox(height: 12),

                  // Plans Hourly & Monthly
                  Row(
                    children: [
                      Expanded(
                        child: _buildPlanCard(
                          title: l10n.agentDetailsPlanHourly,
                          price: pricing['hourly']['price'],
                          period: l10n.commonPerHourShort,
                          description: pricing['hourly']['description'],
                          isSelected: _selectedPlan == 'hourly',
                          onTap: () => setState(() => _selectedPlan = 'hourly'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPlanCard(
                          title: l10n.agentDetailsPlanMonthly,
                          price: pricing['monthly']['price'],
                          period: l10n.commonPerMonthShort,
                          description: pricing['monthly']['description'],
                          badge: l10n.agentDetailsBadgeBestValue,
                          badgeColor: const Color(0xFFCDFF00),
                          isSelected: _selectedPlan == 'monthly',
                          onTap: () => setState(() => _selectedPlan = 'monthly'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating Hire Button
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final planText = _selectedPlan == 'free'
                      ? l10n.agentDetailsPlanFreeTrial
                      : _selectedPlan == 'hourly'
                      ? l10n.agentDetailsHourlyPlan
                      : l10n.agentDetailsMonthlyPlan;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.agentDetailsAgentHiredSnack(
                                widget.title,
                                planText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: const Color(0xFFFFFFFF),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.rocket_launch, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      l10n.agentDetailsHireAgent,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              color: Colors.black.withOpacity(0.5),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFA855F7),
          width: 1.5,
        ),
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.black.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
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
                    color: isSelected ? const Color(0xFFCDFF00) : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFFCDFF00),
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: price,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFFCDFF00) : Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (period.isNotEmpty)
                    TextSpan(
                      text: period,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFFCDFF00).withOpacity(0.7)
                            : Colors.black.withOpacity(0.5),
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
                    ? const Color(0xFFCDFF00).withOpacity(0.8)
                    : Colors.black.withOpacity(0.6),
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

// Custom painter for pulsating ring
class _PulsatingRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _PulsatingRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = color.withOpacity(0.3 - progress * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius * (0.8 + progress * 0.2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}