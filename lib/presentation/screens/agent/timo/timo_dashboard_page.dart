import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:e_team/data/services/timo_service.dart';
import 'package:e_team/presentation/models/timo/timo_task_view_model.dart';
import 'package:e_team/presentation/widgets/timo/timo_design_system.dart';
import 'package:e_team/presentation/widgets/timo/timo_agenda_tab.dart';
import 'package:e_team/presentation/widgets/timo/timo_journal_tab.dart';
import 'package:e_team/presentation/widgets/timo/timo_chrome_widgets.dart';

// ─────────────────────────────────────────────────────────────
//  PAGE PRINCIPALE
// ─────────────────────────────────────────────────────────────
class TimoDashboardPage extends StatefulWidget {
  const TimoDashboardPage({super.key});
  @override
  State<TimoDashboardPage> createState() => _TimoDashboardPageState();
}

class _TimoDashboardPageState extends State<TimoDashboardPage>
    with TickerProviderStateMixin {
  int _tab = 0;
  TaskType? _activeFilter;

  bool _isLoading = true;
  List<TimoTask> _tasks = [];

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calFmt = CalendarFormat.month;

  // ✅ ANIMATION CONTROLLER POUR PULSATION UNIQUEMENT
  late AnimationController _pulseController;

  static const _tabs = [
    (Icons.article_rounded, 'Journal IA'),
    (Icons.calendar_month_rounded, 'Agenda'),
  ];

  // ── Lifecycle ──────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    // ✅ INITIALISER UNIQUEMENT LE CONTROLLER DE PULSATION
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _loadData();
  }

  @override
  void dispose() {
    // ✅ DISPOSER LE CONTROLLER
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final r = await TimoService.getTimoTasks();
      if (mounted) {
        setState(() {
          _tasks = List<Map<String, dynamic>>.from(
            r['tasks'] ?? [],
          ).map(TimoTask.fromMap).toList();

          // ✅ TRI CHRONOLOGIQUE PAR DATE (DEADLINE)
          _tasks.sort((a, b) {
            if (a.deadline == null && b.deadline == null) return 0;
            if (a.deadline == null) return 1;
            if (b.deadline == null) return -1;
            return a.deadline!.compareTo(b.deadline!);
          });

          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Computed ───────────────────────────────────────────────
  List<TimoTask> get _interviews =>
      _tasks.where((t) => t.type == TaskType.interview).toList();
  List<TimoTask> get _onboardings =>
      _tasks.where((t) => t.type == TaskType.onboarding).toList();
  List<TimoTask> get _offboardings =>
      _tasks.where((t) => t.type == TaskType.offboarding).toList();
  List<TimoTask> get _done => _tasks.where((t) => t.isDone).toList();

  List<TimoTask> get _filtered => _activeFilter == null
      ? _tasks
      : _tasks.where((t) => t.type == _activeFilter).toList();

  List<TimoTask> _tasksOn(DateTime day) => _tasks
      .where((t) => t.deadline != null && isSameDay(t.deadline!, day))
      .toList();

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TimoDesignSystem.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildProfessionalHeader(),
            const SizedBox(height: 10),
            _buildCleanNavigation(),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: TimoDesignSystem.other,
                      ),
                    )
                  : IndexedStack(
                      index: _tab,
                      children: [_buildJournal(), _buildAgenda()],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  PROFESSIONAL HEADER - WHITE SAAS DESIGN
  // ════════════════════════════════════════════════════════════
  Widget _buildProfessionalHeader() {
    return TimoHeader(
      pulseController: _pulseController,
      onBack: () => Navigator.pop(context),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  CLEAN NAVIGATION
  // ════════════════════════════════════════════════════════════
  Widget _buildCleanNavigation() {
    return TimoNavigation(
      tabs: _tabs,
      selected: _tab,
      onSelect: (index) => setState(() => _tab = index),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  TAB 0 — JOURNAL IA - WHITE SAAS DESIGN
  // ════════════════════════════════════════════════════════════
  Widget _buildJournal() {
    return TimoJournalTab(
      tasks: _tasks,
      filteredTasks: _filtered,
      activeFilter: _activeFilter,
      interviewsCount: _interviews.length,
      onboardingsCount: _onboardings.length,
      offboardingsCount: _offboardings.length,
      doneCount: _done.length,
      onRefresh: _loadData,
      onFilterChanged: (filter) => setState(() => _activeFilter = filter),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  TAB 1 — AGENDA - WHITE SAAS DESIGN
  // ════════════════════════════════════════════════════════════
  Widget _buildAgenda() {
    final dayTasks = _selectedDay != null
        ? _tasksOn(_selectedDay!)
        : <TimoTask>[];

    return TimoAgendaTab(
      tasks: _tasks,
      dayTasks: dayTasks,
      focusedDay: _focusedDay,
      selectedDay: _selectedDay,
      calendarFormat: _calFmt,
      tasksOn: _tasksOn,
      onRefresh: _loadData,
      onDaySelected: (selected, focused) => setState(() {
        _selectedDay = selected;
        _focusedDay = focused;
      }),
      onFormatChanged: (format) => setState(() => _calFmt = format),
      onPageChanged: (focused) => setState(() => _focusedDay = focused),
      onToggleFormat: () => setState(
        () => _calFmt = _calFmt == CalendarFormat.month
            ? CalendarFormat.week
            : CalendarFormat.month,
      ),
    );
  }
}
