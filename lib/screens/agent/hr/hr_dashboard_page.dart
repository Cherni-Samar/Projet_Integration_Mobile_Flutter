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

class _HrDashboardPageState extends State<HrDashboardPage>

    with TickerProviderStateMixin {
  int _selectedTab = 0;
  final Map<String, int> deptMaxCapacities = {
    "Tech": 20,
    "Design": 10,
    "Marketing": 15,
    "RH": 5,
    "Finance": 8,
    "Support": 12,
  };
  int _employeeSubTab = 0;
  int _countEmployeesInDept(String deptName) {
    // On filtre la liste des employés chargée depuis le backend
    return _employees.where((e) =>
    e['department']?.toString().toLowerCase() == deptName.toLowerCase() &&
        e['status'] == 'active'
    ).length;
  }
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
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  static const _lime = Color(0xFFCCFF00);
  static const _purple = Color(0xFFA855F7);

  @override
  void initState() {
    super.initState();
    _loadAdminData();


    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _pulseController.dispose();
    _fadeController.dispose();
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
      // On demande les 20 dernières actions au lieu de 5
      final result = await HrAgentService.getRecentActions(limit: 20);
      if (result['success'] == true) {
        setState(() {
          _recentActions = List<Map<String, dynamic>>.from(result['recent_actions'] ?? []);
          _loadingActions = false;
        });
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
          _employees = List<Map<String, dynamic>>.from(
            result['employees'] ?? [],
          );
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
          final leaves = List<Map<String, dynamic>>.from(
            result['leaves'] ?? [],
          );
          for (final leave in leaves) {
            leave['employee_name'] = emp['name'];
            leave['employee_role'] = emp['role'];
            allLeaves.add(leave);
          }
        }
      }
      if (mounted) setState(() => _allLeaves = allLeaves);
    } catch (_) {}
  }
  Widget _buildDeptRadar(bool isDark) {
    // On simule les données basées sur tes DEPARTMENT_LIMITS du backend
    final depts = [
      {"name": "Tech", "count": 3, "max": 20},
      {"name": "Design", "count": 0, "max": 10},
      {"name": "Marketing", "count": 0, "max": 15},
      {"name": "RH", "count": 1, "max": 5},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Statut des Équipes",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Icon(Icons.radar, color: const Color(0xFFCCFF00).withOpacity(0.5), size: 20),
            ],
          ),
          const SizedBox(height: 20),
          ...depts.map((d) {
            double percent = (d['count'] as int) / (d['max'] as int);
            bool isLow = percent < 0.8; // Seuil d'alerte de Hera

            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(d['name'] as String, style: const TextStyle(fontSize: 13)),
                      Row(
                        children: [
                          Text("${d['count']}/${d['max']}",
                              style: TextStyle(fontSize: 12, color: isLow ? Colors.orange : Colors.grey)),
                          if (isLow) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.auto_awesome, color: Color(0xFFCCFF00), size: 14), // L'IA travaille ici
                          ]
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 6,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          isLow ? Colors.orange.withOpacity(0.7) : const Color(0xFFCCFF00)
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
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
    // On récupère le type brut de la base de données
    final type = action['action_type']?.toString() ?? "";

    switch (type) {
      case 'absence_alert':
        return {
          'icon': Icons.campaign_rounded,
          'color': Colors.orange,
          'label': 'Alerte Sourcing (Echo)', // ✅ Détection manque staff
          'badge': 'AUTONOME',
        };
      case 'leave_approved':
        return {
          'icon': Icons.check_circle_outline_rounded,
          'color': const Color(0xFF10B981),
          'label': 'Validation de Congé', // ✅ Au lieu de Action Hera
          'badge': 'APPROUVÉ',
        };
      case 'leave_refused':
        return {
          'icon': Icons.highlight_off_rounded,
          'color': const Color(0xFFEF4444),
          'label': 'Refus de Congé',
          'badge': 'REFUSÉ',
        };
      case 'onboarding_started':
        return {
          'icon': Icons.person_add_alt_1_rounded,
          'color': _lime,
          'label': 'Nouvel Onboarding',
          'badge': 'SYSTÈME',
        };
      case 'contract_renewal':
        return {
          'icon': Icons.description_rounded,
          'color': Colors.blue,
          'label': 'Génération de Contrat', // ✅ Très clair pour les docs
          'badge': 'DOCS',
        };
      case 'performance_alert':
        return {
          'icon': Icons.payments_rounded,
          'color': Colors.purple,
          'label': 'Émission Bulletin de Paie',
          'badge': 'PAIE',
        };
      default:
      // ✅ Si l'action est inconnue, on affiche le nom technique formaté proprement
        String cleanName = type.replaceAll('_', ' ');
        if (cleanName.isNotEmpty) {
          cleanName = cleanName[0].toUpperCase() + cleanName.substring(1);
        }
        return {
          'icon': Icons.auto_awesome_rounded,
          'color': _purple,
          'label': cleanName.isNotEmpty ? cleanName : 'Action Système',
          'badge': 'INFO',
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
          backgroundColor: const Color(0xFF1A1A1A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _openVoicePage() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const HeraVoicePage()),
  );

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label à connecter'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Color _bg(bool isDark) =>
      isDark ? const Color(0xFF080808) : const Color(0xFFF0F2F5);
  Color _card(bool isDark) => isDark ? const Color(0xFF141414) : Colors.white;
  Color _cardSoft(bool isDark) =>
      isDark ? const Color(0xFF1C1C1C) : const Color(0xFFF8F9FC);
  Color _border(bool isDark) =>
      isDark ? const Color(0xFF252525) : const Color(0xFFE8EAED);
  Color _text(bool isDark) => isDark ? Colors.white : const Color(0xFF0F172A);
  Color _textMuted(bool isDark) =>
      isDark ? const Color(0xFF888888) : const Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: _bg(isDark),
      body: FadeTransition(
        opacity: _fadeController,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isDark),
              const SizedBox(height: 4),
              _buildTabBar(isDark),
              const SizedBox(height: 8),
              Expanded(
                child: IndexedStack(
                  index: _selectedTab,
                  children: [
                    _buildOverview(isDark),
                    _buildCalendar(isDark),
                    _buildEmployees(isDark),
                    _buildInsights(isDark),
                    _buildAiMonitoring(isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────── HEADER ───────────────
  Widget _quickAction({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
    required bool isDark,
    Color? customColor, // ✅ Ajouté
    Color? customTextColor, // ✅ Ajouté
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          // Si customColor est défini (noir), on l'utilise, sinon logique habituelle
          color: customColor ?? (isPrimary ? _lime : _cardSoft(isDark)),
          borderRadius: BorderRadius.circular(16),
          border: (isPrimary || customColor != null) ? null : Border.all(color: _border(isDark)),
        ),
        child: Column(
          children: [
            Icon(
                icon,
                size: 20,
                color: customTextColor ?? (isPrimary ? Colors.black : _text(isDark))
            ),
            const SizedBox(height: 4),
            Text(
                label,
                style: TextStyle(
                    color: customTextColor ?? (isPrimary ? Colors.black : _text(isDark)),
                    fontSize: 11,
                    fontWeight: FontWeight.bold
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final energy = context.watch<UserProvider>().energyBalance;
    // On vérifie si l'onglet "Vision IA" (index 4) est actif
    bool isVisionSelected = _selectedTab == 4;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border(isDark)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: _cardSoft(isDark),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: _text(isDark)),
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset('assets/images/hera.png', width: 48, height: 48, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Agent Hera', style: TextStyle(color: _text(isDark), fontSize: 18, fontWeight: FontWeight.w900)),
                    Text('SURVEILLANCE IA ACTIVE', style: TextStyle(color: _lime, fontSize: 9, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: _lime.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text('⚡ $energy', style: const TextStyle(color: _lime, fontSize: 13, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              // 1. Bouton Parler
              Expanded(
                  child: _quickAction(
                      icon: Icons.graphic_eq_rounded,
                      label: 'Parler',
                      isPrimary: true,
                      onTap: _openVoicePage,
                      isDark: isDark
                  )
              ),
              const SizedBox(width: 8),

              // 2. Bouton Vision IA (Radar) - Devient Noir si sélectionné
              Expanded(
                child: _quickAction(
                  icon: Icons.remove_red_eye_outlined,
                  label: 'Vision IA',
                  isPrimary: false,
                  customColor: isVisionSelected ? Colors.black : null,
                  customTextColor: isVisionSelected ? Colors.white : null,
                  onTap: () => setState(() => _selectedTab = 4),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),

              // 3. Bouton Historique
              Expanded(
                  child: _quickAction(
                      icon: Icons.history_rounded,
                      label: 'Historique',
                      isPrimary: false,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HeraHistoryPage(
                            isDark: isDark,
                            actions: _recentActions, // ✅ On envoie les données chargées
                          ),
                        ),
                      ),                      isDark: isDark
                  )
              ),
            ],
          ),
        ],
      ),
    );
  }
  // ─────────────── TAB BAR ───────────────
  Widget _buildTabBar(bool isDark) {
    final tabs = [
      (Icons.grid_view_rounded, 'Aperçu'),
      (Icons.calendar_month_rounded, 'Agenda'),
      (Icons.people_alt_rounded, 'Équipe'),
      (Icons.auto_graph_rounded, 'Insights'),
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border(isDark)),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final sel = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: sel
                      ? (isDark ? _lime : Colors.black)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tabs[i].$1,
                      size: 18,
                      color: sel
                          ? (isDark ? Colors.black : Colors.white)
                          : _textMuted(isDark),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tabs[i].$2,
                      style: TextStyle(
                        color: sel
                            ? (isDark ? Colors.black : Colors.white)
                            : _textMuted(isDark),
                        fontSize: 10,
                        fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
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
  Widget _buildAiMonitoring(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // --- SECTION ENTÊTE ---
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _lime.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _lime.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              const Icon(Icons.security_update_good_rounded, size: 40, color: Colors.black),
              const SizedBox(height: 12),
              const Text("Système de Veille IA", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Analyse dynamique basée sur ${_employees.length} employés",
                  style: TextStyle(color: _textMuted(isDark), fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Text("Radar des Équipes", style: TextStyle(color: _text(isDark), fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        // --- GÉNÉRATION DYNAMIQUE DES LIGNES ---
        // On boucle sur chaque département défini dans nos limites
        ...deptMaxCapacities.entries.map((entry) {
          String deptName = entry.key;
          int max = entry.value;
          // On récupère le vrai compte depuis la liste _employees
          int currentCount = _countEmployeesInDept(deptName);

          return _buildRadarRow(deptName, currentCount, max, isDark);
        }).toList(),

        const SizedBox(height: 30),

        // Note d'autonomie
        _buildAiNotice(isDark),
      ],
    );
  }

// Petit widget de note en bas
  Widget _buildAiNotice(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: _cardSoft(isDark), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, size: 20, color: _lime),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Hera surveille ces barres. Si une barre passe en orange, l'agent Echo est alerté.",
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
// Widget pour chaque ligne du Radar
  Widget _buildRadarRow(String name, int count, int max, bool isDark) {
    double percent = count / max;
    bool isAlert = percent < 0.8; // Seuil de déclenchement de Hera

    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              Row(
                children: [
                  Text("$count/$max",
                      style: TextStyle(
                          color: isAlert ? Colors.orange : _textMuted(isDark),
                          fontWeight: FontWeight.bold,
                          fontSize: 12
                      )
                  ),
                  if (isAlert) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.auto_awesome, color: _lime, size: 14),
                  ]
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation<Color>(isAlert ? Colors.orange : _lime),
            ),
          ),
        ],
      ),
    );
  }
  // ─────────────── OVERVIEW ───────────────
  Widget _buildOverview(bool isDark) {
    return RefreshIndicator(
      onRefresh: _loadAdminData,
      color: _lime,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          _buildGreetingBanner(isDark),
          const SizedBox(height: 16),
          if (_loadingStats) _shimmer(isDark, height: 120) else if (_stats != null) _buildStatsRow(isDark),
          const SizedBox(height: 16),

          // ✅ AJOUTE LE RADAR ICI
          _buildDeptRadar(isDark),

          const SizedBox(height: 24),
          _buildActivitySection(isDark),
        ],
      ),
    );
  }

  Widget _buildGreetingBanner(bool isDark) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Bonjour '
        : hour < 18
        ? 'Bon après-midi'
        : 'Bonsoir ';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A1A1A), const Color(0xFF111111)]
              : [Colors.white, const Color(0xFFF8FFF0)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _lime.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    color: _textMuted(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Que voulez-vous\nfaire aujourd\'hui ?',
                  style: TextStyle(
                    color: _text(isDark),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _pillAction(
                      icon: Icons.event_note_rounded,
                      label: 'Congé',
                      onTap: () => _showComingSoon('Demande de congé'),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _pillAction(
                      icon: Icons.history_rounded,
                      label: 'Historique',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HeraHistoryPage(isDark: isDark),
                        ),
                      ),
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Decorative element
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_lime.withOpacity(0.3), _lime.withOpacity(0)],
              ),
            ),
            child: Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _lime,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _lime.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.black,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _cardSoft(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border(isDark)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: _textMuted(isDark)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: _text(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            title: 'Employés',
            value: '${_stats!['total_employees']}',
            sub: 'Total',
            icon: Icons.groups_rounded,
            accent: _lime,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            title: 'En congé',
            value: '${_stats!['on_leave_today']}',
            sub: 'Aujourd\'hui',
            icon: Icons.beach_access_rounded,
            accent: _purple,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color accent,
    required bool isDark,
  }) {
    final isLime = accent == _lime;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: isLime ? Colors.black : accent,
                ),
              ),
              Icon(
                Icons.arrow_outward_rounded,
                size: 14,
                color: _textMuted(isDark),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              color: _text(isDark),
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: _text(isDark),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(sub, style: TextStyle(color: _textMuted(isDark), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildMonthlyCard(bool isDark) {
    final days = _stats!['monthly_leave_days'] ?? 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border(isDark)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF10B981),
              size: 22,
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
                    color: _textMuted(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$days jours',
                  style: TextStyle(
                    color: _text(isDark),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'CE MOIS',
              style: TextStyle(
                color: Color(0xFF10B981),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Activité récente',
              style: TextStyle(
                color: _text(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            // ✅ Bouton "Voir tout" vers la page Historique
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HeraHistoryPage(
                    isDark: isDark,
                    actions: _recentActions, // On passe les données
                  ),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: _lime.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Voir tout',
                  style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_loadingActions)
          _shimmer(isDark, height: 80)
        else if (_recentActions.isEmpty)
          _buildEmptyState(Icons.history_rounded, 'Aucune activité', '...', isDark)
        else
        // ✅ On limite à 4 et on rend chaque carte cliquable
          ..._recentActions.take(4).toList().asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> action = entry.value;
            return GestureDetector(
              onTap: () => _showActionDetailPopup(context, action, isDark), // ✅ Ouvre les détails
              child: _buildActionCard(action, index, isDark),
            );
          }),
      ],
    );
  }
  void _showActionDetailPopup(BuildContext context, Map<String, dynamic> action, bool isDark) {
    // On récupère les détails stockés dans la base
    final details = action['details'] as Map<String, dynamic>? ?? {};
    final type = action['action_type'] ?? 'Action';
    final date = action['created_at'] != null
        ? DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(DateTime.parse(action['created_at']))
        : "Date inconnue";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: _lime),
            const SizedBox(width: 10),
            const Text("Détails de l'action", style: TextStyle(fontSize: 16)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Type : $type", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Date : $date", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const Divider(height: 30),

              // On affiche dynamiquement les détails (ex: département, message...)
              ...details.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
                    children: [
                      TextSpan(text: "${e.key} : ", style: const TextStyle(fontWeight: FontWeight.bold, color: _lime)),
                      TextSpan(text: "${e.value}"),
                    ],
                  ),
                ),
              )).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Fermer", style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }
  Widget _buildActionCard(Map<String, dynamic> action, int index, bool isDark) {
    final config = _getActionConfig(action);
    final accent = config['color'] as Color;
    final isNew = (config['badge'] as String) == 'NOUVEAU';
    final employeeName = action['employee_name'] ?? 'Employé';
    final createdAt = action['created_at'] != null
        ? DateTime.tryParse(action['created_at'].toString())
        : null;
    final timeAgo = createdAt != null ? _timeAgo(createdAt) : '';

    return Dismissible(
      key: Key('action_${_extractId(action['_id'])}_$index'),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => _deleteAction(index, _extractId(action['_id'])),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Row(
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFEF4444),
              size: 20,
            ),
            SizedBox(width: 6),
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: _card(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border(isDark)),
        ),
        child: Row(
          children: [
            // Timeline dot + icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                config['icon'] as IconData,
                color: isNew ? Colors.black : accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employeeName,
                    style: TextStyle(
                      color: _text(isDark),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    config['label'] as String,
                    style: TextStyle(color: _textMuted(isDark), fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isNew
                        ? _lime.withOpacity(0.85)
                        : accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    config['badge'] as String,
                    style: TextStyle(
                      color: isNew ? Colors.black : accent,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (timeAgo.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    timeAgo,
                    style: TextStyle(color: _textMuted(isDark), fontSize: 10.5),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────── CALENDAR ───────────────
  Widget _buildCalendar(bool isDark) {
    final leavesOnSelectedDay = _selectedDay != null
        ? _getLeavesForDay(_selectedDay!)
        : <Map<String, dynamic>>[];
    return RefreshIndicator(
      onRefresh: _loadAdminData,
      color: _lime,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Absences & congés',
                  style: TextStyle(
                    color: _text(isDark),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Sélectionnez une date pour voir les congés approuvés.',
            style: TextStyle(color: _textMuted(isDark), fontSize: 12),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: _card(isDark),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _border(isDark)),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              onDaySelected: (selectedDay, focusedDay) => setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              }),
              onFormatChanged: (format) =>
                  setState(() => _calendarFormat = format),
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              eventLoader: _getLeavesForDay,
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final leaves = _getLeavesForDay(day);
                  if (leaves.isEmpty) return null;
                  Color bg;
                  if (leaves.any((l) => l['type'] == 'urgent'))
                    bg = const Color(0xFFEF4444);
                  else if (leaves.any((l) => l['type'] == 'sick'))
                    bg = const Color(0xFFF59E0B);
                  else
                    bg = _lime;
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: bg.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: bg.withOpacity(0.5), width: 1),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: _text(isDark),
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
                      children: events.take(3).map((event) {
                        final leave = event as Map<String, dynamic>;
                        Color c;
                        switch (leave['type']) {
                          case 'urgent':
                            c = const Color(0xFFEF4444);
                            break;
                          case 'sick':
                            c = const Color(0xFFF59E0B);
                            break;
                          default:
                            c = _lime;
                        }
                        return Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: c,
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
                  shape: BoxShape.circle,
                  border: Border.all(color: _purple, width: 2),
                ),
                selectedDecoration: const BoxDecoration(
                  color: _purple,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: _text(isDark),
                  fontWeight: FontWeight.w900,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
                defaultTextStyle: TextStyle(color: _text(isDark), fontSize: 13),
                weekendTextStyle: TextStyle(
                  color: _textMuted(isDark),
                  fontSize: 13,
                ),
                outsideTextStyle: TextStyle(
                  color: _textMuted(isDark).withOpacity(0.4),
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: _lime.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                formatButtonTextStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
                titleTextStyle: TextStyle(
                  color: _text(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left_rounded,
                  color: _text(isDark),
                  size: 24,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right_rounded,
                  color: _text(isDark),
                  size: 24,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: _text(isDark),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
                weekendStyle: TextStyle(
                  color: _textMuted(isDark),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Legend
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _card(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border(isDark)),
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _legendItem('Congé annuel', _lime),
                _legendItem('Maladie', const Color(0xFFF59E0B)),
                _legendItem('Urgent', const Color(0xFFEF4444)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _selectedDay != null
                ? 'Congés du ${DateFormat('d MMMM yyyy', 'fr_FR').format(_selectedDay!)}'
                : 'Sélectionnez une date',
            style: TextStyle(
              color: _text(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (leavesOnSelectedDay.isEmpty)
            _buildEmptyState(
              Icons.event_available_rounded,
              'Aucun congé',
              'Pas d\'absence ce jour-là',
              isDark,
            )
          else
            ...leavesOnSelectedDay.map((l) => _buildLeaveDetailCard(l, isDark)),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
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
    final fmt = DateFormat('d MMM yyyy', 'fr_FR');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border(isDark)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _lime.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: Colors.black, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employeeName,
                      style: TextStyle(
                        color: _text(isDark),
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$days jour${days > 1 ? "s" : ""}',
                      style: TextStyle(color: _textMuted(isDark), fontSize: 12),
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
              color: _cardSoft(isDark),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 13,
                      color: _textMuted(isDark),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${fmt.format(startDate)} → ${fmt.format(endDate)}',
                        style: TextStyle(color: _text(isDark), fontSize: 12),
                      ),
                    ),
                  ],
                ),
                if (reason.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 13,
                        color: _textMuted(isDark),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reason,
                          style: TextStyle(
                            color: _textMuted(isDark),
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

  // ─────────────── EMPLOYEES ───────────────
  Widget _buildEmployees(bool isDark) {
    final active = _employees.where((e) => e['status'] == 'active').toList();
    final onboarding = _employees
        .where((e) => e['status'] == 'onboarding')
        .toList();
    return Column(
      children: [
        // Sub tab
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _card(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border(isDark)),
          ),
          child: Row(
            children: [
              Expanded(child: _subTab('Mon équipe', active.length, 0, isDark)),
              Expanded(
                child: _subTab('Nouveaux', onboarding.length, 1, isDark),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadAdminData,
            color: _lime,
            child: _loadingEmployees
                ? Center(child: CircularProgressIndicator(color: _lime))
                : _employeeSubTab == 0
                ? _buildActiveList(active, isDark)
                : _buildOnboardingList(onboarding, isDark),
          ),
        ),
      ],
    );
  }

  Widget _subTab(String label, int count, int index, bool isDark) {
    final sel = _employeeSubTab == index;
    return GestureDetector(
      onTap: () => setState(() => _employeeSubTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: sel ? (isDark ? _lime : Colors.black) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: sel
                    ? (isDark ? Colors.black : Colors.white)
                    : _textMuted(isDark),
                fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: sel
                      ? Colors.black.withOpacity(0.15)
                      : _cardSoft(isDark),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: sel
                        ? (isDark ? Colors.black : Colors.white)
                        : _text(isDark),
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

  Widget _buildActiveList(List<Map<String, dynamic>> employees, bool isDark) {
    // ✅ On passe les vrais paramètres ici
    if (employees.isEmpty) {
      return _buildEmptyState(
        Icons.people_outline,
        'Aucun employé actif',
        'Votre liste d\'équipe est vide pour le moment.',
        isDark,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final e = employees[index];
        return GestureDetector(
          // ✅ AU CLIC : Ouvre les documents de l'employé
          onTap: () => _showEmployeeDocuments(context, e, isDark),
          child: _buildActiveCard(e, isDark),
        );
      },
    );
  }
  void _showEmployeeDocuments(BuildContext context, Map<String, dynamic> employee, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder( // ✅ Permet de rafraîchir la fenêtre après génération
        builder: (context, setModalState) => Column(
          children: [
            const SizedBox(height: 20),
            Text(
                "Documents de ${employee['name']}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),
            const Divider(),
            Expanded(
              child: FutureBuilder(
                // On appelle l'historique de l'employé
                future: HrAgentService.getHistory(employeeId: employee['_id'].toString()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: _lime));
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text("Erreur de chargement des données."));
                  }

                  // ✅ Correction du cast pour éviter l'erreur Operator '[]'
                  final Map<String, dynamic> response = snapshot.data as Map<String, dynamic>;
                  final List actions = response['actions'] as List? ?? [];

                  // Filtrage pour ne garder que les documents (Contrat et Bulletin)
                  final docs = actions.where((a) =>
                  a['action_type'] == 'contract_renewal' ||
                      a['action_type'] == 'performance_alert'
                  ).toList();

                  // ── SI LA LISTE EST VIDE : On propose de générer ──
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.description_outlined, size: 40, color: Colors.grey[800]),
                          const SizedBox(height: 10),
                          const Text("Aucun document archivé."),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _lime,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.auto_awesome, size: 16),
                            label: const Text("Générer le contrat via Hera"),
                            onPressed: () async {
                              // On appelle l'API pour générer le doc dans le backend
                              await HrAgentService.generateHeraDoc(
                                  employeeId: employee['_id'],
                                  docType: 'contract'
                              );
                              // On rafraîchit l'interface
                              setModalState(() {});
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  // ── SI LA LISTE N'EST PAS VIDE : On affiche les docs ──
                  // ── SI LA LISTE N'EST PAS VIDE : On affiche les boutons de documents ──
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final doc = docs[i] as Map<String, dynamic>;
                      bool isContract = doc['action_type'] == 'contract_renewal';
                      String docName = isContract ? "CONTRAT DE TRAVAIL" : "BULLETIN DE PAIE";

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => _viewDocumentContent(context, doc, isDark),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: _lime.withOpacity(0.3)), // ✅ Bordure lime pour montrer que c'est cliquable
                            ),
                            child: Row(
                              children: [
                                Icon(isContract ? Icons.description_rounded : Icons.payments_rounded, color: _lime),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    docName,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded, color: _lime, size: 14), // ✅ Une simple flèche pour indiquer l'action
                              ],
                            ),
                          ),
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
    );
  }
  void _viewDocumentContent(BuildContext context, Map<String, dynamic> doc, bool isDark) {
    String content = doc['details']?['content'] ?? "Contenu indisponible";

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(15),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white, // ✅ Fond blanc pour faire "papier"
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header du document
              Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description, color: _lime, size: 20),
                    const SizedBox(width: 10),
                    const Text("Document Officiel E-Team", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              ),

              // Corps du document
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(25),
                  child: Container(
                    width: double.infinity,
                    child: Text(
                      content,
                      style: const TextStyle(
                        color: Colors.black,
                        fontFamily: 'Courier', // ✅ Style machine à écrire / légal
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              // Footer avec badge certifié
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_user, color: Colors.blue[800], size: 16),
                    const SizedBox(width: 8),
                    Text("Document certifié par Hera IA",
                        style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingList(
    List<Map<String, dynamic>> employees,
    bool isDark,
  ) {
    if (employees.isEmpty)
      return _buildEmptyState(
        Icons.celebration,
        'Aucun nouvel arrivant',
        'Tous vos employés sont déjà actifs',
        isDark,
      );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      children: employees.map((e) => _buildOnboardingCard(e, isDark)).toList(),
    );
  }
  Widget _buildActiveCard(Map<String, dynamic> employee, bool isDark) {
    final name = employee['name'] as String? ?? 'Sans nom';

    // ✅ PROTECTION : On force le cast en Map seulement si c'est une Map
    final dynamic rawBalances = employee['balances'];
    final Map<String, dynamic> balances = (rawBalances is Map) ? Map<String, dynamic>.from(rawBalances) : {};

    // Helper pour extraire les chiffres sans crasher
    String getBal(String type) {
      if (balances[type] == null) return "0/0";
      final data = balances[type] as Map<String, dynamic>;
      return "${data['remaining'] ?? 0}/${data['total'] ?? 0}";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFCCFF00).withOpacity(0.1),
            child: Text(name.isNotEmpty ? name[0] : "?", style: const TextStyle(color: Color(0xFFCCFF00))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                Text(employee['role'] ?? 'Employé', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _miniBadge(Icons.beach_access, getBal('annual'), isDark),
                    const SizedBox(width: 4),
                    _miniBadge(Icons.medical_services, getBal('sick'), isDark),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _miniBadge(IconData icon, String val, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
              icon,
              size: 12,
              color: isDark ? Colors.white60 : Colors.black54
          ),
          const SizedBox(width: 4),
          Text(
            val,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _leaveBadge(IconData icon, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _cardSoft(isDark),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: _textMuted(isDark)),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: _text(isDark),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingCard(Map<String, dynamic> employee, bool isDark) {
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
        final daysUntil = startDate
            .difference(DateTime(today.year, today.month, today.day))
            .inDays;
        if (daysUntil == 0)
          countdownText = 'Arrive aujourd\'hui';
        else if (daysUntil == 1)
          countdownText = 'Arrive demain';
        else if (daysUntil > 0)
          countdownText = 'Dans $daysUntil jours';
        else
          countdownText = 'Date passée';
      } catch (_) {}
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _lime.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _lime.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: _text(isDark),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$role • $department',
                      style: TextStyle(color: _textMuted(isDark), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _lime.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'NOUVEAU',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _cardSoft(isDark),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date de début',
                        style: TextStyle(
                          color: _textMuted(isDark),
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        dateText,
                        style: TextStyle(
                          color: _text(isDark),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                if (countdownText.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _lime.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      countdownText,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
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

  // ─────────────── INSIGHTS ───────────────
  Widget _buildInsights(bool isDark) {
    int usedEnergy = 0;
    if (_stats != null) {
      final monthly = _stats!['monthly_leave_days'] ?? 0;
      usedEnergy = (monthly * 10 / 30).round().clamp(0, 100);
    }
    final remaining = 100 - usedEnergy;
    final pct = remaining / 100;

    final tasks = [
      {
        'icon': Icons.event_note,
        'title': 'Demande de congé',
        'cost': 10,
        'color': _purple,
      },
      {
        'icon': Icons.flash_on,
        'title': 'Congé urgent',
        'cost': 15,
        'color': const Color(0xFFEC4899),
      },
      {
        'icon': Icons.person_add_alt_1,
        'title': 'Onboarding employé',
        'cost': 25,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'icon': Icons.trending_up,
        'title': 'Promotion',
        'cost': 20,
        'color': const Color(0xFF06B6D4),
      },
      {
        'icon': Icons.workspace_premium,
        'title': 'Évaluation performance',
        'cost': 18,
        'color': const Color(0xFFF59E0B),
      },
      {
        'icon': Icons.exit_to_app,
        'title': 'Offboarding',
        'cost': 30,
        'color': const Color(0xFFEF4444),
      },
    ];

    return RefreshIndicator(
      onRefresh: _loadAdminData,
      color: _lime,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // Capacity card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: _card(isDark),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _border(isDark)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _purple.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.battery_charging_full,
                        color: _purple,
                        size: 24,
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
                              color: _text(isDark),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                          Text(
                            'Réinitialisé chaque jour',
                            style: TextStyle(
                              color: _textMuted(isDark),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$remaining%',
                      style: TextStyle(
                        color: pct > 0.3 ? _purple : const Color(0xFFEF4444),
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: _cardSoft(isDark),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      pct > 0.3 ? _purple : const Color(0xFFEF4444),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$remaining / 100 disponibles',
                      style: TextStyle(color: _textMuted(isDark), fontSize: 12),
                    ),
                    Text(
                      '$usedEnergy utilisés',
                      style: TextStyle(color: _textMuted(isDark), fontSize: 12),
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
              color: _text(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 12),
          ...tasks.map((task) {
            final cost = task['cost'] as int;
            final color = task['color'] as Color;
            final canAfford = (remaining - cost) >= 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: _card(isDark),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: canAfford
                      ? _border(isDark)
                      : const Color(0xFFEF4444).withOpacity(0.2),
                ),
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
                    child: Icon(
                      task['icon'] as IconData,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task['title'] as String,
                          style: TextStyle(
                            color: _text(isDark),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Coût : $cost unités',
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
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
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Indisponible',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${remaining - cost} après',
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
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

  // ─────────────── HELPERS ───────────────
  Widget _shimmer(bool isDark, {double height = 80}) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }

  Widget _buildEmptyState(
    IconData icon,
    String title,
    String sub,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _card(isDark),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _border(isDark)),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _lime.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: Colors.black, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                color: _text(isDark),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: TextStyle(color: _textMuted(isDark), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
