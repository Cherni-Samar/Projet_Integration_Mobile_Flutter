import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../providers/theme_provider.dart';

class HrDashboardPage extends StatefulWidget {
  final String heraMessage;
  final String username;

  const HrDashboardPage({
    Key? key,
    required this.heraMessage,
    required this.username,
  }) : super(key: key);

  @override
  State<HrDashboardPage> createState() => _HrDashboardPageState();
}

class _HrDashboardPageState extends State<HrDashboardPage>
    with TickerProviderStateMixin {
  // ✅ FIX — initialisation directe, pas "late" séparé
  AnimationController? _pulseController;
  AnimationController? _fadeController;
  Animation<double>? _fadeAnimation;

  int _selectedTab = 0;

  final List<Map<String, dynamic>> _tasks = [
    {
      'icon': '🏖️',
      'title': 'Congé — Ali B.',
      'sub': 'En attente',
      'status': 'pending',
      'time': 'Il y a 2h',
    },
    {
      'icon': '👤',
      'title': 'Onboarding — Sana M.',
      'sub': 'Étape 3/5',
      'status': 'in_progress',
      'time': "Auj.",
    },
    {
      'icon': '📄',
      'title': 'Contrat — Karim T.',
      'sub': 'Généré',
      'status': 'done',
      'time': 'Hier',
    },
    {
      'icon': '⚠️',
      'title': 'Absence — Youssef K.',
      'sub': 'Action requise',
      'status': 'pending',
      'time': 'Il y a 1j',
    },
    {
      'icon': '📊',
      'title': 'Rapport RH',
      'sub': 'Prêt',
      'status': 'done',
      'time': '14 fév',
    },
  ];

  final List<Map<String, dynamic>> _activity = [
    {'label': 'L', 'value': 0.4},
    {'label': 'M', 'value': 0.75},
    {'label': 'M', 'value': 0.55},
    {'label': 'J', 'value': 0.9},
    {'label': 'V', 'value': 0.65},
    {'label': 'S', 'value': 0.2},
    {'label': 'D', 'value': 0.1},
  ];

  @override
  void initState() {
    super.initState();

    // ✅ 1. Pulse controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // ✅ 2. Fade controller
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // ✅ 3. Fade animation — APRÈS le controller
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController!, curve: Curves.easeOut));

    // ✅ 4. Forward — EN DERNIER
    _fadeController!.forward();
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    _fadeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final bg = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA);
    final surface = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subColor = isDark
        ? Colors.white.withOpacity(0.45)
        : Colors.black.withOpacity(0.45);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.08);

    // ✅ Guard — si animation pas encore prête, affiche sans fade
    if (_fadeAnimation == null) {
      return _buildBody(isDark, bg, surface, textColor, subColor, borderColor);
    }

    return AnimatedBuilder(
      animation: _fadeAnimation!,
      builder: (context, child) =>
          Opacity(opacity: _fadeAnimation!.value, child: child),
      child: _buildBody(isDark, bg, surface, textColor, subColor, borderColor),
    );
  }

  Widget _buildBody(
    bool isDark,
    Color bg,
    Color surface,
    Color textColor,
    Color subColor,
    Color borderColor,
  ) {
    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          _buildHeader(isDark, surface, textColor, subColor, borderColor),
          _buildTabBar(isDark, surface, textColor, subColor, borderColor),
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _buildOverview(
                  isDark,
                  bg,
                  surface,
                  textColor,
                  subColor,
                  borderColor,
                ),
                _buildTasks(
                  isDark,
                  bg,
                  surface,
                  textColor,
                  subColor,
                  borderColor,
                ),
                _buildUsage(
                  isDark,
                  bg,
                  surface,
                  textColor,
                  subColor,
                  borderColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader(
    bool isDark,
    Color surface,
    Color textColor,
    Color subColor,
    Color borderColor,
  ) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: surface,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.black.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_back, color: textColor, size: 18),
            ),
          ),
          const SizedBox(width: 12),

          // ✅ pulse safe avec null check
          AnimatedBuilder(
            animation: _pulseController ?? kAlwaysCompleteAnimation,
            builder: (_, __) {
              final pulse = _pulseController?.value ?? 0.0;
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF8B5CF6,
                      ).withOpacity(0.25 + pulse * 0.25),
                      blurRadius: 12 + pulse * 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('👥', style: TextStyle(fontSize: 18)),
                ),
              );
            },
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hera',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFCDFF00),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'HR Agent • Actif',
                      style: TextStyle(color: subColor, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.07)
                  : Colors.black.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.notifications_none, color: textColor, size: 18),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFCDFF00),
                      shape: BoxShape.circle,
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

  // ── TAB BAR ───────────────────────────────────────────────────────────────
  Widget _buildTabBar(
    bool isDark,
    Color surface,
    Color textColor,
    Color subColor,
    Color borderColor,
  ) {
    final tabs = ["Vue d'ensemble", 'Tâches', 'Usage'];
    return Container(
      color: surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = _selectedTab == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF8B5CF6)
                    : (isDark
                          ? Colors.white.withOpacity(0.07)
                          : Colors.black.withOpacity(0.06)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tabs[i],
                style: TextStyle(
                  color: active ? Colors.white : subColor,
                  fontSize: 12,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── OVERVIEW ──────────────────────────────────────────────────────────────
  Widget _buildOverview(
    bool isDark,
    Color bg,
    Color surface,
    Color textColor,
    Color subColor,
    Color borderColor,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heraMessage(isDark, textColor, subColor),
          const SizedBox(height: 20),

          _label('RÉSUMÉ', subColor),
          const SizedBox(height: 10),
          SizedBox(
            height: 130,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _kpiCard(
                  '✅',
                  '24',
                  'Tâches',
                  '+6 sem.',
                  const Color(0xFFCDFF00),
                  isDark,
                  surface,
                ),
                _kpiCard(
                  '⏳',
                  '3',
                  'En cours',
                  '2 urgentes',
                  const Color(0xFFFBBF24),
                  isDark,
                  surface,
                ),
                _kpiCard(
                  '👥',
                  '47',
                  'Employés',
                  '2 nouveaux',
                  const Color(0xFF8B5CF6),
                  isDark,
                  surface,
                ),
                _kpiCard(
                  '📈',
                  '96%',
                  'Résolution',
                  '↑ +4%',
                  const Color(0xFF34D399),
                  isDark,
                  surface,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _label('ACTIVITÉ — 7 JOURS', subColor),
          const SizedBox(height: 10),
          _activityChart(isDark, surface, textColor, subColor, borderColor),

          const SizedBox(height: 20),
          _label('TÂCHES RÉCENTES', subColor),
          const SizedBox(height: 10),
          ..._tasks
              .take(3)
              .map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _taskRow(
                    t,
                    isDark,
                    surface,
                    textColor,
                    subColor,
                    borderColor,
                  ),
                ),
              ),

          const SizedBox(height: 20),
          _label('UTILISATION CE MOIS', subColor),
          const SizedBox(height: 10),
          _usageRow(isDark, surface, textColor, subColor, borderColor),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _heraMessage(bool isDark, Color textColor, Color subColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6).withOpacity(isDark ? 0.15 : 0.08),
            const Color(0xFF6366F1).withOpacity(isDark ? 0.06 : 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(isDark ? 0.4 : 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 15)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hera · Maintenant',
                  style: TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.heraMessage,
                  style: TextStyle(color: textColor, fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiCard(
    String icon,
    String value,
    String label,
    String sub,
    Color color,
    bool isDark,
    Color surface,
  ) {
    return Container(
      width: 110,
      height: 100,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                sub,
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _activityChart(
    bool isDark,
    Color surface,
    Color textColor,
    Color subColor,
    Color borderColor,
  ) {
    return Container(
      height: 90,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _activity.map((day) {
          final isToday = day['label'] == 'J';
          final val = day['value'] as double;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: FractionallySizedBox(
                    heightFactor: val,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isToday
                              ? [
                                  const Color(0xFF8B5CF6),
                                  const Color(0xFFCDFF00),
                                ]
                              : [
                                  const Color(
                                    0xFF8B5CF6,
                                  ).withOpacity(isDark ? 0.5 : 0.3),
                                  const Color(
                                    0xFF8B5CF6,
                                  ).withOpacity(isDark ? 0.15 : 0.08),
                                ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  day['label'] as String,
                  style: TextStyle(
                    color: isToday ? textColor : subColor,
                    fontSize: 9,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _usageRow(
    bool isDark,
    Color surface,
    Color textColor,
    Color subColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: CustomPaint(
              painter: _RingPainter(
                progress: 0.72,
                color: const Color(0xFF8B5CF6),
                bgColor: isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.black.withOpacity(0.07),
              ),
              child: Center(
                child: Text(
                  '72%',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
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
                  '36 / 50 requêtes',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '14 restantes ce mois',
                  style: TextStyle(color: subColor, fontSize: 11),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    ),
                  ),
                  child: const Text(
                    '⚡ Passer à Monthly',
                    style: TextStyle(
                      color: Color(0xFF8B5CF6),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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

  // ── TASKS TAB ─────────────────────────────────────────────────────────────
  Widget _buildTasks(
    bool isDark,
    Color bg,
    Color surface,
    Color textColor,
    Color subColor,
    Color borderColor,
  ) {
    final pending = _tasks.where((t) => t['status'] == 'pending').toList();
    final inProg = _tasks.where((t) => t['status'] == 'in_progress').toList();
    final done = _tasks.where((t) => t['status'] == 'done').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip('${pending.length} En attente', const Color(0xFFFB7185)),
              _chip('${inProg.length} En cours', const Color(0xFFFBBF24)),
              _chip(
                '${done.length} Terminées',
                const Color.fromARGB(255, 7, 186, 51),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (pending.isNotEmpty) ...[
            _label('⚠️  EN ATTENTE', subColor),
            const SizedBox(height: 8),
            ...pending.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _taskRow(
                  t,
                  isDark,
                  surface,
                  textColor,
                  subColor,
                  borderColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (inProg.isNotEmpty) ...[
            _label('⏳  EN COURS', subColor),
            const SizedBox(height: 8),
            ...inProg.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _taskRow(
                  t,
                  isDark,
                  surface,
                  textColor,
                  subColor,
                  borderColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (done.isNotEmpty) ...[
            _label('✅  TERMINÉES', subColor),
            const SizedBox(height: 8),
            ...done.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _taskRow(
                  t,
                  isDark,
                  surface,
                  textColor,
                  subColor,
                  borderColor,
                ),
              ),
            ),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _taskRow(
    Map<String, dynamic> task,
    bool isDark,
    Color surface,
    Color textColor,
    Color subColor,
    Color borderColor,
  ) {
    final status = task['status'] as String;
    Color sc;
    String sl;
    switch (status) {
      case 'pending':
        sc = const Color(0xFFFB7185);
        sl = 'En attente';
        break;
      case 'in_progress':
        sc = const Color(0xFFFBBF24);
        sl = 'En cours';
        break;
      default:
        sc = const Color.fromARGB(255, 7, 186, 51);
        sl = 'Terminé';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Text(task['icon'] as String, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  task['sub'] as String,
                  style: TextStyle(color: subColor, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: sc.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  sl,
                  style: TextStyle(
                    color: sc,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                task['time'] as String,
                style: TextStyle(color: subColor, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── USAGE TAB ─────────────────────────────────────────────────────────────
  Widget _buildUsage(
    bool isDark,
    Color bg,
    Color surface,
    Color textColor,
    Color subColor,
    Color borderColor,
  ) {
    final metrics = [
      {
        'label': 'Requêtes',
        'val': 36,
        'max': 50,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'label': 'Tâches auto',
        'val': 24,
        'max': 30,
        'color': const Color(0xFFCDFF00),
      },
      {
        'label': 'Temps (h)',
        'val': 18,
        'max': 40,
        'color': const Color(0xFF34D399),
      },
      {
        'label': 'Erreurs',
        'val': 3,
        'max': 10,
        'color': const Color(0xFFFB7185),
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B5CF6).withOpacity(isDark ? 0.15 : 0.08),
                  const Color(0xFF6366F1).withOpacity(isDark ? 0.04 : 0.01),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withOpacity(isDark ? 0.3 : 0.15),
              ),
            ),
            child: Row(
              children: [
                const Text('🆓', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plan Gratuit',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '50 requêtes/mois • Renouvelle le 1 mars',
                        style: TextStyle(color: subColor, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Upgrade',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _label('MÉTRIQUES', subColor),
          const SizedBox(height: 12),

          ...metrics.map((m) {
            final color = m['color'] as Color;
            final val = m['val'] as int;
            final max = m['max'] as int;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        m['label'] as String,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$val / $max',
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: val / max,
                      minHeight: 7,
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.07)
                          : Colors.black.withOpacity(0.07),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),
          _label('HISTORIQUE', subColor),
          const SizedBox(height: 10),

          ...[
            {'month': 'Février 2025', 'tasks': 24, 'req': 36},
            {'month': 'Janvier 2025', 'tasks': 19, 'req': 41},
            {'month': 'Décembre 2024', 'tasks': 31, 'req': 48},
          ].map(
            (h) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        h['month'] as String,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _chip2('${h['tasks']} tâches', const Color(0xFFCDFF00)),
                    const SizedBox(width: 6),
                    _chip2('${h['req']} req', const Color(0xFF8B5CF6)),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _label(String t, Color subColor) => Text(
    t,
    style: TextStyle(
      color: subColor,
      fontSize: 11,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    ),
  );

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
    ),
  );

  Widget _chip2(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
    ),
  );
}

// ── Ring Painter ──────────────────────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 7;
    const sw = 7.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = bgColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
