import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../../../services/hr_agent_service.dart';
import 'package:e_team/screens/agent/hr/hera_voice_page.dart';
import '../../../providers/user_provider.dart';
import '../agent_communication_screen.dart';
import 'hr_inbox_screen.dart';
import 'hera_history_page.dart';

class HrDashboardPage extends StatefulWidget {
  const HrDashboardPage({super.key});

  @override
  State<HrDashboardPage> createState() => _HrDashboardPageState();
}

class _HrDashboardPageState extends State<HrDashboardPage> {
  int _selectedTab = 0;
  int _employeeSubTab = 0;

  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _recentActions = [];
  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _allLeaves = [];

  bool _loadingStats = true;
  bool _loadingActions = true;
  bool _loadingEmployees = true;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
          (_) => _loadAdminData(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    _loadStats();
    _loadRecentActions();
    _loadEmployees();
  }

  Future<void> _loadStats() async {
    setState(() => _loadingStats = true);
    try {
      final result = await HrAgentService.getAdminStats();
      if (result['success'] == true) {
        setState(() {
          _stats = result['stats'];
          _loadingStats = false;
        });
      } else {
        setState(() => _loadingStats = false);
      }
    } catch (_) {
      setState(() => _loadingStats = false);
    }
  }

  Future<void> _loadRecentActions() async {
    setState(() => _loadingActions = true);
    try {
      final result = await HrAgentService.getRecentActions(limit: 5);
      if (result['success'] == true) {
        setState(() {
          _recentActions =
          List<Map<String, dynamic>>.from(result['recent_actions'] ?? []);
          _loadingActions = false;
        });
      } else {
        setState(() => _loadingActions = false);
      }
    } catch (_) {
      setState(() => _loadingActions = false);
    }
  }

  Future<void> _loadEmployees() async {
    setState(() => _loadingEmployees = true);
    try {
      final result = await HrAgentService.getAllEmployees();
      if (result['success'] == true) {
        setState(() {
          _employees = List<Map<String, dynamic>>.from(result['employees'] ?? []);
          _loadingEmployees = false;
        });
        _loadAllLeaves();
      } else {
        setState(() => _loadingEmployees = false);
      }
    } catch (_) {
      setState(() => _loadingEmployees = false);
    }
  }

  Future<void> _loadAllLeaves() async {
    try {
      final allLeaves = <Map<String, dynamic>>[];
      for (final emp in _employees) {
        final result = await HrAgentService.getLeaves(employeeId: emp['_id']);
        if (result['success'] == true) {
          final leaves = List<Map<String, dynamic>>.from(result['leaves'] ?? []);
          for (final leave in leaves) {
            leave['employee_name'] = emp['name'];
            leave['employee_role'] = emp['role'];
            allLeaves.add(leave);
          }
        }
      }
      if (mounted) {
        setState(() => _allLeaves = allLeaves);
      }
    } catch (_) {}
  }

  List<Map<String, dynamic>> _getLeavesForDay(DateTime day) {
    return _allLeaves.where((leave) {
      if (leave['status'] != 'approved') return false;
      final startDate = DateTime.parse(leave['start_date']);
      final endDate = DateTime.parse(leave['end_date']);
      return day.isAfter(startDate.subtract(const Duration(days: 1))) &&
          day.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  String? _extractId(dynamic id) {
    if (id == null) return null;
    if (id is String) return id;
    if (id is Map) return id['\$oid']?.toString() ?? id['_id']?.toString();
    return id.toString();
  }

  Map<String, dynamic> _getActionConfig(Map<String, dynamic> action) {
    switch (action['action_type']) {
      case 'onboarding_started':
        return {
          'icon': Icons.person_add_rounded,
          'color': const Color(0xFFCCFF00),
          'label': 'Onboarding démarré',
          'badge': 'NOUVEAU'
        };
      case 'onboarding_completed':
        return {
          'icon': Icons.check_circle_rounded,
          'color': const Color(0xFF10B981),
          'label': 'Onboarding complété',
          'badge': 'ACTIF'
        };
      case 'leave_approved':
        return {
          'icon': Icons.event_available_rounded,
          'color': const Color(0xFF10B981),
          'label': 'Congé approuvé',
          'badge': 'APPROUVÉ'
        };
      case 'leave_refused':
        return {
          'icon': Icons.event_busy_rounded,
          'color': const Color(0xFFEF4444),
          'label': 'Congé refusé',
          'badge': 'REFUSÉ'
        };
      case 'offboarding_started':
        return {
          'icon': Icons.logout_rounded,
          'color': const Color(0xFFF59E0B),
          'label': 'Offboarding démarré',
          'badge': 'DÉPART'
        };
      case 'offboarding_completed':
        return {
          'icon': Icons.exit_to_app_rounded,
          'color': const Color(0xFFEF4444),
          'label': 'Offboarding complété',
          'badge': 'INACTIF'
        };
      case 'promotion':
        return {
          'icon': Icons.trending_up_rounded,
          'color': const Color(0xFFA855F7),
          'label': 'Promotion',
          'badge': 'PROMU'
        };
      case 'absence_alert':
        return {
          'icon': Icons.warning_amber_rounded,
          'color': const Color(0xFFF59E0B),
          'label': 'Alerte absences répétées',
          'badge': 'ALERTE'
        };
      default:
        return {
          'icon': Icons.info_outline_rounded,
          'color': const Color(0xFF7C3AED),
          'label': 'Action Hera',
          'badge': 'INFO'
        };
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
    return DateFormat('d MMM', 'fr_FR').format(date);
  }

  Future<void> _deleteAction(int index, String? actionId) async {
    if (index >= _recentActions.length) return;
    final removed = _recentActions[index];

    setState(() => _recentActions.removeAt(index));

    if (actionId != null && actionId.isNotEmpty) {
      try {
        await HrAgentService.deleteAction(actionId);
      } catch (_) {
        if (mounted) {
          setState(() => _recentActions.insert(index, removed));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la suppression')),
          );
          return;
        }
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Action supprimée'),
          backgroundColor: const Color(0xFF111827),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _openVoicePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HeraVoicePage(),
      ),
    );
  }

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label à connecter'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Color _surface(bool isDark) =>
      isDark ? const Color(0xFF141414) : Colors.white;

  Color _surfaceSoft(bool isDark) =>
      isDark ? const Color(0xFF1D1D1D) : const Color(0xFFF7F9FC);

  Color _pageBg(bool isDark) =>
      isDark ? const Color(0xFF090909) : const Color(0xFFF3F6FB);

  Color _textPrimary(bool isDark) =>
      isDark ? Colors.white : const Color(0xFF111827);

  Color _textSecondary(bool isDark) =>
      isDark ? Colors.white60 : const Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: _pageBg(isDark),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            _buildTabs(isDark),
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _buildOverview(isDark),
                  _buildCalendar(isDark),
                  _buildEmployees(isDark),
                  _buildInsights(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final energy = context.watch<UserProvider>().energyBalance;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _surface(isDark),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: _textPrimary(isDark),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFCCFF00).withOpacity(0.75),
                      const Color(0xFFA855F7).withOpacity(0.65),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/images/hera.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hera',
                      style: TextStyle(
                        color: _textPrimary(isDark),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Votre copilote RH intelligent',
                      style: TextStyle(
                        color: _textSecondary(isDark),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _surface(isDark),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFFCDFF00).withOpacity(0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt,
                        size: 16, color: Color(0xFFFFD54F)),
                    const SizedBox(width: 6),
                    Text(
                      '$energy',
                      style: const TextStyle(
                        color: Color(0xFFCDFF00),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HrInboxScreen(token: null),
                        ),
                      );
                    },
                    icon: const Icon(Icons.mail_outline_rounded, size: 18),
                    label: const Text('Messages'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _surface(isDark),
                      foregroundColor: _textPrimary(isDark),
                      side: BorderSide(
                        color: _textSecondary(isDark).withOpacity(0.18),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AgentCommunicationScreen(
                            token: null,
                            fromAgent: 'hera',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Envoyer à Echo'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _surface(isDark),
                      foregroundColor: _textPrimary(isDark),
                      side: BorderSide(
                        color: _textSecondary(isDark).withOpacity(0.18),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(bool isDark) {
    final tabs = [
      (Icons.dashboard_rounded, 'Vue générale'),
      (Icons.calendar_month_rounded, 'Calendrier'),
      (Icons.people_rounded, 'Équipe'),
      (Icons.insights_rounded, 'Insights'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: _surface(isDark),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTab == index;
          final (icon, label) = tabs[index];

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFCCFF00).withOpacity(0.25)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: isSelected ? Colors.black : _textSecondary(isDark),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.black : _textSecondary(isDark),
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOverview(bool isDark) {
    return RefreshIndicator(
      onRefresh: _loadAdminData,
      color: const Color(0xFFCCFF00),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
        children: [
          _buildHeroSection(isDark),
          const SizedBox(height: 18),
          if (_loadingStats)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFCCFF00)),
              ),
            )
          else if (_stats != null)
            _buildStats(isDark),
          const SizedBox(height: 22),
          _buildHistorySection(isDark),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            const Color(0xFF171717),
            const Color(0xFF101010),
          ]
              : [
            Colors.white,
            const Color(0xFFF6FAFF),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCCFF00).withOpacity(isDark ? 0.08 : 0.10),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Que voulez-vous faire aujourd’hui ?',
            style: TextStyle(
              color: _textPrimary(isDark),
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1.05,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 10),

          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _heroActionCard(
                  bg: const Color(0xFFCCFF00),
                  fg: Colors.black,
                  icon: Icons.graphic_eq_rounded,
                  title: 'Parler à Hera',
                  onTap: _openVoicePage,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    _smallHeroAction(
                      icon: Icons.event_note_rounded,
                      title: 'Demander un congé',
                      onTap: () => _showComingSoon('Demande de congé'),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _smallHeroAction(
                      icon: Icons.history_rounded,
                      title: 'Historique RH',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HeraHistoryPage(isDark: isDark),
                          ),
                        );
                      },
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroActionCard({
    required Color bg,
    required Color fg,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 152,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: fg.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: fg, size: 18),
                ),
                const Spacer(),
                Icon(Icons.arrow_outward_rounded, color: fg, size: 18),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                color: fg,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallHeroAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _surfaceSoft(isDark),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFA855F7).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFA855F7),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: _textPrimary(isDark),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              icon,
              color: _textSecondary(isDark),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _premiumStatCard(
                title: 'Employés',
                value: '${_stats!['total_employees']}',
                subtitle: 'Total suivis',
                icon: Icons.groups_rounded,
                accent: const Color(0xFFCCFF00),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _premiumStatCard(
                title: 'En congé',
                value: '${_stats!['on_leave_today']}',
                subtitle: 'Aujourd’hui',
                icon: Icons.beach_access_rounded,
                accent: const Color(0xFFA855F7),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _surface(isDark),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xFF10B981),
                  size: 25,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jours de congé ce mois',
                      style: TextStyle(
                        color: _textSecondary(isDark),
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_stats!['monthly_leave_days'] ?? 0} jours',
                      style: TextStyle(
                        color: _textPrimary(isDark),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'CE MOIS',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _premiumStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required bool isDark,
  }) {
    final bool isLime = accent == const Color(0xFFCCFF00);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface(isDark),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: isLime ? Colors.black : accent,
              size: 22,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              color: _textPrimary(isDark),
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: _textPrimary(isDark),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: _textSecondary(isDark),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Activité récente',
                style: TextStyle(
                  color: _textPrimary(isDark),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HeraHistoryPage(isDark: isDark),
                ),
              ),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFF00).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Voir tout',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_loadingActions)
          const Padding(
            padding: EdgeInsets.all(28),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFCCFF00)),
            ),
          )
        else if (_recentActions.isEmpty)
          _buildEmptyHistory(isDark)
        else
          ...List.generate(_recentActions.length, (index) {
            final action = _recentActions[index];
            return _buildActionCard(action, index, isDark);
          }),
      ],
    );
  }

  Widget _buildActionCard(
      Map<String, dynamic> action,
      int index,
      bool isDark,
      ) {
    final config = _getActionConfig(action);
    final employeeName = action['employee_name'] ?? 'Employé';
    final createdAt = action['created_at'] != null
        ? DateTime.tryParse(action['created_at'].toString())
        : null;
    final timeAgo = createdAt != null ? _timeAgo(createdAt) : '';

    final Color accent = config['color'] as Color;
    final bool isNew = (config['badge'] as String) == 'NOUVEAU';

    return Dismissible(
      key: Key('action_${_extractId(action['_id'])}_$index'),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => _deleteAction(index, _extractId(action['_id'])),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withOpacity(0.12),
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Row(
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFEF4444),
              size: 22,
            ),
            SizedBox(width: 8),
            Text(
              'Supprimer',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface(isDark),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                config['icon'] as IconData,
                color: isNew ? Colors.black : (isDark ? Colors.white : accent),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employeeName,
                    style: TextStyle(
                      color: _textPrimary(isDark),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    config['label'] as String,
                    style: TextStyle(
                      color: _textSecondary(isDark),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isNew
                        ? const Color(0xFFCCFF00).withOpacity(0.78)
                        : accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    config['badge'] as String,
                    style: TextStyle(
                      color: isNew ? Colors.black : accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (timeAgo.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    timeAgo,
                    style: TextStyle(
                      color: _textSecondary(isDark).withOpacity(0.85),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHistory(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _surface(isDark),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFCCFF00).withOpacity(0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: Colors.black,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Aucune activité',
            style: TextStyle(
              color: _textPrimary(isDark),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Les actions de Hera apparaîtront ici',
            style: TextStyle(
              color: _textSecondary(isDark),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(bool isDark) {
    final leavesOnSelectedDay = _selectedDay != null
        ? _getLeavesForDay(_selectedDay!)
        : <Map<String, dynamic>>[];

    return RefreshIndicator(
      onRefresh: _loadAdminData,
      color: const Color(0xFFCCFF00),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        children: [
          Text(
            'Absences & congés',
            style: TextStyle(
              color: _textPrimary(isDark),
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sélectionnez une date pour voir les congés approuvés.',
            style: TextStyle(
              color: _textSecondary(isDark),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: _surface(isDark),
              borderRadius: BorderRadius.circular(28),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) =>
                  setState(() => _calendarFormat = format),
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              eventLoader: _getLeavesForDay,
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final leavesForDay = _getLeavesForDay(day);
                  if (leavesForDay.isEmpty) return null;

                  Color backgroundColor;
                  if (leavesForDay.any((l) => l['type'] == 'urgent')) {
                    backgroundColor = const Color(0xFFEF4444);
                  } else if (leavesForDay.any((l) => l['type'] == 'sick')) {
                    backgroundColor = const Color(0xFFF59E0B);
                  } else {
                    backgroundColor = const Color(0xFFCCFF00);
                  }

                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: backgroundColor.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: backgroundColor, width: 1.2),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  );
                },
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return null;
                  return Positioned(
                    bottom: 2,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: events.take(3).map((event) {
                        final leave = event as Map<String, dynamic>;
                        Color dotColor;
                        switch (leave['type']) {
                          case 'urgent':
                            dotColor = const Color(0xFFEF4444);
                            break;
                          case 'sick':
                            dotColor = const Color(0xFFF59E0B);
                            break;
                          default:
                            dotColor = const Color(0xFFCCFF00);
                        }
                        return Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFA855F7),
                    width: 2,
                  ),
                ),
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFFA855F7),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: _textPrimary(isDark),
                  fontWeight: FontWeight.w900,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
                defaultTextStyle: TextStyle(
                  color: _textPrimary(isDark),
                  fontSize: 14,
                ),
                weekendTextStyle: TextStyle(
                  color: _textSecondary(isDark),
                  fontSize: 14,
                ),
                outsideTextStyle: TextStyle(
                  color: _textSecondary(isDark).withOpacity(0.35),
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: const Color(0xFFCCFF00).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                formatButtonTextStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                ),
                titleTextStyle: TextStyle(
                  color: _textPrimary(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left_rounded,
                  color: _textPrimary(isDark),
                  size: 26,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right_rounded,
                  color: _textPrimary(isDark),
                  size: 26,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: _textPrimary(isDark),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
                weekendStyle: TextStyle(
                  color: _textSecondary(isDark),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _surface(isDark),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Wrap(
              spacing: 18,
              runSpacing: 10,
              children: [
                _buildLegendItem('Congé annuel', const Color(0xFFCCFF00)),
                _buildLegendItem('Maladie', const Color(0xFFF59E0B)),
                _buildLegendItem('Urgent', const Color(0xFFEF4444)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _selectedDay != null
                ? 'Congés du ${DateFormat('d MMMM yyyy', 'fr_FR').format(_selectedDay!)}'
                : 'Sélectionnez une date',
            style: TextStyle(
              color: _textPrimary(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          if (leavesOnSelectedDay.isEmpty)
            _buildEmpty(
              Icons.event_available,
              'Aucun congé',
              'Pas d\'absence ce jour-là',
              isDark,
            )
          else
            ...leavesOnSelectedDay
                .map((leave) => _buildLeaveDetailCard(leave, isDark)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.18),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: color, width: 1.2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveDetailCard(Map<String, dynamic> leave, bool isDark) {
    final type = leave['type'] as String;
    final employeeName = leave['employee_name'] as String? ?? 'Unknown';
    final reason = leave['reason'] as String? ?? '';
    final days = leave['days'] as int;
    final startDate = DateTime.parse(leave['start_date']);
    final endDate = DateTime.parse(leave['end_date']);

    IconData icon;
    switch (type) {
      case 'annual':
        icon = Icons.beach_access;
        break;
      case 'sick':
        icon = Icons.medical_services;
        break;
      case 'urgent':
        icon = Icons.warning_amber_rounded;
        break;
      default:
        icon = Icons.description;
    }

    final dateFormat = DateFormat('d MMM yyyy', 'fr_FR');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface(isDark),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFF00).withOpacity(0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.black, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employeeName,
                      style: TextStyle(
                        color: _textPrimary(isDark),
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$days jour${days > 1 ? "s" : ""}',
                      style: TextStyle(
                        color: _textSecondary(isDark),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _surfaceSoft(isDark),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: _textSecondary(isDark),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${dateFormat.format(startDate)} → ${dateFormat.format(endDate)}',
                        style: TextStyle(
                          color: _textPrimary(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                if (reason.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 14,
                        color: _textSecondary(isDark),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reason,
                          style: TextStyle(
                            color: _textSecondary(isDark),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployees(bool isDark) {
    final activeEmployees =
    _employees.where((e) => e['status'] == 'active').toList();
    final onboardingEmployees =
    _employees.where((e) => e['status'] == 'onboarding').toList();

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: _surface(isDark),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _employeeSubTab = 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _employeeSubTab == 0
                          ? const Color(0xFFCCFF00).withOpacity(0.24)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Mon équipe',
                          style: TextStyle(
                            color: _employeeSubTab == 0
                                ? Colors.black
                                : _textSecondary(isDark),
                            fontSize: 14,
                            fontWeight: _employeeSubTab == 0
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                        if (activeEmployees.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _employeeSubTab == 0
                                  ? Colors.black.withOpacity(0.08)
                                  : (isDark
                                  ? Colors.white12
                                  : Colors.black.withOpacity(0.06)),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              '${activeEmployees.length}',
                              style: TextStyle(
                                color: _employeeSubTab == 0
                                    ? Colors.black
                                    : _textPrimary(isDark),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _employeeSubTab = 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _employeeSubTab == 1
                          ? const Color(0xFFCCFF00).withOpacity(0.24)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Nouveaux',
                          style: TextStyle(
                            color: _employeeSubTab == 1
                                ? Colors.black
                                : _textSecondary(isDark),
                            fontSize: 14,
                            fontWeight: _employeeSubTab == 1
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                        if (onboardingEmployees.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _employeeSubTab == 1
                                  ? Colors.black.withOpacity(0.08)
                                  : (isDark
                                  ? Colors.white12
                                  : Colors.black.withOpacity(0.06)),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              '${onboardingEmployees.length}',
                              style: TextStyle(
                                color: _employeeSubTab == 1
                                    ? Colors.black
                                    : _textPrimary(isDark),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
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
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadAdminData,
            color: const Color(0xFFCCFF00),
            child: _loadingEmployees
                ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFCCFF00),
              ),
            )
                : _employeeSubTab == 0
                ? _buildActiveEmployeesList(activeEmployees, isDark)
                : _buildOnboardingEmployeesList(onboardingEmployees, isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveEmployeesList(
      List<Map<String, dynamic>> employees,
      bool isDark,
      ) {
    if (employees.isEmpty) {
      return _buildEmpty(
        Icons.people_outline,
        'Aucun employé actif',
        'Tous vos employés sont en cours d\'intégration',
        isDark,
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
      children: employees
          .map((emp) => _buildActiveEmployeeCard(emp, isDark))
          .toList(),
    );
  }

  Widget _buildOnboardingEmployeesList(
      List<Map<String, dynamic>> employees,
      bool isDark,
      ) {
    if (employees.isEmpty) {
      return _buildEmpty(
        Icons.celebration,
        'Aucun nouvel arrivant',
        'Tous vos employés sont déjà actifs',
        isDark,
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
      children: employees
          .map((emp) => _buildOnboardingEmployeeCard(emp, isDark))
          .toList(),
    );
  }

  Widget _buildActiveEmployeeCard(
      Map<String, dynamic> employee,
      bool isDark,
      ) {
    final name = employee['name'] as String;
    final role = employee['role'] as String;
    final department = employee['department'] as String;
    final balances = employee['balances'] as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface(isDark),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFF00).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: _textPrimary(isDark),
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$role • $department',
                      style: TextStyle(
                        color: _textSecondary(isDark),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _badge(
                Icons.beach_access,
                '${balances['annual']['remaining']}/${balances['annual']['total']}',
                isDark,
              ),
              const SizedBox(width: 8),
              _badge(
                Icons.medical_services,
                '${balances['sick']['remaining']}/${balances['sick']['total']}',
                isDark,
              ),
              const SizedBox(width: 8),
              _badge(
                Icons.warning_amber_rounded,
                '${balances['urgent']['remaining']}/${balances['urgent']['total']}',
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingEmployeeCard(
      Map<String, dynamic> employee,
      bool isDark,
      ) {
    final name = employee['name'] as String;
    final role = employee['role'] as String;
    final department = employee['department'] as String;
    final startDateStr = employee['start_date'] as String?;

    String dateText = 'Date non définie';
    String countdownText = '';

    if (startDateStr != null && startDateStr.isNotEmpty) {
      try {
        final startDate = DateTime.parse(startDateStr);
        dateText = DateFormat('d MMMM yyyy', 'fr_FR').format(startDate);
        final today = DateTime.now();
        final daysUntilStart =
            startDate.difference(DateTime(today.year, today.month, today.day)).inDays;
        if (daysUntilStart == 0) {
          countdownText = 'Arrive aujourd\'hui';
        } else if (daysUntilStart == 1) {
          countdownText = 'Arrive demain';
        } else if (daysUntilStart > 0) {
          countdownText = 'Arrive dans $daysUntilStart jours';
        } else {
          countdownText = 'Date de début passée';
        }
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface(isDark),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFF00).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: _textPrimary(isDark),
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$role • $department',
                      style: TextStyle(
                        color: _textSecondary(isDark),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFF00).withOpacity(0.72),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'NOUVEAU',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _surfaceSoft(isDark),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.black,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Date de début',
                      style: TextStyle(
                        color: _textPrimary(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        dateText,
                        style: TextStyle(
                          color: _textPrimary(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (countdownText.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 14,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              countdownText,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String text, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _surfaceSoft(isDark),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: Colors.black),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: _textPrimary(isDark),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsights(bool isDark) {
    int usedEnergy = 0;
    if (_stats != null) {
      final monthlyLeaves = _stats!['monthly_leave_days'] ?? 0;
      usedEnergy = (monthlyLeaves * 10 / 30).round().clamp(0, 100);
    }
    final remainingEnergy = 100 - usedEnergy;

    final tasks = [
      {
        'icon': Icons.event_note,
        'title': 'Demande de congé',
        'cost': 10,
        'color': const Color(0xFFA855F7)
      },
      {
        'icon': Icons.flash_on,
        'title': 'Congé urgent',
        'cost': 15,
        'color': const Color(0xFFEC4899)
      },
      {
        'icon': Icons.person_add_alt_1,
        'title': 'Onboarding employé',
        'cost': 25,
        'color': const Color(0xFF8B5CF6)
      },
      {
        'icon': Icons.trending_up,
        'title': 'Promotion',
        'cost': 20,
        'color': const Color(0xFF06B6D4)
      },
      {
        'icon': Icons.workspace_premium,
        'title': 'Évaluation performance',
        'cost': 18,
        'color': const Color(0xFFF59E0B)
      },
      {
        'icon': Icons.exit_to_app,
        'title': 'Offboarding',
        'cost': 30,
        'color': const Color(0xFFEF4444)
      },
    ];

    return RefreshIndicator(
      onRefresh: _loadAdminData,
      color: const Color(0xFFCCFF00),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: _surface(isDark),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFA855F7).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.battery_charging_full,
                        color: Color(0xFFA855F7),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Capacité Hera',
                            style: TextStyle(
                              color: _textPrimary(isDark),
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Budget réinitialisé chaque jour',
                            style: TextStyle(
                              color: _textSecondary(isDark),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: remainingEnergy / 100,
                    minHeight: 12,
                    backgroundColor:
                    (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      remainingEnergy > 30
                          ? const Color(0xFFA855F7)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$remainingEnergy / 100',
                      style: TextStyle(
                        color: _textPrimary(isDark),
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '$usedEnergy utilisés',
                      style: TextStyle(
                        color: _textSecondary(isDark),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Tâches disponibles',
            style: TextStyle(
              color: _textPrimary(isDark),
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 12),
          ...tasks.map((task) {
            final cost = task['cost'] as int;
            final afterUse = remainingEnergy - cost;
            final canAfford = afterUse >= 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _surface(isDark),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: (task['color'] as Color).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          task['icon'] as IconData,
                          color: task['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task['title'] as String,
                              style: TextStyle(
                                color: _textPrimary(isDark),
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Coût : $cost unités',
                              style: TextStyle(
                                color: task['color'] as Color,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!canAfford)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Indisponible',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _surfaceSoft(isDark),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: _textSecondary(isDark),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            canAfford
                                ? '$afterUse unités restantes après exécution'
                                : 'Budget insuffisant',
                            style: TextStyle(
                              color: canAfford
                                  ? _textPrimary(isDark)
                                  : Colors.red,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmpty(
      IconData icon,
      String title,
      String subtitle,
      bool isDark,
      ) {
    return ListView(
      shrinkWrap: true,
      children: [
        Container(
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            color: _surface(isDark),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFF00).withOpacity(0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: Colors.black, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  color: _textPrimary(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textSecondary(isDark),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}