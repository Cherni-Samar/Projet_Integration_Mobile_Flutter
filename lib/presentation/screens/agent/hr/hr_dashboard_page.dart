import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:e_team/data/services/hr_agent_service.dart';
import 'package:e_team/domain/models/hera_models.dart';
import 'package:e_team/presentation/providers/user_provider.dart';
import 'hera_history_page.dart';
import 'hera_voice_page.dart';
class HeraPalette {
  static const bg = Colors.white;
  static const card = Color(0xFFF7F7F9);
  static const cardSoft = Color(0xFFEEEEF3);
  static const border = Color(0xFFE4E4EC);
  static const mauve = Color(0xFF904FF1);
  static const lime = Color(0xFF8940FB);
  static const violet = Color(0xFF6D28D9);
  static const timo = Color(0xFFB845FF);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFFFB74D);
  static const danger = Color(0xFFEF4444);
  static const textPrimary = Color(0xFF0D0D0D);
  static const textMuted = Color(0xFF9CA3AF);
  static const textSoft = Color(0xFFB0B0C0);
}

class HrDashboardPage extends StatefulWidget {
  const HrDashboardPage({super.key});

  @override
  State<HrDashboardPage> createState() => _HrDashboardPageState();
}

class _HrDashboardPageState extends State<HrDashboardPage>
    with TickerProviderStateMixin {
  int _selectedTab = 0;
  int _employeeSubTab = 0;

  HeraStats? _stats;
  List<Map<String, dynamic>> _recentActions = [];
  List<HeraEmployee> _employees = [];
  List<HeraLeave> _allLeaves = [];
  List<HeraCandidate> _candidates = [];

  bool _loadingStats = true;
  bool _loadingActions = true;
  bool _loadingEmployees = true;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  late AnimationController _pulseCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _glowCtrl;

  static const Map<String, int> _deptMax = {
    'Tech': 20,
    'Design': 10,
    'Marketing': 15,
    'RH': 5,
    'Finance': 8,
    'Support': 12,
  };

  static const _tabs = [
    (Icons.stream_rounded, 'Flux'),
    (Icons.calendar_month_rounded, 'Agenda'),
    (Icons.groups_2_rounded, 'Équipe'),
    (Icons.bolt_rounded, 'Énergie'),
    (Icons.radar_rounded, 'Vision'),
  ];

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _loadAll();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _loadStats(),
      _loadRecentActions(),
      _loadEmployees(),
      _loadCandidates(),
    ]);
  }

  Future<void> _loadStats() async {
    if (mounted) setState(() => _loadingStats = true);

    try {
      final response = await HrAgentService.getAdminStatsTyped();
      if (!mounted) return;
      setState(() {
        _stats = response.stats;
        _loadingStats = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  Future<void> _loadRecentActions() async {
    if (mounted) setState(() => _loadingActions = true);

    try {
      final response = await HrAgentService.getRecentActions(limit: 20);

      if (!mounted) return;

      setState(() {
        _recentActions = List<Map<String, dynamic>>.from(
          response['recent_actions'] ?? [],
        );
        _loadingActions = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingActions = false);
    }
  }
  Future<void> _loadEmployees() async {
    if (mounted) setState(() => _loadingEmployees = true);

    try {
      final response = await HrAgentService.getAllEmployeesTyped();
      if (!mounted) return;

      setState(() {
        _employees = response.employees;
        _loadingEmployees = false;
      });

      await _loadAllLeaves();
    } catch (_) {
      if (mounted) setState(() => _loadingEmployees = false);
    }
  }

  Future<void> _loadCandidates() async {
    try {
      final response = await HrAgentService.getAllCandidatesTyped();
      if (!mounted) return;
      setState(() => _candidates = response.candidates);
    } catch (e) {
      debugPrint('❌ Erreur chargement candidats : $e');
    }
  }

  Future<void> _loadAllLeaves() async {
    try {
      final leaves = <HeraLeave>[];

      for (final emp in _employees) {
        final response = await HrAgentService.getLeavesTyped(
          employeeId: emp.id,
          employeeName: emp.name,
          employeeRole: emp.role,
        );

        if (response.success) {
          leaves.addAll(response.leaves);
        }
      }

      if (mounted) setState(() => _allLeaves = leaves);
    } catch (_) {}
  }

  String? _extractId(dynamic id) {
    if (id == null) return null;
    if (id is String) return id;
    if (id is Map) return id[r'$oid']?.toString() ?? id['_id']?.toString();
    return id.toString();
  }

  int _countInDept(String dept) {
    return _employees.where((emp) {
      return emp.department.toLowerCase() == dept.toLowerCase() &&
          emp.status == 'active';
    }).length;
  }

  List<HeraLeave> _leavesForDay(DateTime day) {
    return _allLeaves.where((leave) {
      if (leave.status != 'approved') return false;
      return !day.isBefore(leave.startDate) && !day.isAfter(leave.endDate);
    }).toList();
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays}j';
    return DateFormat('d MMM', 'fr_FR').format(date);
  }

  Map<String, dynamic> _actionConfig(Map<String, dynamic> action) {
    final type = action['action_type']?.toString() ?? '';
    final details = action['details'] is Map<String, dynamic>
        ? action['details'] as Map<String, dynamic>
        : <String, dynamic>{};

    switch (type) {
      case 'planning_confirmed':
        if (details['agent'] == 'Timo') {
          return {
            'icon': Icons.event_available_rounded,
            'color': HeraPalette.timo,
            'label': 'Logistique · Planning validé',
            'badge': 'TIMO IA',
          };
        }
        return {
          'icon': Icons.campaign_rounded,
          'color': HeraPalette.warning,
          'label': 'Alerte staffing · ${details['department'] ?? 'équipe'}',
          'badge': 'AUTONOME',
        };
      case 'leave_approved':
        return {
          'icon': Icons.check_circle_outline_rounded,
          'color': HeraPalette.success,
          'label': 'Congé approuvé',
          'badge': 'RH IA',
        };
      case 'leave_refused':
        return {
          'icon': Icons.event_busy_rounded,
          'color': HeraPalette.danger,
          'label': 'Congé refusé',
          'badge': 'REFUSÉ',
        };
      case 'contract_renewal':
        return {
          'icon': Icons.description_rounded,
          'color': Colors.blue,
          'label': 'Contrat édité',
          'badge': 'DOCS',
        };
      default:
        return {
          'icon': Icons.auto_awesome_rounded,
          'color': HeraPalette.mauve,
          'label': 'Action système IA',
          'badge': 'INFO',
        };
    }
  }

  void _openVoicePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HeraVoicePage()),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: HeraPalette.cardSoft,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: HeraPalette.bg,
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: HeraPalette.textPrimary,
          displayColor: HeraPalette.textPrimary,
        ),
      ),
      child: _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
      backgroundColor: HeraPalette.bg,
      body: FadeTransition(
        opacity: _fadeCtrl,
        child: SafeArea(
          child: Column(
            children: [
              _Header(
                energy: context.watch<UserProvider>().energyBalance,
                pulseCtrl: _pulseCtrl,
                glowCtrl: _glowCtrl,
                onBack: () => Navigator.pop(context),
                onSpeak: _openVoicePage,
                onVision: () => setState(() => _selectedTab = 4),
                onHistory: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HeraHistoryPage(
                      actions: _recentActions,
                      isDark: false,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _PillTabBar(
                tabs: _tabs,
                selected: _selectedTab,
                onSelect: (i) => setState(() => _selectedTab = i),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: IndexedStack(
                  index: _selectedTab,
                  children: [
                    _buildFlux(),
                    _buildAgenda(),
                    _buildTeam(),
                    _buildEnergyView(),
                    _buildStatsRadarView(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlux() {
    final hasTimoAction = _recentActions.isNotEmpty &&
        _recentActions.first['details']?['agent'] == 'Timo';

    return RefreshIndicator(
      onRefresh: _loadAll,
      color: HeraPalette.mauve,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          if (_loadingStats)
            const _ShimmerBox(height: 200)
          else
            _WorkforcePulse(stats: _stats, pulseCtrl: _pulseCtrl),
          const SizedBox(height: 14),
          if (hasTimoAction) ...[
            const _TimoBanner(),
            const SizedBox(height: 14),
          ],
          _SectionHeader(
            label: 'Activité récente',
            action: 'Voir tout',
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HeraHistoryPage(
                  actions: _recentActions,
                  isDark: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_loadingActions) ...[
            const _ShimmerBox(height: 72),
            const SizedBox(height: 8),
            const _ShimmerBox(height: 72),
          ] else if (_recentActions.isEmpty)
            const _EmptyState(
              icon: Icons.history_rounded,
              title: 'Aucune activité',
              sub: '...',
            )
          else
            ..._recentActions.take(5).toList().asMap().entries.map(
                  (entry) => _buildActionCard(entry.value, entry.key),
            ),
        ],
      ),
    );
  }

  Widget _buildActionCard(Map<String, dynamic> action, int index) {
    final cfg = _actionConfig(action);
    final color = cfg['color'] as Color;
    final name = action['employee_name'] as String? ?? 'Employé';
    final createdAt = action['created_at'] != null
        ? DateTime.tryParse(action['created_at'].toString())
        : null;

    return Dismissible(
      key: Key('act_${_extractId(action['_id'])}_$index'),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => _deleteAction(index, _extractId(action['_id'])),
      background: const _DismissBackground(),
      child: GestureDetector(
        onTap: () => _showActionDetail(action),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: HeraPalette.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: HeraPalette.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(cfg['icon'] as IconData, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: HeraPalette.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cfg['label'] as String,
                      style: const TextStyle(
                        color: HeraPalette.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _Badge(label: cfg['badge'] as String, color: color),
                  if (createdAt != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      _timeAgo(createdAt),
                      style: const TextStyle(
                        color: HeraPalette.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteAction(int index, String? id) async {
    if (index >= _recentActions.length) return;

    final removed = _recentActions[index];
    setState(() => _recentActions.removeAt(index));

    if (id != null) {
      try {
        await HrAgentService.deleteAction(id);
      } catch (_) {
        if (!mounted) return;
        setState(() => _recentActions.insert(index, removed));
        _toast('Erreur suppression');
        return;
      }
    }

    if (mounted) _toast('Action supprimée');
  }

  void _showActionDetail(Map<String, dynamic> action) {
    final details = action['details'] is Map<String, dynamic>
        ? action['details'] as Map<String, dynamic>
        : <String, dynamic>{};

    final date = action['created_at'] != null
        ? DateFormat('dd MMMM yyyy · HH:mm', 'fr_FR')
        .format(DateTime.parse(action['created_at']))
        : 'Date inconnue';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: HeraPalette.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: HeraPalette.mauve, size: 18),
            SizedBox(width: 10),
            Text(
              'Détails',
              style: TextStyle(color: HeraPalette.textPrimary, fontSize: 16),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Type : ${action['action_type'] ?? '—'}',
                style: const TextStyle(
                  color: HeraPalette.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(
                  color: HeraPalette.textMuted,
                  fontSize: 11,
                ),
              ),
              const Divider(color: HeraPalette.border, height: 24),
              ...details.entries.map(
                    (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: HeraPalette.textPrimary,
                        fontSize: 13,
                      ),
                      children: [
                        TextSpan(
                          text: '${entry.key} : ',
                          style: const TextStyle(
                            color: HeraPalette.mauve,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: '${entry.value}'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Fermer',
              style: TextStyle(color: HeraPalette.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgenda() {
    final leaves = _selectedDay != null
        ? _leavesForDay(_selectedDay!)
        : <HeraLeave>[];

    return RefreshIndicator(
      onRefresh: _loadAll,
      color: HeraPalette.mauve,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          const _SectionHeader(label: 'Absences & Congés'),
          const SizedBox(height: 4),
          const Text(
            'Sélectionnez une date pour voir les absences approuvées.',
            style: TextStyle(color: HeraPalette.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          _buildCalendarCard(leaves),
          const SizedBox(height: 14),
          _buildCalendarLegend(),
          const SizedBox(height: 20),
          Text(
            _selectedDay != null
                ? 'Congés du ${DateFormat('d MMMM yyyy', 'fr_FR').format(_selectedDay!)}'
                : 'Sélectionnez une date',
            style: const TextStyle(
              color: HeraPalette.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (leaves.isEmpty)
            const _EmptyState(
              icon: Icons.event_available_rounded,
              title: 'Aucun congé',
              sub: 'Pas d\'absence ce jour-là',
            )
          else
            ...leaves.map(_buildLeaveDetailCard),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(List<HeraLeave> leaves) {
    return Container(
      decoration: BoxDecoration(
        color: HeraPalette.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: HeraPalette.border),
      ),
      child: TableCalendar<HeraLeave>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        onDaySelected: (selected, focused) {
          setState(() {
            _selectedDay = selected;
            _focusedDay = focused;
          });
        },
        onFormatChanged: (format) => setState(() => _calendarFormat = format),
        onPageChanged: (focused) => _focusedDay = focused,
        eventLoader: _leavesForDay,
        calendarBuilders: CalendarBuilders<HeraLeave>(
          defaultBuilder: (context, day, _) {
            final dayLeaves = _leavesForDay(day);
            if (dayLeaves.isEmpty) return null;

            final color = dayLeaves.any((leave) => leave.type == 'urgent')
                ? HeraPalette.danger
                : dayLeaves.any((leave) => leave.type == 'sick')
                ? HeraPalette.warning
                : HeraPalette.mauve;

            return Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return null;

            return Positioned(
              bottom: 3,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: events.take(3).map((leave) {
                  final color = leave.type == 'urgent'
                      ? HeraPalette.danger
                      : leave.type == 'sick'
                      ? HeraPalette.warning
                      : HeraPalette.mauve;

                  return Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(
            shape: BoxShape.circle,
            color: HeraPalette.mauve,
          ),
          selectedDecoration: BoxDecoration(
            shape: BoxShape.circle,
            color: HeraPalette.violet,
          ),
          todayTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
          selectedTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
          defaultTextStyle: TextStyle(
            color: HeraPalette.textPrimary,
            fontSize: 13,
          ),
          weekendTextStyle: TextStyle(
            color: HeraPalette.textSoft,
            fontSize: 13,
          ),
          outsideTextStyle: TextStyle(color: HeraPalette.border),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: HeraPalette.mauve.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          formatButtonTextStyle: const TextStyle(
            color: HeraPalette.mauve,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
          titleTextStyle: const TextStyle(
            color: HeraPalette.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
          leftChevronIcon: const Icon(
            Icons.chevron_left_rounded,
            color: HeraPalette.textPrimary,
            size: 24,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right_rounded,
            color: HeraPalette.textPrimary,
            size: 24,
          ),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: HeraPalette.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          weekendStyle: TextStyle(
            color: HeraPalette.textMuted,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarLegend() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HeraPalette.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HeraPalette.border),
      ),
      child: const Wrap(
        spacing: 20,
        runSpacing: 8,
        children: [
          _LegendChip(label: 'Congé annuel', color: HeraPalette.mauve),
          _LegendChip(label: 'Maladie', color: HeraPalette.warning),
          _LegendChip(label: 'Urgent', color: HeraPalette.danger),
        ],
      ),
    );
  }

  Widget _buildLeaveDetailCard(HeraLeave leave) {
    final fmt = DateFormat('d MMM yyyy', 'fr_FR');
    final icon = leave.type == 'sick'
        ? Icons.medical_services
        : leave.type == 'urgent'
        ? Icons.warning_amber_rounded
        : Icons.beach_access;
    final color = leave.type == 'sick'
        ? HeraPalette.warning
        : leave.type == 'urgent'
        ? HeraPalette.danger
        : HeraPalette.mauve;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HeraPalette.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HeraPalette.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.employeeName.isEmpty ? '—' : leave.employeeName,
                      style: const TextStyle(
                        color: HeraPalette.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${leave.days} jour${leave.days > 1 ? "s" : ""}',
                      style: const TextStyle(
                        color: HeraPalette.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: HeraPalette.cardSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 13,
                      color: HeraPalette.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${fmt.format(leave.startDate)} → ${fmt.format(leave.endDate)}',
                        style: const TextStyle(
                          color: HeraPalette.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                if (leave.reason.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 13,
                        color: HeraPalette.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          leave.reason,
                          style: const TextStyle(
                            color: HeraPalette.textSoft,
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

  Widget _buildTeam() {
    final active = _employees
        .where((emp) => emp.status == 'active' || emp.status == 'offboarding')
        .toList();

    final onboarding = _employees
        .where((emp) => emp.status == 'onboarding')
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: HeraPalette.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: HeraPalette.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SubTabPill(
                    label: 'Équipe',
                    count: active.length,
                    selected: _employeeSubTab == 0,
                    onTap: () => setState(() => _employeeSubTab = 0),
                  ),
                ),
                Expanded(
                  child: _SubTabPill(
                    label: 'Nouveaux',
                    count: onboarding.length,
                    selected: _employeeSubTab == 1,
                    onTap: () => setState(() => _employeeSubTab = 1),
                  ),
                ),
                Expanded(
                  child: _SubTabPill(
                    label: 'Candidats',
                    count: _candidates.length,
                    selected: _employeeSubTab == 2,
                    onTap: () => setState(() => _employeeSubTab = 2),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadAll,
            color: HeraPalette.mauve,
            child: _loadingEmployees
                ? const Center(
              child: CircularProgressIndicator(color: HeraPalette.mauve),
            )
                : _employeeSubTab == 0
                ? _buildActiveList(active)
                : _employeeSubTab == 1
                ? _buildOnboardingList(onboarding)
                : _buildCandidateList(_candidates),
          ),
        ),
      ],
    );
  }

  Widget _buildCandidateList(List<HeraCandidate> list) {
    if (list.isEmpty) {
      return const _EmptyState(
        icon: Icons.person_add_alt_1,
        title: 'Aucun candidat',
        sub: 'Hera attend des candidatures...',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final candidate = list[i];
        final score = candidate.scoreIa;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HeraPalette.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: HeraPalette.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: HeraPalette.mauve.withOpacity(0.1),
                child: const Icon(
                  Icons.person_outline,
                  color: HeraPalette.mauve,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      candidate.department,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: score >= 80
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$score%',
                  style: TextStyle(
                    color: score >= 80 ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveList(List<HeraEmployee> list) {
    if (list.isEmpty) {
      return const _EmptyState(
        icon: Icons.people_outline,
        title: 'Aucun employé actif',
        sub: 'Votre équipe est vide.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: list.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => _showEmployeeDocuments(list[index]),
        child: _ActiveCard(employee: list[index]),
      ),
    );
  }

  Widget _buildOnboardingList(List<HeraEmployee> list) {
    if (list.isEmpty) {
      return const _EmptyState(
        icon: Icons.celebration,
        title: 'Aucun nouvel arrivant',
        sub: 'Tout le monde est déjà actif.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: list.length,
      itemBuilder: (context, index) => _OnboardingCard(employee: list[index]),
    );
  }

  void _showEmployeeDocuments(HeraEmployee emp) {
    showModalBottomSheet(
      context: context,
      backgroundColor: HeraPalette.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: HeraPalette.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Documents · ${emp.name}',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Divider(color: HeraPalette.border, height: 24),
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: HrAgentService.getHistory(employeeId: emp.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: HeraPalette.mauve,
                        ),
                      );
                    }

                    final response = snapshot.data ?? {};
                    final actions = response['actions'] as List? ?? [];
                    final docs = actions.where((action) {
                      if (action is! Map) return false;
                      final type = action['action_type'];
                      return type == 'contract_renewal' ||
                          type == 'performance_alert';
                    }).toList();

                    if (docs.isEmpty) {
                      return Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            await HrAgentService.generateHeraDoc(
                              employeeId: emp.id,
                              docType: 'contract',
                            );
                            setSheet(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HeraPalette.mauve,
                          ),
                          child: const Text(
                            'Générer le contrat via Hera',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: docs.length,
                      itemBuilder: (_, index) {
                        final doc = Map<String, dynamic>.from(docs[index]);
                        final isContract =
                            doc['action_type'] == 'contract_renewal';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: HeraPalette.cardSoft,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: HeraPalette.mauve.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isContract
                                    ? Icons.description
                                    : Icons.payments,
                                color: HeraPalette.mauve,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isContract
                                      ? 'CONTRAT DE TRAVAIL'
                                      : 'BULLETIN DE PAIE',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.visibility_outlined,
                                  color: HeraPalette.mauve,
                                ),
                                onPressed: () => _viewDocument(doc),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.file_download_outlined,
                                  color: HeraPalette.lime,
                                ),
                                onPressed: () => _generatePdf(
                                  isContract ? 'Contrat' : 'Bulletin',
                                  doc['details']?['content'] ?? '',
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewDocument(Map<String, dynamic> doc) {
    final isContract = doc['action_type'] == 'contract_renewal';
    final title = isContract ? 'Contrat de Travail' : 'Bulletin de Paie';
    final content = doc['details']?['content'] as String? ?? 'Contenu indisponible';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.88,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'APERÇU · ${title.toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      content.replaceAll('*', ''),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontFamily: 'serif',
                        fontSize: 14,
                        height: 1.7,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: HeraPalette.lime,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.file_download),
                  label: const Text(
                    'TÉLÉCHARGER EN PDF',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  onPressed: () => _generatePdf(title, content),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generatePdf(String title, String content) async {
    final pdf = pw.Document();
    final cleanContent = content.replaceAll(RegExp(r'[^\x00-\x7F]'), '');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'E-TEAM — DOCUMENT OFFICIEL',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
                pw.Text(
                  DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              color: PdfColors.blueGrey50,
              child: pw.Text(
                title.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 30),
            pw.Text(
              cleanContent,
              style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
            ),
            pw.Spacer(),
            pw.Divider(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Certifié par Hera IA',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.blue700,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${title.replaceAll(' ', '_')}.pdf',
    );
  }

  Widget _buildEnergyView() {
    final energy = context.read<UserProvider>().energyBalance;

    final tasks = [
      ('Demande de congé', 10, Icons.event_note_rounded, HeraPalette.violet),
      ('Congé urgent', 15, Icons.flash_on_rounded, const Color(0xFFEC4899)),
      ('Onboarding employé', 25, Icons.person_add_alt_1_rounded, const Color(0xFF8B5CF6)),
      ('Promotion', 20, Icons.trending_up_rounded, const Color(0xFF06B6D4)),
      ('Évaluation performance', 18, Icons.workspace_premium, HeraPalette.warning),
      ('Offboarding', 30, Icons.exit_to_app_rounded, HeraPalette.danger),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        const Text(
          'Coût des tâches IA',
          style: TextStyle(
            color: HeraPalette.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        ...tasks.map((task) {
          final (label, cost, icon, taskColor) = task;
          final canAfford = energy >= cost;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HeraPalette.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: canAfford
                    ? HeraPalette.border
                    : HeraPalette.danger.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: taskColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: taskColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: HeraPalette.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '$cost ⚡ points',
                        style: TextStyle(
                          color: taskColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!canAfford)
                  const _Badge(label: 'INSUFFISANT', color: HeraPalette.danger)
                else
                  _Badge(label: '${energy - cost} restants', color: taskColor),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: HeraPalette.cardSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HeraPalette.border),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: HeraPalette.mauve),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'L\'énergie se recharge chaque jour. Chaque action IA consomme des points selon sa complexité.',
                  style: TextStyle(color: HeraPalette.textMuted, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRadarView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: HeraPalette.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: HeraPalette.mauve.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: HeraPalette.mauve.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.radar_rounded,
                  color: HeraPalette.mauve,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Analyse de Densité',
                      style: TextStyle(
                        color: HeraPalette.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${_employees.length} collaborateurs · ${_deptMax.length} départements',
                      style: const TextStyle(
                        color: HeraPalette.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Densité par département',
          style: TextStyle(
            color: HeraPalette.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 16),
        ..._deptMax.entries.map((entry) {
          final count = _countInDept(entry.key);
          final pct = (count / entry.value).clamp(0.0, 1.0);
          final isFull = pct >= 0.8;
          final color = isFull ? HeraPalette.mauve : const Color(0xFFB971FF);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: HeraPalette.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: HeraPalette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        color: HeraPalette.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$count / ${entry.value}',
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: color.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: HeraPalette.cardSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HeraPalette.border),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: HeraPalette.mauve),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Mauve = département à ≥ 80% de capacité. Orange = sous-effectif, recrutement recommandé.',
                  style: TextStyle(color: HeraPalette.textMuted, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final int energy;
  final AnimationController pulseCtrl;
  final AnimationController glowCtrl;
  final VoidCallback onBack;
  final VoidCallback onSpeak;
  final VoidCallback onVision;
  final VoidCallback onHistory;

  const _Header({
    required this.energy,
    required this.pulseCtrl,
    required this.glowCtrl,
    required this.onBack,
    required this.onSpeak,
    required this.onVision,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: HeraPalette.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: HeraPalette.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _CircleBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
              const SizedBox(width: 12),
              AnimatedBuilder(
                animation: glowCtrl,
                builder: (_, child) => Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: HeraPalette.mauve.withOpacity(
                          0.3 + 0.2 * glowCtrl.value,
                        ),
                        blurRadius: 14 + 8 * glowCtrl.value,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: child,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(23),
                  child: Image.asset(
                    'assets/images/hera.png',
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Agent Hera',
                      style: TextStyle(
                        color: HeraPalette.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: pulseCtrl,
                          builder: (_, __) => Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: HeraPalette.lime.withOpacity(
                                0.6 + 0.4 * pulseCtrl.value,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'SURVEILLANCE IA ACTIVE',
                          style: TextStyle(
                            color: HeraPalette.lime,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: HeraPalette.cardSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '⚡ $energy',
                  style: const TextStyle(
                    color: HeraPalette.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _QuickBtn(
                  icon: Icons.graphic_eq_rounded,
                  label: 'PARLER',
                  isPrimary: true,
                  onTap: onSpeak,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickBtn(
                  icon: Icons.history_rounded,
                  label: 'Historique',
                  isPrimary: false,
                  onTap: onHistory,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickBtn(
                  icon: Icons.radar_rounded,
                  label: 'Vision IA',
                  isPrimary: false,
                  onTap: onVision,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: HeraPalette.cardSoft,
        ),
        child: Icon(icon, color: HeraPalette.textPrimary, size: 16),
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _QuickBtn({
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary ? HeraPalette.mauve : HeraPalette.cardSoft,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(color: HeraPalette.border),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isPrimary ? Colors.white : HeraPalette.textSoft,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : HeraPalette.textSoft,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillTabBar extends StatelessWidget {
  final List<(IconData, String)> tabs;
  final int selected;
  final ValueChanged<int> onSelect;

  const _PillTabBar({
    required this.tabs,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: HeraPalette.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HeraPalette.border),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final selectedTab = selected == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selectedTab ? HeraPalette.mauve : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tabs[index].$1,
                      size: 17,
                      color: selectedTab ? Colors.white : HeraPalette.textMuted,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tabs[index].$2,
                      style: TextStyle(
                        color:
                        selectedTab ? Colors.white : HeraPalette.textMuted,
                        fontSize: 10,
                        fontWeight:
                        selectedTab ? FontWeight.w800 : FontWeight.w500,
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
}

class _WorkforcePulse extends StatelessWidget {
  final HeraStats? stats;
  final AnimationController pulseCtrl;

  const _WorkforcePulse({required this.stats, required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    final total = stats?.totalEmployees ?? 0;
    final onLeave = stats?.onLeaveToday ?? 0;
    final active = total - onLeave;
    final monthly = stats?.monthlyLeaveDays ?? 0;

    return AnimatedBuilder(
      animation: pulseCtrl,
      builder: (_, child) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF7C3AED).withOpacity(
                0.13 + 0.04 * pulseCtrl.value,
              ),
              const Color(0xFFB57BFF).withOpacity(0.07),
              HeraPalette.bg,
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFF7C3AED).withOpacity(
              0.45 + 0.1 * pulseCtrl.value,
            ),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(
                0.10 + 0.04 * pulseCtrl.value,
              ),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: child,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'WORKFORCE PULSE',
                style: TextStyle(
                  color: Color(0xFF7C3AED),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.8,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Color(0xFF7C3AED),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _PulseItem(
                  value: '$total',
                  label: 'Effectif total',
                  icon: Icons.groups_2_rounded,
                  color: HeraPalette.mauve,
                ),
              ),
              const _VertDivider(),
              Expanded(
                child: _PulseItem(
                  value: '$active',
                  label: 'Actifs',
                  icon: Icons.person_rounded,
                  color: HeraPalette.success,
                ),
              ),
              const _VertDivider(),
              Expanded(
                child: _PulseItem(
                  value: '$onLeave',
                  label: 'En congé',
                  icon: Icons.beach_access_rounded,
                  color: HeraPalette.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: HeraPalette.cardSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  size: 14,
                  color: HeraPalette.textMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  '$monthly jours de congé ce mois',
                  style: const TextStyle(
                    color: HeraPalette.textSoft,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _PulseItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: HeraPalette.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: HeraPalette.textMuted, fontSize: 10),
        ),
      ],
    );
  }
}

class _VertDivider extends StatelessWidget {
  const _VertDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 60, width: 1, color: HeraPalette.border);
  }
}

class _TimoBanner extends StatelessWidget {
  const _TimoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HeraPalette.timo.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HeraPalette.timo.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: HeraPalette.timo, size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'L\'agent Timo a confirmé un planning — calendrier mis à jour.',
              style: TextStyle(
                color: HeraPalette.timo,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Icon(
            Icons.check_circle,
            color: HeraPalette.timo.withOpacity(0.5),
            size: 16,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final String? action;
  final VoidCallback? onAction;

  const _SectionHeader({required this.label, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: HeraPalette.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: HeraPalette.mauve.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                action!,
                style: const TextStyle(
                  color: HeraPalette.mauve,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SubTabPill extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _SubTabPill({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? HeraPalette.mauve : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : HeraPalette.textMuted,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color:
                  selected ? Colors.white.withOpacity(0.2) : HeraPalette.cardSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: selected ? Colors.white : HeraPalette.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActiveCard extends StatelessWidget {
  final HeraEmployee employee;

  const _ActiveCard({required this.employee});

  @override
  Widget build(BuildContext context) {
    String getBalance(String type) {
      final data = employee.balances[type];
      if (data is! Map) return '0/0';
      return '${data['remaining'] ?? 0}/${data['total'] ?? 0}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HeraPalette.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HeraPalette.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: HeraPalette.mauve.withOpacity(0.15),
            child: Text(
              employee.name.isNotEmpty ? employee.name[0] : '?',
              style: const TextStyle(
                color: HeraPalette.mauve,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: const TextStyle(
                    color: HeraPalette.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  employee.role.isEmpty ? 'Employé' : employee.role,
                  style: const TextStyle(
                    color: HeraPalette.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _MiniBadge(
                      icon: Icons.beach_access,
                      value: getBalance('annual'),
                    ),
                    const SizedBox(width: 6),
                    _MiniBadge(
                      icon: Icons.medical_services,
                      value: getBalance('sick'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: HeraPalette.textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final IconData icon;
  final String value;

  const _MiniBadge({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: HeraPalette.cardSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: HeraPalette.textMuted),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: HeraPalette.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  final HeraEmployee employee;

  const _OnboardingCard({required this.employee});

  @override
  Widget build(BuildContext context) {
    String? rawDate;
    final contract = employee.contract;

    if (contract != null) {
      rawDate = contract['start']?.toString();
    }

    String dateText = 'Date non définie';
    String countdown = '';

    if (rawDate != null && rawDate.isNotEmpty) {
      try {
        final start = DateTime.parse(rawDate);
        dateText = DateFormat('d MMMM yyyy', 'fr_FR').format(start);

        final today = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );
        final diff = start.difference(today).inDays;

        if (diff == 0) {
          countdown = 'Arrive aujourd\'hui';
        } else if (diff == 1) {
          countdown = 'Arrive demain';
        } else if (diff > 0) {
          countdown = 'Dans $diff jours';
        } else {
          countdown = 'Arrivé';
        }
      } catch (_) {
        dateText = 'Format date invalide';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HeraPalette.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HeraPalette.mauve.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: HeraPalette.mauve.withOpacity(0.1),
                child: Text(
                  employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: HeraPalette.mauve,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${employee.role} · ${employee.department}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const _Badge(label: 'NOUVEAU', color: HeraPalette.mauve),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date de début prévue',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateText,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                if (countdown.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: HeraPalette.mauve.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      countdown,
                      style: const TextStyle(
                        color: HeraPalette.mauve,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color, width: 1.5),
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
}

class _DismissBackground extends StatelessWidget {
  const _DismissBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: HeraPalette.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      child: const Row(
        children: [
          Icon(Icons.delete_outline_rounded, color: HeraPalette.danger, size: 20),
          SizedBox(width: 6),
          Text(
            'Supprimer',
            style: TextStyle(
              color: HeraPalette.danger,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double height;

  const _ShimmerBox({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: HeraPalette.card,
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: HeraPalette.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: HeraPalette.border),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: HeraPalette.mauve.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: HeraPalette.mauve, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: HeraPalette.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: const TextStyle(color: HeraPalette.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
