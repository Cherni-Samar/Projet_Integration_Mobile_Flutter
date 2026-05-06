import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:e_team/data/services/timo_service.dart';
import 'package:e_team/presentation/models/timo/timo_task_view_model.dart';
import 'package:e_team/presentation/widgets/timo/timo_design_system.dart';
import 'package:e_team/presentation/widgets/timo/timo_shared_widgets.dart';

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
    if (_tasks.isEmpty) {
      return _emptyState(
        Icons.article_outlined,
        'Aucune tâche planifiée',
        'Hera n\'a encore rien envoyé à Timo.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: TimoDesignSystem.other,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        children: [
          // ── Stats par type ──
          _buildCleanStats(),
          const SizedBox(height: 16),

          // ── Filtres pills ──
          _buildFilterPills(),
          const SizedBox(height: 16),

          // ── Tâches filtrées ──
          if (_filtered.isEmpty)
            _emptyState(
              Icons.filter_list_off_rounded,
              'Aucun résultat',
              'Pas de tâche pour ce filtre.',
            )
          else
            ..._filtered.map((t) => _buildTaskCard(t)),
        ],
      ),
    );
  }

  // ── Stats: Interviews / Onboardings / Offboardings ─────────
  Widget _buildCleanStats() {
    return TimoStatsCard(
      interviews: _interviews.length,
      onboardings: _onboardings.length,
      offboardings: _offboardings.length,
      done: _done.length,
      total: _tasks.length,
    );
  }

  // ── Filtres pills ───────────────────────────────────────────
  Widget _buildFilterPills() {
    final filters = [
      (null, 'Tous', TimoDesignSystem.other),
      (TaskType.interview, 'Interview', TimoDesignSystem.interview),
      (TaskType.onboarding, 'Onboarding', TimoDesignSystem.onboarding),
      (TaskType.offboarding, 'Offboarding', TimoDesignSystem.offboarding),
    ];
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: filters.map((f) {
          final sel = _activeFilter == f.$1;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = f.$1),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: sel ? f.$3 : TimoDesignSystem.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel ? f.$3 : TimoDesignSystem.border,
                  width: 0.5,
                ),
              ),
              child: Text(
                f.$2,
                style: GoogleFonts.plusJakartaSans(
                  color: sel ? Colors.white : TimoDesignSystem.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Carte tâche avec design amélioré ─────────────────────────────────────────────
  Widget _buildTaskCard(TimoTask task) {
    return TimoTaskCard(task: task);
  }

  // ════════════════════════════════════════════════════════════
  //  TAB 1 — AGENDA - WHITE SAAS DESIGN
  // ════════════════════════════════════════════════════════════
  Widget _buildAgenda() {
    final dayTasks = _selectedDay != null
        ? _tasksOn(_selectedDay!)
        : <TimoTask>[];

    return RefreshIndicator(
      onRefresh: _loadData,
      color: TimoDesignSystem.other,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        children: [
          // Calendrier
          Container(
            decoration: BoxDecoration(
              color: TimoDesignSystem.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TimoDesignSystem.border, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: TimoDesignSystem.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header custom
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat(
                              'MMMM yyyy',
                              'fr_FR',
                            ).format(_focusedDay).toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              color: TimoDesignSystem.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            '${_tasks.length} événements',
                            style: GoogleFonts.plusJakartaSans(
                              color: TimoDesignSystem.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Toggle semaine / mois
                      GestureDetector(
                        onTap: () => setState(
                          () => _calFmt = _calFmt == CalendarFormat.month
                              ? CalendarFormat.week
                              : CalendarFormat.month,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: TimoDesignSystem.other.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _calFmt == CalendarFormat.month
                                    ? Icons.view_week_rounded
                                    : Icons.calendar_month_rounded,
                                size: 13,
                                color: TimoDesignSystem.other,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _calFmt == CalendarFormat.month
                                    ? 'Semaine'
                                    : 'Mois',
                                style: GoogleFonts.plusJakartaSans(
                                  color: TimoDesignSystem.other,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calFmt,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (sel, foc) => setState(() {
                    _selectedDay = sel;
                    _focusedDay = foc;
                  }),
                  onFormatChanged: (f) => setState(() => _calFmt = f),
                  onPageChanged: (f) => setState(() => _focusedDay = f),
                  eventLoader: _tasksOn,
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (ctx, day, _) {
                      final ts = _tasksOn(day);
                      if (ts.isEmpty) return null;
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: TimoDesignSystem.other.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: TimoDesignSystem.other.withValues(
                              alpha: 0.45,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: GoogleFonts.plusJakartaSans(
                              color: TimoDesignSystem.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                    todayBuilder: (ctx, day, _) => Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: TimoDesignSystem.other,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    selectedBuilder: (ctx, day, _) => Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF57C00),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: TimoDesignSystem.other.withValues(
                              alpha: 0.5,
                            ),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    // Points colorés selon le type
                    markerBuilder: (ctx, date, events) {
                      final ts = events.cast<TimoTask>();
                      if (ts.isEmpty) return null;
                      return Positioned(
                        bottom: 4,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: ts
                              .take(3)
                              .map(
                                (t) => Container(
                                  width: 5,
                                  height: 5,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: t.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      );
                    },
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: const BoxDecoration(),
                    selectedDecoration: const BoxDecoration(),
                    defaultTextStyle: GoogleFonts.plusJakartaSans(
                      color: TimoDesignSystem.textPrimary,
                      fontSize: 13,
                    ),
                    weekendTextStyle: GoogleFonts.plusJakartaSans(
                      color: TimoDesignSystem.textMuted,
                      fontSize: 13,
                    ),
                    outsideTextStyle: GoogleFonts.plusJakartaSans(
                      color: TimoDesignSystem.textMuted.withValues(alpha: 0.35),
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: false,
                    titleTextStyle: const TextStyle(fontSize: 0),
                    leftChevronIcon: Icon(
                      Icons.chevron_left_rounded,
                      color: TimoDesignSystem.textPrimary,
                      size: 24,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right_rounded,
                      color: TimoDesignSystem.textPrimary,
                      size: 24,
                    ),
                    headerPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: GoogleFonts.plusJakartaSans(
                      color: TimoDesignSystem.textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                    weekendStyle: GoogleFonts.plusJakartaSans(
                      color: TimoDesignSystem.other.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Légende types
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: TimoDesignSystem.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TimoDesignSystem.border, width: 0.5),
            ),
            child: Wrap(
              spacing: 18,
              runSpacing: 8,
              children: [
                _legendChip('Interview', TimoDesignSystem.interview),
                _legendChip('Onboarding', TimoDesignSystem.onboarding),
                _legendChip('Offboarding', TimoDesignSystem.offboarding),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tâches du jour sélectionné
          Row(
            children: [
              Text(
                _selectedDay != null
                    ? 'Plannings du ${DateFormat('d MMMM', 'fr_FR').format(_selectedDay!)}'
                    : 'Sélectionnez une date',
                style: GoogleFonts.plusJakartaSans(
                  color: TimoDesignSystem.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              if (dayTasks.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: TimoDesignSystem.other.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${dayTasks.length}',
                    style: GoogleFonts.plusJakartaSans(
                      color: TimoDesignSystem.other,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (dayTasks.isEmpty)
            _emptyState(
              Icons.event_available_rounded,
              'Aucun planning',
              'Rien de planifié ce jour-là.',
            )
          else
            ...dayTasks.map((t) => _buildTaskCard(t)),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  SHARED HELPERS - WHITE SAAS DESIGN
  // ════════════════════════════════════════════════════════════
  Widget _legendChip(String label, Color color) {
    return TimoLegendChip(label: label, color: color);
  }

  Widget _emptyState(IconData icon, String title, String sub) {
    return TimoEmptyState(icon: icon, title: title, sub: sub);
  }
}
