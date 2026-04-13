import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../services/timo_service.dart';

// ─────────────────────────────────────────────────────────────
//  PALETTE TIMO
// ─────────────────────────────────────────────────────────────
class TP {
  static const bronze  = Color(0xFFDB965B);
  static const bronzeD = Color(0xFFC47A3A);
  static const gold    = Color(0xFFFFD580);
  static const success = Color(0xFF10B981);
  static const info    = Color(0xFF06B6D4);
  static const danger  = Color(0xFFEF4444);
  static const violet  = Color(0xFF8B5CF6);

  static Color bg(bool d)        => d ? const Color(0xFF0A0A0A) : const Color(0xFFF5F3F0);
  static Color card(bool d)      => d ? const Color(0xFF141414) : Colors.white;
  static Color cardSoft(bool d)  => d ? const Color(0xFF1C1C1C) : const Color(0xFFEEEBE7);
  static Color border(bool d)    => d ? const Color(0xFF252525) : const Color(0xFFE0DBD4);
  static Color text(bool d)      => d ? Colors.white            : const Color(0xFF1A1008);
  static Color textMuted(bool d) => d ? const Color(0xFF777777) : const Color(0xFF8B7D6E);
  static Color textSoft(bool d)  => d ? const Color(0xFF444444) : const Color(0xFFB5A99A);
}

// ─────────────────────────────────────────────────────────────
//  HELPERS — parser le titre "[TYPE] : Nom"
// ─────────────────────────────────────────────────────────────
enum TaskType { interview, onboarding, offboarding, other }

class TimoTask {
  final String    raw;
  final String    employeeName;
  final TaskType  type;
  final String    status;
  final DateTime? deadline;
  final String    id;

  TimoTask({
    required this.raw,
    required this.employeeName,
    required this.type,
    required this.status,
    required this.deadline,
    required this.id,
  });

  factory TimoTask.fromMap(Map<String, dynamic> m) {
    final title  = m['title'] as String? ?? '';
    final status = m['status'] as String? ?? 'todo';
    final id     = m['_id']?.toString() ?? '';

    DateTime? deadline;
    try { deadline = DateTime.parse(m['deadline']); } catch (_) {}

    // Parse "[INTERVIEW] : Ahmed" → type + nom
    TaskType type = TaskType.other;
    String   name = title;

    final match = RegExp(r'\[(\w+)\]\s*:\s*(.+)').firstMatch(title);
    if (match != null) {
      final typeStr = match.group(1)?.toUpperCase() ?? '';
      name = match.group(2)?.trim() ?? title;
      switch (typeStr) {
        case 'INTERVIEW':   type = TaskType.interview;   break;
        case 'ONBOARDING':  type = TaskType.onboarding;  break;
        case 'OFFBOARDING': type = TaskType.offboarding; break;
      }
    }

    return TimoTask(raw: title, employeeName: name, type: type,
        status: status, deadline: deadline, id: id);
  }

  bool get isDone => status == 'done';

  // Config visuelle selon le type
  IconData get icon => switch (type) {
    TaskType.interview   => Icons.record_voice_over_rounded,
    TaskType.onboarding  => Icons.person_add_alt_1_rounded,
    TaskType.offboarding => Icons.exit_to_app_rounded,
    TaskType.other       => Icons.event_rounded,
  };

  Color get color => switch (type) {
    TaskType.interview   => TP.info,
    TaskType.onboarding  => TP.success,
    TaskType.offboarding => TP.danger,
    TaskType.other       => TP.bronze,
  };

  String get typeLabel => switch (type) {
    TaskType.interview   => 'INTERVIEW',
    TaskType.onboarding  => 'ONBOARDING',
    TaskType.offboarding => 'OFFBOARDING',
    TaskType.other       => 'TÂCHE',
  };
}

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

  int _tab    = 0;
  TaskType? _activeFilter;
  bool _isLoading = true;
  List<TimoTask> _tasks = [];

  DateTime  _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calFmt = CalendarFormat.month;

  late AnimationController _pulseCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _glowCtrl;

  static const _tabs = [
    (Icons.article_rounded,        'Journal IA'),
    (Icons.calendar_month_rounded, 'Agenda'),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _fadeCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
    _glowCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _loadData();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final r = await TimoService.getTimoTasks();
      if (mounted) setState(() {
        _tasks = List<Map<String, dynamic>>.from(r['tasks'] ?? [])
            .map(TimoTask.fromMap)
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<TimoTask> get _interviews   => _tasks.where((t) => t.type == TaskType.interview).toList();
  List<TimoTask> get _onboardings  => _tasks.where((t) => t.type == TaskType.onboarding).toList();
  List<TimoTask> get _offboardings => _tasks.where((t) => t.type == TaskType.offboarding).toList();
  List<TimoTask> get _done         => _tasks.where((t) => t.isDone).toList();

  List<TimoTask> get _filtered => _activeFilter == null
      ? _tasks
      : _tasks.where((t) => t.type == _activeFilter).toList();

  List<TimoTask> _tasksOn(DateTime day) => _tasks.where((t) =>
  t.deadline != null && isSameDay(t.deadline!, day)).toList();

  @override
  Widget build(BuildContext context) {
    final d = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: TP.bg(d),
      body: FadeTransition(
        opacity: _fadeCtrl,
        child: SafeArea(child: Column(children: [
          _buildHeader(d),
          const SizedBox(height: 10),
          _buildPillTabBar(d),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: TP.bronze))
                : IndexedStack(index: _tab, children: [
              _buildJournal(d),
              _buildAgenda(d),
            ]),
          ),
        ])),
      ),
    );
  }

  Widget _buildHeader(bool d) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: TP.card(d),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: TP.border(d))),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: d ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.07)),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: TP.text(d), size: 16)),
        ),
        const SizedBox(width: 12),

        AnimatedBuilder(
          animation: _glowCtrl,
          builder: (_, child) => Container(
              decoration: BoxDecoration(shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                      color: TP.bronze.withOpacity(0.25 + 0.2 * _glowCtrl.value),
                      blurRadius: 14 + 8 * _glowCtrl.value)]),
              child: child),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: Image.asset(
                'assets/images/krono.png',
                width: 46, height: 46, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => CircleAvatar(
                    backgroundColor: TP.bronze,
                    child: const Icon(Icons.timer_rounded, color: Colors.white))),
          ),
        ),
        const SizedBox(width: 12),

        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Agent Timo', style: TextStyle(
              color: TP.text(d), fontSize: 18, fontWeight: FontWeight.w900)),
          Row(children: [
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) => Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: TP.bronze.withOpacity(0.6 + 0.4 * _pulseCtrl.value))),
            ),
            const SizedBox(width: 5),
            const Text('LOGISTICS MASTER SYNC',
                style: TextStyle(color: TP.bronze, fontSize: 9,
                    fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          ]),
        ])),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
              color: d ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12)),
          child: Text('📋 ${_tasks.length}',
              style: TextStyle(color: TP.text(d), fontSize: 13, fontWeight: FontWeight.w900)),
        ),
      ]),
    );
  }

  Widget _buildPillTabBar(bool d) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
        color: TP.card(d),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TP.border(d))),
    child: Row(children: List.generate(_tabs.length, (i) {
      final sel = _tab == i;
      return Expanded(child: GestureDetector(
        onTap: () => setState(() => _tab = i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: sel ? TP.bronze : Colors.transparent,
              borderRadius: BorderRadius.circular(16)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(_tabs[i].$1, size: 17, color: sel ? Colors.white : TP.textMuted(d)),
            const SizedBox(height: 3),
            Text(_tabs[i].$2, style: TextStyle(
                color: sel ? Colors.white : TP.textMuted(d),
                fontSize: 10, fontWeight: sel ? FontWeight.w800 : FontWeight.w500)),
          ]),
        ),
      ));
    })),
  );

  Widget _buildJournal(bool d) {
    if (_tasks.isEmpty) return _emptyState(
        Icons.article_outlined, 'Aucune tâche planifiée',
        'Hera n\'a encore rien envoyé à Timo.', d);

    return RefreshIndicator(
      onRefresh: _loadData,
      color: TP.bronze,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        children: [
          _buildStatsPulse(d),
          const SizedBox(height: 16),
          _buildFilterPills(d),
          const SizedBox(height: 16),
          if (_filtered.isEmpty)
            _emptyState(Icons.filter_list_off_rounded,
                'Aucun résultat', 'Pas de tâche pour ce filtre.', d)
          else
            ..._filtered.map((t) => _buildTaskCard(t, d)),
        ],
      ),
    );
  }

  Widget _buildStatsPulse(bool d) {
    final total = _tasks.length;
    final done  = _done.length;
    final pct   = total == 0 ? 0.0 : done / total;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: TP.card(d),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: TP.border(d))),
      child: Column(children: [
        Row(children: [
          Expanded(child: _statItem('${_interviews.length}',   'INTERVIEWS',   TP.info,    Icons.record_voice_over_rounded,  d)),
          Container(width: 1, height: 50, color: TP.border(d)),
          Expanded(child: _statItem('${_onboardings.length}',  'ONBOARDINGS',  TP.success, Icons.person_add_alt_1_rounded,   d)),
          Container(width: 1, height: 50, color: TP.border(d)),
          Expanded(child: _statItem('${_offboardings.length}', 'OFFBOARDINGS', TP.danger,  Icons.exit_to_app_rounded,        d)),
        ]),
        const SizedBox(height: 16),

        Row(children: [
          Text('Complétés', style: TextStyle(color: TP.textMuted(d), fontSize: 11)),
          const Spacer(),
          Text('$done / $total',
              style: TextStyle(color: pct > 0.7 ? TP.success : TP.bronze,
                  fontSize: 12, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
                value: pct, minHeight: 7,
                backgroundColor: TP.cardSoft(d),
                valueColor: AlwaysStoppedAnimation(pct > 0.7 ? TP.success : TP.bronze))),
      ]),
    );
  }

  Widget _statItem(String val, String label, Color color, IconData icon, bool d) =>
      Column(children: [
        Container(width: 38, height: 38,
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18)),
        const SizedBox(height: 6),
        Text(val, style: TextStyle(color: TP.text(d), fontSize: 22,
            fontWeight: FontWeight.w900, height: 1)),
        const SizedBox(height: 2),
        Text(label, textAlign: TextAlign.center,
            style: TextStyle(color: TP.textMuted(d), fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
      ]);

  Widget _buildFilterPills(bool d) {
    final filters = [
      (null,               'Tous',         TP.bronze),
      (TaskType.interview,  'Interview',   TP.info),
      (TaskType.onboarding, 'Onboarding',  TP.success),
      (TaskType.offboarding,'Offboarding', TP.danger),
    ];
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: filters.map((f) {
          final sel = _activeFilter == f.$1;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = f.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                  color: sel ? f.$3 : TP.cardSoft(d),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: sel ? f.$3 : TP.border(d))),
              child: Text(f.$2, style: TextStyle(
                  color: sel ? Colors.white : TP.textMuted(d),
                  fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskCard(TimoTask task, bool d) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: TP.card(d),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: task.isDone
                  ? TP.success.withOpacity(0.25)
                  : task.color.withOpacity(0.2))),
      child: Row(children: [
        Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
                color: task.isDone
                    ? TP.success.withOpacity(0.12)
                    : task.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(
                task.isDone ? Icons.task_alt_rounded : task.icon,
                color: task.isDone ? TP.success : task.color, size: 22)),
        const SizedBox(width: 12),

        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(task.employeeName, style: TextStyle(
              color: task.isDone ? TP.textMuted(d) : TP.text(d),
              fontWeight: FontWeight.w900, fontSize: 15,
              decoration: task.isDone ? TextDecoration.lineThrough : null,
              decorationColor: TP.textMuted(d))),
          const SizedBox(height: 4),
          if (task.deadline != null)
            Row(children: [
              Icon(Icons.schedule_rounded, size: 12, color: TP.textMuted(d)),
              const SizedBox(width: 4),
              Text(
                  DateFormat('EEE dd MMM · HH:mm', 'fr_FR').format(task.deadline!),
                  style: TextStyle(color: TP.textMuted(d), fontSize: 11)),
            ]),
        ])),

        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                  color: task.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(task.typeLabel, style: TextStyle(
                  color: task.color, fontSize: 8,
                  fontWeight: FontWeight.w900, letterSpacing: 0.5))),
          if (task.isDone) ...[
            const SizedBox(height: 6),
            const Icon(Icons.verified_rounded, color: TP.success, size: 16),
          ],
        ]),
      ]),
    );
  }

  Widget _buildAgenda(bool d) {
    final dayTasks = _selectedDay != null ? _tasksOn(_selectedDay!) : <TimoTask>[];

    return RefreshIndicator(
      onRefresh: _loadData,
      color: TP.bronze,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        children: [
          Container(
            decoration: BoxDecoration(
                color: TP.card(d),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: TP.border(d))),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: Row(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                        DateFormat('MMMM yyyy', 'fr_FR').format(_focusedDay).toUpperCase(),
                        style: TextStyle(color: TP.text(d), fontSize: 15,
                            fontWeight: FontWeight.w900, letterSpacing: -0.3)),
                    Text('${_tasks.length} événements',
                        style: TextStyle(color: TP.textMuted(d), fontSize: 11)),
                  ]),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _calFmt = _calFmt == CalendarFormat.month
                        ? CalendarFormat.week : CalendarFormat.month),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                          color: TP.bronze.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(children: [
                        Icon(_calFmt == CalendarFormat.month
                            ? Icons.view_week_rounded : Icons.calendar_month_rounded,
                            size: 13, color: TP.bronze),
                        const SizedBox(width: 5),
                        Text(_calFmt == CalendarFormat.month ? 'Semaine' : 'Mois',
                            style: const TextStyle(color: TP.bronze,
                                fontSize: 11, fontWeight: FontWeight.w800)),
                      ]),
                    ),
                  ),
                ]),
              ),

              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calFmt,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (sel, foc) => setState(() { _selectedDay = sel; _focusedDay = foc; }),
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
                          color: TP.bronze.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: TP.bronze.withOpacity(0.45))),
                      child: Center(child: Text('${day.day}', style: TextStyle(
                          color: TP.text(d), fontWeight: FontWeight.w900, fontSize: 13))),
                    );
                  },
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration:    const BoxDecoration(),
                  selectedDecoration: const BoxDecoration(),
                  defaultTextStyle:   TextStyle(color: TP.text(d), fontSize: 13),
                  weekendTextStyle:   TextStyle(color: TP.textMuted(d), fontSize: 13),
                  outsideTextStyle:   TextStyle(color: TP.textSoft(d).withOpacity(0.35)),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: false,
                  titleTextStyle: const TextStyle(fontSize: 0),
                  leftChevronIcon:  Icon(Icons.chevron_left_rounded,  color: TP.text(d), size: 24),
                  rightChevronIcon: Icon(Icons.chevron_right_rounded, color: TP.text(d), size: 24),
                  headerPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: TP.textMuted(d), fontWeight: FontWeight.w700, fontSize: 11),
                  weekendStyle: TextStyle(color: TP.bronze.withOpacity(0.7), fontWeight: FontWeight.w700, fontSize: 11),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: TP.card(d),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TP.border(d))),
            child: Wrap(spacing: 18, runSpacing: 8, children: [
              _legendChip('Interview',   TP.info),
              _legendChip('Onboarding',  TP.success),
              _legendChip('Offboarding', TP.danger),
            ]),
          ),
          const SizedBox(height: 20),

          Row(children: [
            Text(
                _selectedDay != null
                    ? 'Plannings du ${DateFormat('d MMMM', 'fr_FR').format(_selectedDay!)}'
                    : 'Sélectionnez une date',
                style: TextStyle(color: TP.text(d), fontSize: 15, fontWeight: FontWeight.w900)),
            const Spacer(),
            if (dayTasks.isNotEmpty)
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: TP.bronze.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('${dayTasks.length}',
                      style: const TextStyle(color: TP.bronze,
                          fontSize: 12, fontWeight: FontWeight.w900))),
          ]),
          const SizedBox(height: 12),

          if (dayTasks.isEmpty)
            _emptyState(Icons.event_available_rounded,
                'Aucun planning', 'Rien de planifié ce jour-là.', d)
          else
            ...dayTasks.map((t) => _buildTaskCard(t, d)),
        ],
      ),
    );
  }

  Widget _legendChip(String label, Color color) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 10, height: 10,
        decoration: BoxDecoration(
            color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(3),
            border: Border.all(color: color, width: 1.5))),
    const SizedBox(width: 5),
    Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
  ]);

  Widget _emptyState(IconData icon, String title, String sub, bool d) => Padding(
    padding: const EdgeInsets.all(8),
    child: Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
          color: TP.card(d),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: TP.border(d))),
      child: Column(children: [
        Container(width: 60, height: 60,
            decoration: BoxDecoration(
                color: TP.bronze.withOpacity(0.12), borderRadius: BorderRadius.circular(18)),
            child: Icon(icon, color: TP.bronze, size: 28)),
        const SizedBox(height: 14),
        Text(title, style: TextStyle(
            color: TP.text(d), fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 6),
        Text(sub, textAlign: TextAlign.center,
            style: TextStyle(color: TP.textMuted(d), fontSize: 13)),
      ]),
    ),
  );
}
