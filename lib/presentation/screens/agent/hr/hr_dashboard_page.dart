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
import 'package:e_team/presentation/widgets/hera/hera_shared_widgets.dart';
import 'tabs/hr_flux_tab.dart';
import 'tabs/hr_agenda_tab.dart';
import 'tabs/hr_team_tab.dart';
import 'tabs/hr_energy_tab.dart';
import 'tabs/hr_vision_tab.dart';
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
              HrHeader(
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
              HrPillTabBar(
                tabs: _tabs,
                selected: _selectedTab,
                onSelect: (i) => setState(() => _selectedTab = i),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: IndexedStack(
                  index: _selectedTab,
                  children: [
                    HrFluxTab(
                      recentActions: _recentActions,
                      loadingStats: _loadingStats,
                      loadingActions: _loadingActions,
                      stats: _stats,
                      pulseCtrl: _pulseCtrl,
                      onRefresh: _loadAll,
                      onDeleteAction: _deleteAction,
                      onShowDetail: _showActionDetail,
                    ),
                    HrAgendaTab(
                      selectedDay: _selectedDay,
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      allLeaves: _allLeaves,
                      onRefresh: _loadAll,
                      onDaySelected: (selected, focused) => setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                      }),
                      onFormatChanged: (format) =>
                          setState(() => _calendarFormat = format),
                      onPageChanged: (focused) => _focusedDay = focused,
                    ),
                    HrTeamTab(
                      employees: _employees,
                      candidates: _candidates,
                      loadingEmployees: _loadingEmployees,
                      employeeSubTab: _employeeSubTab,
                      onRefresh: _loadAll,
                      onSubTabChanged: (i) =>
                          setState(() => _employeeSubTab = i),
                      onEmployeeTap: _showEmployeeDocuments,
                    ),
                    HrEnergyTab(
                      energyBalance:
                          context.read<UserProvider>().energyBalance,
                    ),
                    HrVisionTab(
                      employees: _employees,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteAction(Map<String, dynamic> action, int index) async {
    if (index >= _recentActions.length) return;
    final id = _extractId(action['_id']);

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
}


