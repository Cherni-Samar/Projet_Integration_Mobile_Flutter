import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../services/hr_agent_service.dart';
import 'package:table_calendar/table_calendar.dart';

class HrDashboardPage extends StatefulWidget {
  const HrDashboardPage({super.key});

  @override
  State<HrDashboardPage> createState() => _HrDashboardPageState();
}

class _HrDashboardPageState extends State<HrDashboardPage>
    with SingleTickerProviderStateMixin {

  // ══════════════════════════════════════════════════════════════════════════
  // VARIABLES
  // ══════════════════════════════════════════════════════════════════════════

  int _selectedTab = 0;
  int _employeeSubTab = 0; // 0 = Mon équipe, 1 = Nouveaux arrivants

  // Données admin
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _recentActions = [];
  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _allLeaves = [];

  bool _loadingStats = true;
  bool _loadingActions = true;
  bool _loadingEmployees = true;

  // Calendrier
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  late AnimationController _pulseController;
  Timer? _refreshTimer;

  // ══════════════════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ══════════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _loadAdminData();

    // Auto-refresh toutes les 30 secondes
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      print('🔄 Auto-refresh Dashboard (30s)');
      _loadAdminData();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MÉTHODES API
  // ══════════════════════════════════════════════════════════════════════════

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
    } catch (e) {
      setState(() => _loadingStats = false);
    }
  }

  Future<void> _loadRecentActions() async {
    setState(() => _loadingActions = true);

    try {
      final result = await HrAgentService.getRecentActions(limit: 3);

      if (result['success'] == true) {
        setState(() {
          _recentActions = List<Map<String, dynamic>>.from(result['recent_actions'] ?? []);
          _loadingActions = false;
        });
      } else {
        setState(() => _loadingActions = false);
      }
    } catch (e) {
      print('❌ Erreur chargement actions: $e');
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
    } catch (e) {
      setState(() => _loadingEmployees = false);
    }
  }

  Future<void> _loadAllLeaves() async {
    try {
      print('📅 Chargement des congés de tous les employés...');

      final allLeaves = <Map<String, dynamic>>[];

      for (var emp in _employees) {
        print('  → Chargement des congés de ${emp['name']}...');

        final result = await HrAgentService.getLeaves(employeeId: emp['_id']);

        if (result['success'] == true) {
          final leaves = List<Map<String, dynamic>>.from(result['leaves'] ?? []);

          print('    ✅ ${leaves.length} congé(s) trouvé(s)');

          for (var leave in leaves) {
            leave['employee_name'] = emp['name'];
            leave['employee_role'] = emp['role'];
            allLeaves.add(leave);
          }
        } else {
          print('    ❌ Erreur: ${result['error']}');
        }
      }

      print('📊 Total: ${allLeaves.length} congé(s) chargé(s) pour ${_employees.length} employé(s)');

      setState(() {
        _allLeaves = allLeaves;
      });
    } catch (e) {
      print('💥 Erreur _loadAllLeaves: $e');
    }
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

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8FAFC),
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
                  _buildEnergy(isDark),
                  _buildEmployees(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFA855F7).withOpacity(0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: isDark ? Colors.white : Colors.black,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFCCFF00).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFCCFF00),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/images/hera.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hera Dashboard',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'HR Management Agent',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Bouton refresh
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                print('🔄 Refresh manuel Dashboard');
                _loadAdminData();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🔄 Actualisation...'),
                    duration: Duration(seconds: 1),
                    backgroundColor: Color(0xFF000000),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: Icon(
                Icons.refresh_rounded,
                color: isDark ? Colors.white : Colors.black,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TABS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTabs(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _tab(Icons.dashboard_rounded, 0, isDark),
          _tab(Icons.calendar_month_rounded, 1, isDark),
          _tab(Icons.bolt_rounded, 2, isDark),
          _tab(Icons.people_rounded, 3, isDark),
        ],
      ),
    );
  }

  Widget _tab(IconData icon, int index, bool isDark) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFCCFF00).withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isSelected
                ? Colors.black
                : (isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5)),
            size: 22,
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // OVERVIEW TAB
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildOverview(bool isDark) {
    return RefreshIndicator(
      onRefresh: _loadAdminData,
      color: const Color(0xFFCCFF00),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_loadingStats)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: Color(0xFFCCFF00)),
              ),
            )
          else if (_stats != null)
            _buildStats(isDark),

          const SizedBox(height: 24),

          _buildHistorySection(isDark),
        ],
      ),
    );
  }

  Widget _buildStats(bool isDark) {
    return Row(
      children: [
        _statCard(Icons.people, 'Employés', '${_stats!['total_employees']}', isDark),
        const SizedBox(width: 12),
        _statCard(Icons.beach_access, 'En congé', '${_stats!['on_leave_today']}', isDark),
      ],
    );
  }

  Widget _statCard(IconData icon, String label, String value, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFCCFF00).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.black, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HISTORY SECTION
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildHistorySection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Historique',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Voir tout',
                style: TextStyle(
                  color: Color(0xFFA855F7),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_loadingActions)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: Color(0xFFCCFF00)),
            ),
          )
        else if (_recentActions.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                'Aucun historique pour le moment',
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          ..._recentActions.map((action) {
            IconData icon;
            Color color;
            String text;

            // Gestion des types d'actions
            switch (action['action_type']) {
              case 'onboarding_started':
                icon = Icons.person_add;
                color = const Color(0xFFCCFF00);
                text = 'Nouvel employé : ${action['details']?['name'] ?? 'Unknown'} (${action['details']?['role'] ?? ''})';
                break;

              case 'employee_activated':
                icon = Icons.check_circle;
                color = const Color(0xFF10B981);
                text = '${action['details']?['name'] ?? 'Employé'} est maintenant actif';
                break;

              case 'leave_approved':
                icon = Icons.check_circle;
                color = const Color(0xFFCCFF00);
                final employeeName = action['employee_name'] ?? 'Employé';
                text = 'Congé de $employeeName approuvé automatiquement';
                break;

              case 'leave_refused':
                icon = Icons.cancel;
                color = const Color(0xFFEF4444);
                final employeeName = action['employee_name'] ?? 'Employé';
                text = 'Congé de $employeeName refusé';
                break;

              default:
              // Fallback pour les anciens types
                switch (action['status']) {
                  case 'approved':
                    icon = Icons.check_circle;
                    color = const Color(0xFFCCFF00);
                    final employeeName = action['employee_name'] ?? 'Employé';
                    text = 'Congé de $employeeName approuvé';
                    break;
                  case 'refused':
                    icon = Icons.cancel;
                    color = const Color(0xFFEF4444);
                    final employeeName = action['employee_name'] ?? 'Employé';
                    text = 'Congé de $employeeName refusé';
                    break;
                  default:
                    icon = Icons.info;
                    color = const Color(0xFFA855F7);
                    text = 'Action Hera';
                }
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.3),
                    size: 20,
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CALENDAR TAB
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildCalendar(bool isDark) {
    final leavesOnSelectedDay = _selectedDay != null ? _getLeavesForDay(_selectedDay!) : <Map<String, dynamic>>[];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
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
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getLeavesForDay,

            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final leavesForDay = _getLeavesForDay(day);

                if (leavesForDay.isNotEmpty) {
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
                      color: backgroundColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: backgroundColor,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }
                return null;
              },

              outsideBuilder: (context, day, focusedDay) {
                final leavesForDay = _getLeavesForDay(day);

                if (leavesForDay.isNotEmpty) {
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
                      color: backgroundColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: backgroundColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: (isDark ? Colors.white : Colors.black).withOpacity(0.3),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }
                return null;
              },

              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
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
                }
                return null;
              },
            ),

            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFA855F7), width: 2),
              ),
              selectedDecoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFA855F7), Color(0xFF8B5CF6)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA855F7).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              todayTextStyle: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              defaultTextStyle: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
              ),
              weekendTextStyle: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
              outsideTextStyle: TextStyle(
                color: isDark ? Colors.white30 : Colors.black26,
              ),
            ),

            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: const Color(0xFFCCFF00).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFCCFF00)),
              ),
              formatButtonTextStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              titleTextStyle: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left_rounded,
                color: isDark ? Colors.white : Colors.black,
                size: 28,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white : Colors.black,
                size: 28,
              ),
            ),

            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              weekendStyle: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Légende',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildLegendItem('Congé annuel', const Color(0xFFCCFF00)),
                  const SizedBox(width: 16),
                  _buildLegendItem('Maladie', const Color(0xFFF59E0B)),
                  const SizedBox(width: 16),
                  _buildLegendItem('Urgent', const Color(0xFFEF4444)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Text(
          _selectedDay != null
              ? 'Congés le ${DateFormat('d MMMM yyyy', 'fr_FR').format(_selectedDay!)}'
              : 'Sélectionnez une date',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        if (leavesOnSelectedDay.isEmpty)
          _buildEmpty(Icons.event_available, 'Aucun congé', 'Pas d\'absence ce jour-là', isDark)
        else
          ...leavesOnSelectedDay.map((leave) => _buildLeaveDetailCard(leave, isDark)),
      ],
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
            fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFF00).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFCCFF00),
                    width: 1.5,
                  ),
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
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$days jour${days > 1 ? "s" : ""}',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 13,
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
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: isDark ? Colors.white60 : Colors.black54),
                    const SizedBox(width: 8),
                    Text(
                      '${dateFormat.format(startDate)} → ${dateFormat.format(endDate)}',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (reason.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 14, color: isDark ? Colors.white60 : Colors.black54),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reason,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
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

  // ══════════════════════════════════════════════════════════════════════════
  // ENERGY TAB
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildEnergy(bool isDark) {
    int usedEnergy = 45;

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
        'color': const Color(0xFFA855F7),
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFA855F7).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA855F7).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.battery_charging_full,
                      color: Color(0xFFA855F7),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget Énergie Hera',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Réinitialisé chaque jour',
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Stack(
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: remainingEnergy / 100,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: remainingEnergy > 30
                              ? [const Color(0xFFA855F7), const Color(0xFF8B5CF6)]
                              : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: (remainingEnergy > 30
                                ? const Color(0xFFA855F7)
                                : const Color(0xFFEF4444)).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$remainingEnergy / 100',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Unités disponibles',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bolt,
                          color: remainingEnergy > 30
                              ? const Color(0xFFA855F7)
                              : const Color(0xFFEF4444),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$usedEnergy utilisés',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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

        const SizedBox(height: 24),

        Row(
          children: [
            Text(
              'Tâches disponibles',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFA855F7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${tasks.length}',
                style: const TextStyle(
                  color: Color(0xFFA855F7),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        ...tasks.map((task) {
          final cost = task['cost'] as int;
          final afterUse = remainingEnergy - cost;
          final canAfford = afterUse >= 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: canAfford
                    ? (task['color'] as Color).withOpacity(0.3)
                    : Colors.red.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: (task['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
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
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.bolt,
                                size: 14,
                                color: task['color'] as Color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Coût : $cost unités',
                                style: TextStyle(
                                  color: task['color'] as Color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!canAfford)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.block, color: Colors.red, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Indisponible',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
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
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Après exécution : ',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        canAfford ? '$afterUse unités restantes' : 'Budget insuffisant',
                        style: TextStyle(
                          color: canAfford
                              ? (task['color'] as Color)
                              : Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFA855F7).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFA855F7).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Color(0xFFA855F7), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Le budget se réinitialise automatiquement chaque jour à minuit',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // EMPLOYEES TAB - SÉPARÉ EN 2 SECTIONS
  // ══════════════════════════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════════════════════════
// EMPLOYEES TAB - AVEC SUB-TABS
// ══════════════════════════════════════════════════════════════════════════


  Widget _buildEmployees(bool isDark) {
    // Sépare les employés actifs et en onboarding
    final activeEmployees = _employees
        .where((e) => e['status'] == 'active')
        .toList();

    final onboardingEmployees = _employees
        .where((e) => e['status'] == 'onboarding')
        .toList();

    return Column(
      children: [
        // ═══════════════════════════════════════════════════════════════════
        // SUB-TABS
        // ═══════════════════════════════════════════════════════════════════
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _employeeSubTab = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _employeeSubTab == 0
                          ? (isDark ? Colors.white : Colors.white)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: _employeeSubTab == 0
                          ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Mon équipe',
                          style: TextStyle(
                            color: _employeeSubTab == 0
                                ? Colors.black
                                : (isDark ? Colors.white60 : Colors.black54),
                            fontSize: 14,
                            fontWeight: _employeeSubTab == 0
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                        if (activeEmployees.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _employeeSubTab == 0
                                  ? const Color(0xFFCCFF00)
                                  : (isDark ? Colors.white24 : Colors.black12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${activeEmployees.length}',
                              style: const TextStyle(
                                color: Colors.black, // ✅ TOUJOURS NOIR
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _employeeSubTab == 1
                          ? (isDark ? Colors.white : Colors.white)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: _employeeSubTab == 1
                          ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Nouveaux',
                          style: TextStyle(
                            color: _employeeSubTab == 1
                                ? Colors.black
                                : (isDark ? Colors.white60 : Colors.black54),
                            fontSize: 14,
                            fontWeight: _employeeSubTab == 1
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                        if (onboardingEmployees.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _employeeSubTab == 1
                                  ? const Color(0xFFCCFF00)
                                  : (isDark ? Colors.white24 : Colors.black12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${onboardingEmployees.length}',
                              style: const TextStyle(
                                color: Colors.black, // ✅ TOUJOURS NOIR
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
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

        // ═══════════════════════════════════════════════════════════════════
        // CONTENU SELON LE TAB
        // ═══════════════════════════════════════════════════════════════════
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadAdminData,
            color: const Color(0xFFCCFF00),
            child: _loadingEmployees
                ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFCCFF00)),
            )
                : _employeeSubTab == 0
                ? _buildActiveEmployeesList(activeEmployees, isDark)
                : _buildOnboardingEmployeesList(onboardingEmployees, isDark),
          ),
        ),
      ],
    );
  }
// ══════════════════════════════════════════════════════════════════════════
// LISTE EMPLOYÉS ACTIFS
// ══════════════════════════════════════════════════════════════════════════

  Widget _buildActiveEmployeesList(List<Map<String, dynamic>> employees, bool isDark) {
    if (employees.isEmpty) {
      return _buildEmpty(
        Icons.people_outline,
        'Aucun employé actif',
        'Tous vos employés sont en cours d\'intégration',
        isDark,
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: employees.map((emp) => _buildActiveEmployeeCard(emp, isDark)).toList(),
    );
  }

// ══════════════════════════════════════════════════════════════════════════
// LISTE NOUVEAUX ARRIVANTS
// ══════════════════════════════════════════════════════════════════════════

  Widget _buildOnboardingEmployeesList(List<Map<String, dynamic>> employees, bool isDark) {
    if (employees.isEmpty) {
      return _buildEmpty(
        Icons.celebration,
        'Aucun nouvel arrivant',
        'Tous vos employés sont déjà actifs',
        isDark,
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: employees.map((emp) => _buildOnboardingEmployeeCard(emp, isDark)).toList(),
    );
  }
  // Card employé actif
  Widget _buildActiveEmployeeCard(Map<String, dynamic> employee, bool isDark) {
    final name = employee['name'] as String;
    final role = employee['role'] as String;
    final department = employee['department'] as String;
    final balances = employee['balances'] as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFF00).withOpacity(0.2), // ✅ Fond jaune
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFCCFF00),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black, // ✅ LETTRE TOUJOURS NOIRE
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
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
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$role • $department',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _badge(Icons.beach_access, '${balances['annual']['remaining']}/${balances['annual']['total']}', isDark),
              const SizedBox(width: 8),
              _badge(Icons.medical_services, '${balances['sick']['remaining']}/${balances['sick']['total']}', isDark),
              const SizedBox(width: 8),
              _badge(Icons.warning_amber_rounded, '${balances['urgent']['remaining']}/${balances['urgent']['total']}', isDark),
            ],
          ),
        ],
      ),
    );
  }
  // Card employé en onboarding
  Widget _buildOnboardingEmployeeCard(Map<String, dynamic> employee, bool isDark) {
    final name = employee['name'] as String;
    final role = employee['role'] as String;
    final department = employee['department'] as String;

    final startDateStr = employee['start_date'] as String?;

    DateTime? startDate;
    String dateText = 'Date non définie';
    String countdownText = '';

    if (startDateStr != null && startDateStr.isNotEmpty) {
      try {
        startDate = DateTime.parse(startDateStr);
        dateText = DateFormat('d MMMM yyyy', 'fr_FR').format(startDate);

        final today = DateTime.now();
        final daysUntilStart = startDate.difference(DateTime(today.year, today.month, today.day)).inDays;

        if (daysUntilStart == 0) {
          countdownText = 'Arrive aujourd\'hui !';
        } else if (daysUntilStart == 1) {
          countdownText = 'Arrive demain';
        } else if (daysUntilStart > 0) {
          countdownText = 'Arrive dans $daysUntilStart jours';
        } else {
          countdownText = 'Date de début passée';
        }
      } catch (e) {
        print('❌ Erreur parsing date: $e');
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFCCFF00),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCCFF00).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFF00).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFCCFF00),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCCFF00).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFCCFF00),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            ' Nouveau',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$role • $department',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Informations de date
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFCCFF00).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFCCFF00).withOpacity(0.3),
                width: 1,
              ),
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
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateText,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
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
                          borderRadius: BorderRadius.circular(8),
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
                                fontWeight: FontWeight.bold,
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
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: Colors.black),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(IconData icon, String title, String subtitle, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFCCFF00).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.black, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}