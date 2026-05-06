import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:e_team/data/services/timo_service.dart';

// ═══════════════════════════════════════════════════════════════
// 🎨 WHITE SAAS PREMIUM DESIGN SYSTEM
// ═══════════════════════════════════════════════════════════════
class TimoDesignSystem {
  // White SaaS Theme Colors
  static const Color bg = Color(0xFFFFFFFF); // Fond blanc pur
  static const Color card = Color(0xFFFFFFFF); // Cartes blanches
  static const Color border = Color(
    0xFFF1F5F9,
  ); // Bordures ultra-fines gris-bleu
  static const Color textPrimary = Color(0xFF0F172A); // Texte principal
  static const Color textSecondary = Color(0xFF64748B); // Texte secondaire
  static const Color textMuted = Color(0xFF94A3B8); // Texte atténué

  // Task Type Colors
  static const Color interview = Color(0xFF06B6D4); // Cyan pour interviews
  static const Color onboarding = Color(0xFF10B981); // Emerald pour onboarding
  static const Color offboarding = Color(
    0xFFF87171,
  ); // Rouge Corail pour offboarding
  static const Color other = Color(0xFFFF9800); // Orange pour autres

  // Status Colors
  static const Color success = Color(0xFF10B981); // Vert succès
  static const Color warning = Color(0xFFF59E0B); // Orange warning
  static const Color neonGreen = Color(0xFFCCFF00); // Point de vie pulsant

  // Shadows & Effects
  static const Color shadowLight = Color(0x08000000); // Ombre ultra-légère
}

// ─────────────────────────────────────────────────────────────
//  TASK CLASSIFICATION - LOGIQUE CORRIGÉE PAR MOTS-CLÉS
// ─────────────────────────────────────────────────────────────
enum TaskType { interview, onboarding, offboarding, other }

class TimoTask {
  final String raw;
  final String employeeName;
  final TaskType type;
  final String status;
  final DateTime? deadline;
  final String id;

  TimoTask({
    required this.raw,
    required this.employeeName,
    required this.type,
    required this.status,
    required this.deadline,
    required this.id,
  });

  factory TimoTask.fromMap(Map<String, dynamic> m) {
    final title = m['title'] as String? ?? '';
    final status = m['status'] as String? ?? 'todo';
    final id = m['_id']?.toString() ?? '';

    DateTime? deadline;
    try {
      deadline = DateTime.parse(m['deadline']);
    } catch (_) {}

    // ✅ NOUVELLE LOGIQUE DE CLASSIFICATION PAR MOTS-CLÉS
    TaskType type = TaskType.other;
    String employeeName = title;

    final lowerTitle = title.toLowerCase();

    // Classification par mots-clés
    if (lowerTitle.contains('démission') ||
        lowerTitle.contains('départ') ||
        lowerTitle.contains('offboarding')) {
      type = TaskType.offboarding;
    } else if (lowerTitle.contains('intégration') ||
        lowerTitle.contains('onboarding')) {
      type = TaskType.onboarding;
    } else if (lowerTitle.contains('entretien') ||
        lowerTitle.contains('interview')) {
      type = TaskType.interview;
    }

    // Extraction du nom après les deux points
    if (title.contains(':')) {
      final parts = title.split(':');
      if (parts.length > 1) {
        employeeName = parts[1].trim();
      }
    }

    return TimoTask(
      raw: title,
      employeeName: employeeName,
      type: type,
      status: status,
      deadline: deadline,
      id: id,
    );
  }

  bool get isDone => status == 'done';

  // Configuration visuelle selon le type
  IconData get icon => switch (type) {
    TaskType.interview => Icons.record_voice_over_rounded,
    TaskType.onboarding => Icons.person_add_alt_1_rounded,
    TaskType.offboarding => Icons.exit_to_app_rounded,
    TaskType.other => Icons.event_rounded,
  };

  Color get color => switch (type) {
    TaskType.interview => TimoDesignSystem.interview,
    TaskType.onboarding => TimoDesignSystem.onboarding,
    TaskType.offboarding => TimoDesignSystem.offboarding,
    TaskType.other => TimoDesignSystem.other,
  };

  String get typeLabel => switch (type) {
    TaskType.interview => 'INTERVIEW',
    TaskType.onboarding => 'ONBOARDING',
    TaskType.offboarding => 'OFFBOARDING',
    TaskType.other => 'TÂCHE',
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
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
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
      child: Row(
        children: [
          // Bouton de retour
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: TimoDesignSystem.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TimoDesignSystem.border, width: 0.5),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              color: TimoDesignSystem.textPrimary,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),

          // Avatar Timo
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: TimoDesignSystem.other, width: 2),
              boxShadow: [
                BoxShadow(
                  color: TimoDesignSystem.shadowLight,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(
                'assets/images/krono.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: TimoDesignSystem.other.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.timer_rounded,
                      color: TimoDesignSystem.other,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Nom et statut
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TIMO COMMAND CENTER',
                  style: GoogleFonts.plusJakartaSans(
                    color: TimoDesignSystem.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // ✅ PULSATION ANIMATION
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: TimoDesignSystem.neonGreen.withValues(
                              alpha: 0.4 + 0.6 * _pulseController.value,
                            ),
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'SCHEDULING ENGINE ONLINE',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFFF9800),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
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

  // ════════════════════════════════════════════════════════════
  //  CLEAN NAVIGATION
  // ════════════════════════════════════════════════════════════
  Widget _buildCleanNavigation() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [TimoDesignSystem.other, const Color(0xFFF57C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TimoDesignSystem.other.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: _tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = _tab == index;

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _tab = index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 0.5,
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tab.$1,
                        color: Colors.white,
                        size: isSelected ? 20 : 18,
                      ),
                      const SizedBox(height: 4),
                      if (isSelected)
                        Text(
                          tab.$2,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        Container(
                          height: 2,
                          width: 20,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
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
    final total = _tasks.length;
    final done = _done.length;
    final pct = total == 0 ? 0.0 : done / total;

    return Container(
      padding: const EdgeInsets.all(20),
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
          // 3 métriques métier
          Row(
            children: [
              Expanded(
                child: _statItem(
                  '${_interviews.length}',
                  'INTERVIEWS',
                  TimoDesignSystem.interview,
                  Icons.record_voice_over_rounded,
                ),
              ),
              Container(width: 1, height: 50, color: TimoDesignSystem.border),
              Expanded(
                child: _statItem(
                  '${_onboardings.length}',
                  'ONBOARDINGS',
                  TimoDesignSystem.onboarding,
                  Icons.person_add_alt_1_rounded,
                ),
              ),
              Container(width: 1, height: 50, color: TimoDesignSystem.border),
              Expanded(
                child: _statItem(
                  '${_offboardings.length}',
                  'OFFBOARDINGS',
                  TimoDesignSystem.offboarding,
                  Icons.exit_to_app_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Barre de progression globale
          Row(
            children: [
              Text(
                'Complétés',
                style: GoogleFonts.plusJakartaSans(
                  color: TimoDesignSystem.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '$done / $total',
                style: GoogleFonts.plusJakartaSans(
                  color: pct > 0.7
                      ? TimoDesignSystem.success
                      : TimoDesignSystem.other,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 7,
              backgroundColor: TimoDesignSystem.border,
              valueColor: AlwaysStoppedAnimation(
                pct > 0.7 ? TimoDesignSystem.success : TimoDesignSystem.other,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String val, String label, Color color, IconData icon) =>
      Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            val,
            style: GoogleFonts.plusJakartaSans(
              color: TimoDesignSystem.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: TimoDesignSystem.textMuted,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      );

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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TimoDesignSystem.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isDone
              ? TimoDesignSystem.success.withValues(alpha: 0.25)
              : task.color.withValues(alpha: 0.2),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: TimoDesignSystem.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône type
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: task.isDone
                  ? TimoDesignSystem.success.withValues(alpha: 0.12)
                  : task.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              task.isDone ? Icons.task_alt_rounded : task.icon,
              color: task.isDone ? TimoDesignSystem.success : task.color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom de l'employé/candidat
                Text(
                  task.employeeName,
                  style: GoogleFonts.plusJakartaSans(
                    color: task.isDone
                        ? TimoDesignSystem.textMuted
                        : TimoDesignSystem.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                    decorationColor: TimoDesignSystem.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                // ✅ DATE + HEURE TRÈS LISIBLE (ex: '15 Avr • 09:00')
                if (task.deadline != null)
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: TimoDesignSystem.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat(
                          'dd MMM • HH:mm',
                          'fr_FR',
                        ).format(task.deadline!),
                        style: GoogleFonts.plusJakartaSans(
                          color: TimoDesignSystem.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Badge type
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: task.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  task.typeLabel,
                  style: GoogleFonts.plusJakartaSans(
                    color: task.color,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (task.isDone) ...[
                const SizedBox(height: 6),
                Icon(
                  Icons.verified_rounded,
                  color: TimoDesignSystem.success,
                  size: 16,
                ),
              ],
            ],
          ),
        ],
      ),
    );
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
  Widget _legendChip(String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: color, width: 1.5),
        ),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Widget _emptyState(IconData icon, String title, String sub) => Padding(
    padding: const EdgeInsets.all(8),
    child: Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: TimoDesignSystem.card,
        borderRadius: BorderRadius.circular(24),
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
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: TimoDesignSystem.other.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: TimoDesignSystem.other, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: TimoDesignSystem.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: TimoDesignSystem.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}
