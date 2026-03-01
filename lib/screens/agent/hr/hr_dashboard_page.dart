import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../providers/theme_provider.dart';
import '../../../services/hr_agent_service.dart';

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

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController!, curve: Curves.easeOut));

    _fadeController!.forward();
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    _fadeController?.dispose();
    super.dispose();
  }

  // ── Theme helpers ─────────────────────────────────────────────────────────
  Color _bg(bool d) => d ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA);
  Color _surface(bool d) => d ? const Color(0xFF1A1A1A) : Colors.white;
  Color _text(bool d) => d ? Colors.white : Colors.black;
  Color _sub(bool d) =>
      d ? Colors.white.withOpacity(0.45) : Colors.black.withOpacity(0.45);
  Color _border(bool d) =>
      d ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08);

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    if (_fadeAnimation == null) {
      return _buildBody(isDark);
    }

    return AnimatedBuilder(
      animation: _fadeAnimation!,
      builder: (context, child) =>
          Opacity(opacity: _fadeAnimation!.value, child: child),
      child: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    return Scaffold(
      backgroundColor: _bg(isDark),
      body: Column(
        children: [
          _buildHeader(isDark),
          _buildTabBar(isDark),
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _buildOverview(isDark),
                _buildTasks(isDark),
                _buildLeaves(
                  isDark,
                  _bg(isDark),
                  _surface(isDark),
                  _text(isDark),
                  _sub(isDark),
                  _border(isDark),
                ),
                _buildUsage(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: _surface(isDark),
        border: Border(bottom: BorderSide(color: _border(isDark))),
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
              child: Icon(Icons.arrow_back, color: _text(isDark), size: 18),
            ),
          ),
          const SizedBox(width: 12),

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
                    color: _text(isDark),
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
                      style: TextStyle(color: _sub(isDark), fontSize: 11),
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
                Icon(Icons.notifications_none, color: _text(isDark), size: 18),
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
  Widget _buildTabBar(bool isDark) {
    final tabs = ["Vue d'ensemble", 'Tâches', 'Usage', 'congés'];
    return Container(
      color: _surface(isDark),
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
                  color: active ? Colors.white : _sub(isDark),
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

  // ── CONGÉS TAB ──────────────────────────────────────────────────────────────
  Widget _buildLeaves(
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
          // ── Banner ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🌴 Nouvelle demande',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Soumettez votre congé en quelques secondes',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showLeaveForm(isDark),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF8B5CF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Demander',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _label('HISTORIQUE', subColor),
          const SizedBox(height: 12),

          // ── Historique statique (à rendre dynamique plus tard) ──
          ...[
            {
              'type': '🌴 Congé Annuel',
              'dates': '10→19 Mar 2025',
              'days': '10j',
              'status': 'approved',
            },
            {
              'type': '🤒 Congé Maladie',
              'dates': '05→07 Jan 2025',
              'days': '3j',
              'status': 'approved',
            },
            {
              'type': '⚡ Congé Urgent',
              'dates': '20 Fév 2025',
              'days': '1j',
              'status': 'pending',
            },
          ].map((leave) {
            final isApproved = leave['status'] == 'approved';
            final statusColor = isApproved
                ? const Color(0xFF34D399)
                : const Color(0xFFFBBF24);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          leave['type']!,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          leave['dates']!,
                          style: TextStyle(color: subColor, fontSize: 12),
                        ),
                        Text(
                          leave['days']!,
                          style: TextStyle(
                            color: const Color(0xFF8B5CF6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      isApproved ? '✅ Approuvé' : '⏳ En attente',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
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

  // ── Formulaire Congé ─────────────────────────────────────────────────────────
  void _showLeaveForm(bool isDark) {
    String _type = 'annual';
    DateTime? _startDate;
    DateTime? _endDate;
    final _reasonController = TextEditingController();
    bool _loading = false;
    String? _message;
    bool _success = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 30,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '🌴 Demande de Congé',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Type
              DropdownButtonFormField<String>(
                value: _type,
                dropdownColor: isDark ? const Color(0xFF252525) : Colors.white,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Type de congé',
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF252525)
                      : const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'annual',
                    child: Text('🌴 Congé Annuel'),
                  ),
                  DropdownMenuItem(
                    value: 'sick',
                    child: Text('🤒 Congé Maladie'),
                  ),
                  DropdownMenuItem(
                    value: 'urgent',
                    child: Text('⚡ Congé Urgent'),
                  ),
                ],
                onChanged: (v) => setModalState(() => _type = v!),
              ),
              const SizedBox(height: 12),

              // Dates
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (d != null) setModalState(() => _startDate = d);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF252525)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Color(0xFF8B5CF6),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _startDate != null
                                  ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                  : 'Début',
                              style: TextStyle(
                                color: _startDate != null
                                    ? (isDark ? Colors.white : Colors.black)
                                    : Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (d != null) setModalState(() => _endDate = d);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF252525)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Color(0xFF8B5CF6),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _endDate != null
                                  ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                  : 'Fin',
                              style: TextStyle(
                                color: _endDate != null
                                    ? (isDark ? Colors.white : Colors.black)
                                    : Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Motif
              TextField(
                controller: _reasonController,
                maxLines: 2,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Motif...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF252525)
                      : const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Message
              if (_message != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: _success
                        ? const Color(0xFF34D399).withOpacity(0.1)
                        : const Color(0xFFFB7185).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _success
                          ? const Color(0xFF34D399)
                          : const Color(0xFFFB7185),
                    ),
                  ),
                  child: Text(
                    _message!,
                    style: TextStyle(
                      color: _success
                          ? const Color(0xFF34D399)
                          : const Color(0xFFFB7185),
                      fontSize: 13,
                    ),
                  ),
                ),

              // Bouton
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          if (_startDate == null || _endDate == null) {
                            setModalState(
                              () => _message = '⚠️ Sélectionne les dates !',
                            );
                            return;
                          }
                          setModalState(() => _loading = true);
                          try {
                            final days =
                                _endDate!.difference(_startDate!).inDays + 1;
                            final result = await HrAgentService.requestLeave(
                              employeeId: '69a36380631008d197d4ac02',
                              employeeEmail: 'eya.mosbahi@esprit.tn',
                              type: _type,
                              startDate: _startDate!.toIso8601String().split(
                                'T',
                              )[0],
                              endDate: _endDate!.toIso8601String().split(
                                'T',
                              )[0],
                              days: days,
                              reason: _reasonController.text.isEmpty
                                  ? 'Congé'
                                  : _reasonController.text,
                            );
                            setModalState(() {
                              _success = result['success'] == true;
                              _message = result['message'] ?? result['error'];
                              _loading = false;
                            });
                            if (_success) {
                              Future.delayed(const Duration(seconds: 2), () {
                                Navigator.pop(ctx);
                              });
                            }
                          } catch (e) {
                            setModalState(() {
                              _message = '❌ Erreur: $e';
                              _loading = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          '✅ Soumettre',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── OVERVIEW ──────────────────────────────────────────────────────────────
  Widget _buildOverview(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heraMessage(isDark),
          const SizedBox(height: 20),

          _label('RÉSUMÉ', _sub(isDark)),
          const SizedBox(height: 10),
          SizedBox(
            height: 115,
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
                ),
                _kpiCard(
                  '⏳',
                  '3',
                  'En cours',
                  '2 urgentes',
                  const Color(0xFFFBBF24),
                  isDark,
                ),
                _kpiCard(
                  '👥',
                  '47',
                  'Employés',
                  '2 nouveaux',
                  const Color(0xFF8B5CF6),
                  isDark,
                ),
                _kpiCard(
                  '📈',
                  '96%',
                  'Résolution',
                  '↑ +4%',
                  const Color(0xFF34D399),
                  isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _label('ACTIVITÉ — 7 JOURS', _sub(isDark)),
          const SizedBox(height: 10),
          _activityChart(isDark),

          const SizedBox(height: 20),
          _label('TÂCHES RÉCENTES', _sub(isDark)),
          const SizedBox(height: 10),
          ..._tasks
              .take(3)
              .map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _taskRow(t, isDark),
                ),
              ),

          const SizedBox(height: 20),
          _label('UTILISATION CE MOIS', _sub(isDark)),
          const SizedBox(height: 10),
          _usageRow(isDark),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _heraMessage(bool isDark) {
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
                  style: TextStyle(
                    color: _text(isDark),
                    fontSize: 13,
                    height: 1.5,
                  ),
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
  ) {
    return Container(
      width: 115,
      height: 115,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _surface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
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
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text(isDark),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              Text(
                sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: _sub(isDark), fontSize: 9, height: 1.2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _activityChart(bool isDark) {
    return Container(
      height: 90,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: _surface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border(isDark)),
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
                    color: isToday ? _text(isDark) : _sub(isDark),
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

  Widget _usageRow(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border(isDark)),
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
                    color: _text(isDark),
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
                    color: _text(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '14 restantes ce mois',
                  style: TextStyle(color: _sub(isDark), fontSize: 11),
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
  Widget _buildTasks(bool isDark) {
    final pending = _tasks.where((t) => t['status'] == 'pending').toList();
    final inProg = _tasks.where((t) => t['status'] == 'in_progress').toList();
    final done = _tasks.where((t) => t['status'] == 'done').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Boutons de test réels
          _label('TESTER HERA', _sub(isDark)),
          const SizedBox(height: 12),

          _testButton(
            icon: '🏖️',
            label: 'Demander un congé (5 jours)',
            color: const Color(0xFF8B5CF6),
            isDark: isDark,
            onTap: () => _testLeaveRequest(isDark),
          ),
          const SizedBox(height: 10),
          _testButton(
            icon: '⚡',
            label: 'Congé urgent',
            color: const Color(0xFFFBBF24),
            isDark: isDark,
            onTap: () => _testUrgentLeave(isDark),
          ),
          const SizedBox(height: 10),
          _testButton(
            icon: '👤',
            label: 'Onboarding nouvel employé',
            color: const Color(0xFF34D399),
            isDark: isDark,
            onTap: () => _testOnboarding(isDark),
          ),
          const SizedBox(height: 10),
          _testButton(
            icon: '🚪',
            label: 'Offboarding employé',
            color: const Color(0xFFFB7185),
            isDark: isDark,
            onTap: () => _testOffboarding(isDark),
          ),

          const SizedBox(height: 24),
          _label('TÂCHES EN COURS', _sub(isDark)),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip('${pending.length} En attente', const Color(0xFFFB7185)),
              _chip('${inProg.length} En cours', const Color(0xFFFBBF24)),
              _chip('${done.length} Terminées', const Color(0xFF34D399)),
            ],
          ),
          const SizedBox(height: 16),

          if (pending.isNotEmpty) ...[
            _label('⚠️  EN ATTENTE', _sub(isDark)),
            const SizedBox(height: 8),
            ...pending.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _taskRow(t, isDark),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (inProg.isNotEmpty) ...[
            _label('⏳  EN COURS', _sub(isDark)),
            const SizedBox(height: 8),
            ...inProg.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _taskRow(t, isDark),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (done.isNotEmpty) ...[
            _label('✅  TERMINÉES', _sub(isDark)),
            const SizedBox(height: 8),
            ...done.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _taskRow(t, isDark),
              ),
            ),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _testButton({
    required String icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.1 : 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: _text(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _taskRow(Map<String, dynamic> task, bool isDark) {
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
        sc = const Color(0xFF34D399);
        sl = 'Terminé';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _surface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border(isDark)),
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
                    color: _text(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  task['sub'] as String,
                  style: TextStyle(color: _sub(isDark), fontSize: 11),
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
                style: TextStyle(color: _sub(isDark), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── USAGE TAB ─────────────────────────────────────────────────────────────
  Widget _buildUsage(bool isDark) {
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
          // Plan card
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
                          color: _text(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '50 requêtes/mois • Renouvelle le 1 mars',
                        style: TextStyle(color: _sub(isDark), fontSize: 11),
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
          _label('MÉTRIQUES', _sub(isDark)),
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
                          color: _text(isDark),
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
          _label('HISTORIQUE', _sub(isDark)),
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
                  color: _surface(isDark),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border(isDark)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        h['month'] as String,
                        style: TextStyle(
                          color: _text(isDark),
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

  // ── TEST METHODS ──────────────────────────────────────────────────────────
  Future<void> _testLeaveRequest(bool isDark) async {
    _showLoading(isDark, 'Envoi demande de congé...');
    try {
      final result = await HrAgentService.requestLeave(
        employeeId: '69a36380631008d197d4ac02',
        employeeEmail: 'eya.mosbahi@esprit.tn',
        type: 'annual',
        startDate: '2025-03-10',
        endDate: '2025-03-14',
        days: 5,
        reason: 'Vacances famille',
      );
      if (!mounted) return;
      Navigator.pop(context);
      _showResult(isDark, result);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showError(e.toString());
    }
  }

  Future<void> _testUrgentLeave(bool isDark) async {
    _showLoading(isDark, 'Envoi congé urgent...');
    try {
      final result = await HrAgentService.urgentLeave(
        employeeId: 'samar@eteam.com',
        reason: 'Urgence médicale famille',
      );
      if (!mounted) return;
      Navigator.pop(context);
      _showResult(isDark, result);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showError(e.toString());
    }
  }

  Future<void> _testOnboarding(bool isDark) async {
    _showLoading(isDark, 'Démarrage onboarding...');
    try {
      final result = await HrAgentService.onboarding(
        name: 'Sana Meziane',
        email: 'sana@eteam.com',
        role: 'Designer',
        department: 'Creative',
        contractType: 'CDI',
        managerEmail: 'manager@eteam.com',
      );
      if (!mounted) return;
      Navigator.pop(context);
      _showResult(isDark, result);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showError(e.toString());
    }
  }

  Future<void> _testOffboarding(bool isDark) async {
    _showLoading(isDark, 'Démarrage offboarding...');
    try {
      final result = await HrAgentService.offboarding(
        employeeId: 'samar@eteam.com',
        reason: 'resignation',
        lastDay: '2025-03-31',
      );
      if (!mounted) return;
      Navigator.pop(context);
      _showResult(isDark, result);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showError(e.toString());
    }
  }

  // ── UI HELPERS ────────────────────────────────────────────────────────────
  void _showLoading(bool isDark, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF8B5CF6)),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  color: _text(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResult(bool isDark, Map<String, dynamic> result) {
    final success = result['success'] == true;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Text(success ? '✅' : '❌', style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              success ? 'Succès' : 'Refusé',
              style: TextStyle(
                color: _text(isDark),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    (success
                            ? const Color(0xFF34D399)
                            : const Color(0xFFFB7185))
                        .withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                result['message'] ?? 'Aucun message',
                style: TextStyle(
                  color: _text(isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (result['balance_left'] != null)
              _resultRow(
                '💰 Solde restant',
                '${result['balance_left']} jours',
                isDark,
              ),
            if (result['leave_id'] != null)
              _resultRow('🆔 ID congé', result['leave_id'].toString(), isDark),
            if (result['employee_id'] != null)
              _resultRow(
                '👤 Employé ID',
                result['employee_id'].toString(),
                isDark,
              ),
            if (result['status'] != null)
              _resultRow('📊 Statut', result['status'].toString(), isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFF8B5CF6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: _sub(isDark), fontSize: 11)),
          Text(
            value,
            style: TextStyle(
              color: _text(isDark),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error.contains('indisponible')
                    ? '❌ Express :3000 indisponible\nLance: npm run dev'
                    : '❌ $error',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
