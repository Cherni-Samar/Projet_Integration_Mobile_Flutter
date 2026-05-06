import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:e_team/core/errors/app_error.dart';
import 'package:e_team/data/services/hera_service.dart';
import 'package:e_team/domain/models/hera_models.dart';
import 'package:e_team/presentation/providers/hera_provider.dart';
import 'package:e_team/presentation/providers/user_provider.dart';
import 'package:e_team/presentation/screens/hera/hera_history_page.dart';
import 'package:e_team/presentation/screens/hera/hera_voice_page.dart';
import 'package:e_team/presentation/widgets/common/app_error_snack_bar.dart';
import 'package:e_team/presentation/widgets/hera/hera_shared_widgets.dart';
import 'package:e_team/presentation/screens/hera/tabs/hera_flux_tab.dart';
import 'package:e_team/presentation/screens/hera/tabs/hera_agenda_tab.dart';
import 'package:e_team/presentation/screens/hera/tabs/hera_team_tab.dart';
import 'package:e_team/presentation/screens/hera/tabs/hera_energy_tab.dart';
import 'package:e_team/presentation/screens/hera/tabs/hera_vision_tab.dart';

// ─── Selector value objects ──────────────────────────────────────────────────
// Each bundles exactly the fields one tab needs.
// Equality is value-based so Selector skips rebuilds when nothing changed.

@immutable
class _FluxData {
  final List<Map<String, dynamic>> recentActions;
  final bool loadingStats;
  final bool loadingActions;
  final HeraStats? stats;

  const _FluxData({
    required this.recentActions,
    required this.loadingStats,
    required this.loadingActions,
    required this.stats,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _FluxData &&
          recentActions == other.recentActions &&
          loadingStats == other.loadingStats &&
          loadingActions == other.loadingActions &&
          stats == other.stats;

  @override
  int get hashCode =>
      Object.hash(recentActions, loadingStats, loadingActions, stats);
}

@immutable
class _TeamData {
  final List<HeraEmployee> employees;
  final List<HeraCandidate> candidates;
  final bool loadingEmployees;

  const _TeamData({
    required this.employees,
    required this.candidates,
    required this.loadingEmployees,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TeamData &&
          employees == other.employees &&
          candidates == other.candidates &&
          loadingEmployees == other.loadingEmployees;

  @override
  int get hashCode => Object.hash(employees, candidates, loadingEmployees);
}

// ─── Page ────────────────────────────────────────────────────────────────────

class HeraDashboardPage extends StatefulWidget {
  const HeraDashboardPage({super.key});

  @override
  State<HeraDashboardPage> createState() => _HeraDashboardPageState();
}

class _HeraDashboardPageState extends State<HeraDashboardPage>
    with TickerProviderStateMixin {
  // ─── Pure UI state ────────────────────────────────────────────────────────
  int _selectedTab = 0;
  int _employeeSubTab = 0;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // ─── Animation controllers ────────────────────────────────────────────────
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

    // Trigger initial data load via provider — unchanged from Phase 8
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HeraProvider>();

      // ── Error listener ────────────────────────────────────────────────────
      // Reacts to provider errors as a side effect (SnackBar).
      // Does NOT cause any widget rebuild — Selector optimization is preserved.
      provider.addListener(_onProviderError);

      provider.loadDashboardData();
    });
  }

  @override
  void dispose() {
    // Remove the error listener before disposing to avoid calling setState
    // on a dead widget.
    context.read<HeraProvider>().removeListener(_onProviderError);
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  // ─── UI helpers ───────────────────────────────────────────────────────────

  void _openVoicePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HeraVoicePage()),
    );
  }

  /// Called by the provider listener whenever [HeraProvider.error] changes.
  /// Shows a SnackBar with a retry action for recoverable errors.
  /// Clears the error from the provider after displaying it so it doesn't
  /// re-fire on the next unrelated notifyListeners() call.
  void _onProviderError() {
    if (!mounted) return;
    final provider = context.read<HeraProvider>();
    final error = provider.error;
    if (error == null) return;

    AppErrorSnackBar.show(
      context,
      error,
      onRetry: () {
        provider.clearError();
        provider.refresh();
      },
    );

    // Clear after scheduling the SnackBar so the listener doesn't re-fire
    // for the same error on the next unrelated notifyListeners() call.
    provider.clearError();
  }

  /// Generic success / info toast (non-error messages).
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

  // ─── Action handlers ──────────────────────────────────────────────────────

  Future<void> _deleteAction(Map<String, dynamic> action, int index) async {
    final error = await context.read<HeraProvider>().deleteAction(
      action,
      index,
    );
    if (!mounted) return;
    if (error != null) {
      AppErrorSnackBar.show(context, error);
    } else {
      _toast('Action supprimée');
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // The Scaffold itself has NO provider subscription.
    // Each section subscribes only to the slice it needs via Selector.
    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: HeraPalette.bg,
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: HeraPalette.textPrimary,
          displayColor: HeraPalette.textPrimary,
        ),
      ),
      child: Scaffold(
        backgroundColor: HeraPalette.bg,
        body: FadeTransition(
          opacity: _fadeCtrl,
          child: SafeArea(
            child: Column(
              children: [
                // ── Header: only re-renders when recentActions changes ──────
                // (needed for the history button to pass the latest list)
                Selector<HeraProvider, List<Map<String, dynamic>>>(
                  selector: (_, p) => p.recentActions,
                  builder: (_, recentActions, __) => HeraHeader(
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
                          actions: recentActions.toList(),
                          isDark: false,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ── Tab bar: pure UI state, no provider needed ──────────────
                HeraPillTabBar(
                  tabs: _tabs,
                  selected: _selectedTab,
                  onSelect: (i) => setState(() => _selectedTab = i),
                ),

                const SizedBox(height: 10),

                // ── Tab content: each tab has its own targeted Selector ─────
                Expanded(
                  child: IndexedStack(
                    index: _selectedTab,
                    children: [
                      // Tab 0 — Flux
                      // Rebuilds only when: recentActions, loadingStats,
                      // loadingActions, or stats change.
                      Selector<HeraProvider, _FluxData>(
                        selector: (_, p) => _FluxData(
                          recentActions: p.recentActions,
                          loadingStats: p.loadingStats,
                          loadingActions: p.loadingActions,
                          stats: p.stats,
                        ),
                        builder: (_, data, __) => HeraFluxTab(
                          recentActions: data.recentActions.toList(),
                          loadingStats: data.loadingStats,
                          loadingActions: data.loadingActions,
                          stats: data.stats,
                          pulseCtrl: _pulseCtrl,
                          onRefresh: context.read<HeraProvider>().refresh,
                          onDeleteAction: _deleteAction,
                          onShowDetail: _showActionDetail,
                        ),
                      ),

                      // Tab 1 — Agenda
                      // Rebuilds only when allLeaves changes.
                      // Calendar UI state (_selectedDay, _focusedDay,
                      // _calendarFormat) is local setState — handled by the
                      // outer StatefulWidget rebuild, not the Selector.
                      Selector<HeraProvider, List<HeraLeave>>(
                        selector: (_, p) => p.allLeaves,
                        builder: (_, allLeaves, __) => HeraAgendaTab(
                          selectedDay: _selectedDay,
                          focusedDay: _focusedDay,
                          calendarFormat: _calendarFormat,
                          allLeaves: allLeaves.toList(),
                          onRefresh: context.read<HeraProvider>().refresh,
                          onDaySelected: (selected, focused) => setState(() {
                            _selectedDay = selected;
                            _focusedDay = focused;
                          }),
                          onFormatChanged: (format) =>
                              setState(() => _calendarFormat = format),
                          onPageChanged: (focused) => _focusedDay = focused,
                        ),
                      ),

                      // Tab 2 — Team
                      // Rebuilds only when employees, candidates, or
                      // loadingEmployees change.
                      Selector<HeraProvider, _TeamData>(
                        selector: (_, p) => _TeamData(
                          employees: p.employees,
                          candidates: p.candidates,
                          loadingEmployees: p.loadingEmployees,
                        ),
                        builder: (_, data, __) => HeraTeamTab(
                          employees: data.employees.toList(),
                          candidates: data.candidates.toList(),
                          loadingEmployees: data.loadingEmployees,
                          employeeSubTab: _employeeSubTab,
                          onRefresh: context.read<HeraProvider>().refresh,
                          onSubTabChanged: (i) =>
                              setState(() => _employeeSubTab = i),
                          onEmployeeTap: _showEmployeeDocuments,
                        ),
                      ),

                      // Tab 3 — Energy
                      // No HeraProvider data needed — only UserProvider.
                      // Selector on UserProvider.energyBalance so it only
                      // rebuilds when the balance actually changes.
                      Selector<UserProvider, int>(
                        selector: (_, p) => p.energyBalance,
                        builder: (_, energyBalance, __) =>
                            HeraEnergyTab(energyBalance: energyBalance),
                      ),

                      // Tab 4 — Vision
                      // Rebuilds only when employees list changes.
                      Selector<HeraProvider, List<HeraEmployee>>(
                        selector: (_, p) => p.employees,
                        builder: (_, employees, __) =>
                            HeraVisionTab(employees: employees.toList()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── UI-only dialogs / sheets ─────────────────────────────────────────────

  void _showActionDetail(Map<String, dynamic> action) {
    final details = action['details'] is Map<String, dynamic>
        ? action['details'] as Map<String, dynamic>
        : <String, dynamic>{};

    final date = action['created_at'] != null
        ? DateFormat(
            'dd MMMM yyyy · HH:mm',
            'fr_FR',
          ).format(DateTime.parse(action['created_at']))
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
                  future: HeraService.getHistory(employeeId: emp.id),
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
                            await HeraService.generateHeraDoc(
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
                              color: HeraPalette.mauve.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isContract ? Icons.description : Icons.payments,
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
    final content =
        doc['details']?['content'] as String? ?? 'Contenu indisponible';

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
