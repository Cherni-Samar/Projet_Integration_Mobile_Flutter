import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:e_team/data/services/hr_agent_service.dart';
class DexoDashboardPage extends StatefulWidget {
  final String? token;
  const DexoDashboardPage({super.key, this.token});

  @override
  State<DexoDashboardPage> createState() => _DexoDashboardPageState();
}

class _DexoDashboardPageState extends State<DexoDashboardPage> with TickerProviderStateMixin {
  int _selectedTab = 0;
  bool _isLoading = true;
  bool _isAiThinking = true;
  String _dailyReport = "";
  List<Map<String, dynamic>> _documentActions = [];

  // Nouveaux états pour les fonctionnalités
  String _selectedFilter = 'all'; // all, attestation, bulletin
  String _selectedPeriod = 'week'; // week, month, all

  // ✅ ANIMATION CONTROLLER POUR PULSATION
  late AnimationController _pulseController;

  static const _dexoBlue = Color(0xFF71C6FF);
  static const _dexoBg = Color(0xFFF8FAFC);

  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();

    // ✅ INITIALISER LE CONTROLLER DE PULSATION
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _loadDexoData();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 45), (timer) {
      _loadDexoData(isAuto: true);
    });
  }

  @override
  void dispose() {
    // ✅ DISPOSER LE CONTROLLER
    _pulseController.dispose();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  // Nettoyage IA : Supprime les * et les **
  String get _cleanReport {
    return _dailyReport.replaceAll('*', '').trim();
  }

  Future<void> _loadDexoData({bool isAuto = false}) async {
    if (!mounted) return;
    if (!isAuto) setState(() => _isAiThinking = true);

    try {
      final result = await HrAgentService.getDexoCheckup();
      final docActionsResult = await HrAgentService.getDocumentActions(limit: 20);

      print('📊 DEXO CHECKUP RESULT => $result');

      final report =
          result['report'] ??
              result['dailyReport'] ??
              result['summary'] ??
              result['message'] ??
              result['data']?['report'] ??
              result['data']?['summary'] ??
              result['checkup']?['report'] ??
              result['checkup']?['summary'] ??
              "Aucune synthèse disponible.";

      if (mounted) {
        setState(() {
          _dailyReport = report.toString();
          _documentActions = List<Map<String, dynamic>>.from(
            docActionsResult['success'] == true
                ? (docActionsResult['actions'] ?? [])
                : [],
          );
          _isAiThinking = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ DEXO LOAD ERROR => $e');

      if (mounted) {
        setState(() {
          _dailyReport = "Erreur lors du chargement de la synthèse Dexo.";
          _isAiThinking = false;
          _isLoading = false;
        });
      }
    }
  }
  // Export PDF fonctionnel
  Future<void> _downloadReportPdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("E-TEAM - RAPPORT EXÉCUTIF", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 1.5, color: PdfColors.blue800),
                pw.SizedBox(height: 25),
                pw.Text("Synthese Strategique IA", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                pw.SizedBox(height: 40),
                pw.Text(_cleanReport, style: const pw.TextStyle(fontSize: 13, lineSpacing: 1.8)),
                pw.Spacer(),
                pw.Text("Document certifié par l'Agent Dexo IA", style: const pw.TextStyle(fontSize: 8, color: PdfColors.blueGrey)),
              ],
            ),
          );
        },
      ),
    );
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'Rapport_Dexo_CEO.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dexoBg,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: _dexoBlue))
            : Column(
          children: [
            _buildHeader(),
            _buildPillTabs(),
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _buildBriefingTab(),
                  _buildDocumentFactoryTab(),
                  _buildSystemMonitorTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. HEADER AVEC BOUTON RETOUR
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          _circleBtn(Icons.arrow_back_ios_new_rounded, () => Navigator.pop(context)),
          const SizedBox(width: 15),
          CircleAvatar(
            radius: 26,
            backgroundColor: _dexoBlue.withValues(alpha: 0.1),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset('assets/images/dexo.png', fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Icon(Icons.admin_panel_settings, color: _dexoBlue)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Dexo IA Admin", style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black)),
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
                            color: Color(0xFF7DBDFF).withOpacity(0.4 + 0.6 * _pulseController.value),
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'EXECUTIVE OVERSIGHT ACTIVE',
                        style: GoogleFonts.plusJakartaSans(
                          color: Color(0xFF3234FD),
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
          const Icon(Icons.verified_user_rounded, color: _dexoBlue, size: 28),
        ],
      ),
    );
  }

  // 2. TABS
  Widget _buildPillTabs() {
    final tabs = ["Dashboard", "Documents", "Agents IA"];
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: List.generate(tabs.length, (i) => Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _selectedTab == i ? _dexoBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(tabs[i], style: GoogleFonts.plusJakartaSans(color: _selectedTab == i ? Colors.white : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        )),
      ),
    );
  }

  // 3. TAB BRIEFING
  Widget _buildBriefingTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildVocalStatusCard(),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade200)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("DERNIÈRE SYNTHÈSE", style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: _dexoBlue, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              _isAiThinking
                  ? const Center(child: CircularProgressIndicator())
                  : Text(_cleanReport, style: GoogleFonts.lora(fontSize: 15, height: 1.7, color: Colors.black87)),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _downloadReportPdf,
                  icon: const Icon(Icons.download_for_offline_rounded, size: 20),
                  label: const Text("GÉNÉRER LE RAPPORT PDF"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _dexoBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
  // 4. TAB DOCUMENTS (CONSULTATION PAR CATÉGORIES)
  Widget _buildDocumentFactoryTab() {
    // Filtrer les documents
    List<Map<String, dynamic>> filteredDocs = _documentActions.where((doc) {
      // Filtre par type
      if (_selectedFilter != 'all') {
        final docType = doc['details']?['document']?.toString().toLowerCase() ?? '';
        if (_selectedFilter == 'attestation' && !docType.contains('attestation')) return false;
        if (_selectedFilter == 'bulletin' && !docType.contains('bulletin')) return false;
      }

      // Filtre par période
      if (_selectedPeriod != 'all') {
        final createdAt = doc['created_at'] ?? doc['createdAt'];
        if (createdAt != null) {
          try {
            final date = DateTime.parse(createdAt);
            final now = DateTime.now();
            final difference = now.difference(date);

            if (_selectedPeriod == 'week' && difference.inDays > 7) return false;
            if (_selectedPeriod == 'month' && difference.inDays > 30) return false;
          } catch (e) {
            // Ignore les erreurs de parsing de date
          }
        }
      }

      return true;
    }).toList();

    // Grouper les documents filtrés par catégorie
    final Map<String, List<Map<String, dynamic>>> groupedDocs = {};

    for (var action in filteredDocs) {
      final category = action['category'] ?? 'autre';
      if (!groupedDocs.containsKey(category)) {
        groupedDocs[category] = [];
      }
      groupedDocs[category]!.add(action);
    }

    // Définir l'ordre et les infos des catégories
    final categoryInfo = {
      'rh': {'name': 'Ressources Humaines', 'icon': Icons.people_alt_rounded, 'color': const Color(
          0xFF000000)},
      'finance': {'name': 'Finance & Paie', 'icon': Icons.payments_rounded, 'color': const Color(0xFF4CAF50)},
      'contrats': {'name': 'Contrats', 'icon': Icons.description_outlined, 'color': const Color(0xFF2196F3)},
      'juridique': {'name': 'Juridique', 'icon': Icons.gavel_rounded, 'color': const Color(0xFF9C27B0)},
      'factures': {'name': 'Factures', 'icon': Icons.receipt_long_outlined, 'color': const Color(0xFFF44336)},
      'rapports': {'name': 'Rapports', 'icon': Icons.assessment_outlined, 'color': const Color(0xFF00BCD4)},
      'technique': {'name': 'Technique', 'icon': Icons.engineering_outlined, 'color': const Color(0xFF607D8B)},
      'marketing': {'name': 'Marketing', 'icon': Icons.campaign_outlined, 'color': const Color(0xFFE91E63)},
      'presentations': {'name': 'Présentations', 'icon': Icons.slideshow_outlined, 'color': const Color(0xFF673AB7)},
      'autre': {'name': 'Autres', 'icon': Icons.folder_outlined, 'color': Colors.grey},
    };

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Statistiques en haut
        _buildDocumentStats(),
        const SizedBox(height: 20),

        // Filtres
        _buildFilters(),
        const SizedBox(height: 20),

        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_dexoBlue, _dexoBlue.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.folder_open_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "DOCUMENTS PAR CATÉGORIE",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey.shade700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${groupedDocs.length} catégories • ${filteredDocs.length} documents",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _dexoBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _dexoBlue.withValues(alpha: 0.2)),
              ),
              child: Text(
                '${filteredDocs.length}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: _dexoBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // État vide
        if (filteredDocs.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Aucune demande de document",
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Les demandes des employés apparaîtront ici",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
        // Affichage par catégorie
          ...groupedDocs.entries.map((entry) {
            final category = entry.key;
            final docs = entry.value;
            final info = categoryInfo[category] ?? categoryInfo['autre']!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header de catégorie
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (info['color'] as Color).withValues(alpha: 0.1),
                        (info['color'] as Color).withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (info['color'] as Color).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: info['color'] as Color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          info['icon'] as IconData,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          info['name'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: info['color'] as Color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${docs.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Documents de cette catégorie
                ...docs.map((doc) => _buildDocumentActionCard(doc, info['color'] as Color)),

                const SizedBox(height: 20),
              ],
            );
          }),
      ],
    );
  }
  // 5. TAB AGENTS IA (VERSION SIMPLE)
  Widget _buildSystemMonitorTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Header simple
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _dexoBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.hub_outlined, color: _dexoBlue, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Agents IA",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "Statut du système E-TEAM",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "4/5 ACTIFS",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Agents simples
        _buildSimpleAgentCard("Hera", "Agent RH", "Gestion des ressources humaines", true, Colors.purple),
        _buildSimpleAgentCard("Echo", "Agent Communication", "Emails et réseaux sociaux", true, Colors.blue),
        _buildSimpleAgentCard("Timo", "Agent Planning", "Gestion des rendez-vous", true, Colors.orange),
        _buildSimpleAgentCard("Dexo", "Superviseur", "Monitoring et rapports", true, _dexoBlue),
      ],
    );
  }

  Widget _buildSimpleAgentCard(String name, String role, String description, bool online, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: online ? color : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getAgentIcon(name),
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Informations
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: online ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: online ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              online ? "ACTIF" : "STANDBY",
              style: TextStyle(
                color: online ? Colors.green : Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVocalStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_dexoBlue, Color(0xFF71C6FF)]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: _dexoBlue.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))]
      ),
      child: Row(
        children: [
          const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 35),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Briefing Vocal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text("Sync Telegram : Active", style: TextStyle(color: Colors.white70, fontSize: 11)),
            ]),
          ),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)), child: const Text("21:00", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
        ],
      ),
    );
  }
  // Statistiques des documents
  Widget _buildDocumentStats() {
    final totalDocs = _documentActions.length;
    final attestations = _documentActions.where((doc) =>
    doc['details']?['document']?.toString().toLowerCase().contains('attestation') ?? false
    ).length;
    final bulletins = _documentActions.where((doc) =>
    doc['details']?['document']?.toString().toLowerCase().contains('bulletin') ?? false
    ).length;

    // Documents récents (dernières 24h)
    final recentDocs = _documentActions.where((doc) {
      final createdAt = doc['created_at'] ?? doc['createdAt'];
      if (createdAt != null) {
        try {
          final date = DateTime.parse(createdAt);
          final difference = DateTime.now().difference(date);
          return difference.inHours < 24;
        } catch (e) {
          return false;
        }
      }
      return false;
    }).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_dexoBlue, _dexoBlue.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _dexoBlue.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "STATISTIQUES DOCUMENTS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "LIVE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard("Total", totalDocs.toString(), Icons.folder_copy_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard("Attestations", attestations.toString(), Icons.verified_user_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard("Bulletins", bulletins.toString(), Icons.receipt_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard("24h", recentDocs.toString(), Icons.schedule_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Filtres
  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFilter,
                icon: Icon(Icons.filter_list, color: _dexoBlue, size: 18),
                style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w600),
                onChanged: (value) => setState(() => _selectedFilter = value!),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Tous les types')),
                  DropdownMenuItem(value: 'attestation', child: Text('Attestations')),
                  DropdownMenuItem(value: 'bulletin', child: Text('Bulletins')),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPeriod,
                icon: Icon(Icons.date_range, color: _dexoBlue, size: 18),
                style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w600),
                onChanged: (value) => setState(() => _selectedPeriod = value!),
                items: const [
                  DropdownMenuItem(value: 'week', child: Text('Cette semaine')),
                  DropdownMenuItem(value: 'month', child: Text('Ce mois')),
                  DropdownMenuItem(value: 'all', child: Text('Toute période')),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Modal de détails du document
  void _showDocumentDetails(Map<String, dynamic> document) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _dexoBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.description, color: _dexoBlue, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            document['details']?['document'] ?? 'Document',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            document['employee_name'] ?? 'Employé',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Contenu scrollable
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Informations générales
                    _buildDetailSection(
                      "Informations générales",
                      Icons.info_outline,
                      [
                        _buildDetailRow("Type", document['details']?['document'] ?? 'N/A'),
                        _buildDetailRow("Employé", document['employee_name'] ?? 'N/A'),
                        _buildDetailRow("Email", document['employee_email'] ?? 'N/A'),
                        _buildDetailRow("Catégorie", (document['category'] ?? 'general').toUpperCase()),
                        _buildDetailRow("Date", _formatDetailDate(document['created_at'] ?? document['createdAt'])),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Détails spécifiques
                    if (document['details']?['reason'] != null || document['details']?['month'] != null)
                      _buildDetailSection(
                        "Détails spécifiques",
                        Icons.assignment_outlined,
                        [
                          if (document['details']?['reason'] != null)
                            _buildDetailRow("Motif", document['details']['reason']),
                          if (document['details']?['month'] != null)
                            _buildDetailRow("Période", "${document['details']['month']}/${document['details']['year']}"),
                        ],
                      ),

                    const SizedBox(height: 30),



                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildDetailSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _dexoBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Nouvelle fonction pour afficher les demandes de documents
  Widget _buildDocumentActionCard(Map<String, dynamic> action, [Color? categoryColor]) {
    final details = action['details'] ?? {};
    final docType = details['document'] ?? 'Document';
    final category = action['category'] ?? details['category'] ?? 'general';
    final createdAt = action['created_at'] ?? action['createdAt'];
    final employeeName = action['employee_name'] ?? 'Employé';

    // Déterminer l'icône et la couleur selon la catégorie
    IconData icon;
    Color finalColor;

    if (categoryColor != null) {
      finalColor = categoryColor;
    } else {
      finalColor = _getCategoryColor(category);
    }

    icon = _getCategoryIcon(category);

    // Formater la date
    String formattedDate = 'Récent';
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        final now = DateTime.now();
        final difference = now.difference(date);

        if (difference.inMinutes < 60) {
          formattedDate = 'Il y a ${difference.inMinutes}min';
        } else if (difference.inHours < 24) {
          formattedDate = 'Il y a ${difference.inHours}h';
        } else {
          formattedDate = DateFormat('dd/MM à HH:mm').format(date);
        }
      } catch (e) {
        formattedDate = 'Récent';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: finalColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: finalColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icône catégorie
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [finalColor, finalColor.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: finalColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),

            // Informations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          docType,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: finalColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: finalColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          category.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: finalColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          employeeName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Détails supplémentaires (reason, month, etc.)
                  if (details['reason'] != null || details['month'] != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              details['reason'] ?? 'Mois: ${details['month']}/${details['year']}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Status badge et bouton détails
            const SizedBox(width: 8),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showDocumentDetails(action),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _dexoBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.visibility_outlined,
                      color: _dexoBlue,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleBtn(IconData i, VoidCallback onTap) => GestureDetector(
      onTap: onTap,
      child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: Colors.grey.shade200)),
          child: Icon(i, color: Colors.black, size: 18)
      )
  );

  // Helper: Obtenir la couleur selon la catégorie
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'rh':
        return const Color(0xFF00796B); // Teal
      case 'finance':
        return const Color(0xFF4CAF50); // Vert
      case 'contrats':
        return const Color(0xFF2196F3); // Bleu
      case 'juridique':
        return const Color(0xFF9C27B0); // Violet
      case 'factures':
        return const Color(0xFFF44336); // Rouge
      case 'rapports':
        return const Color(0xFF00BCD4); // Cyan
      case 'technique':
        return const Color(0xFF607D8B); // Gris bleu
      case 'marketing':
        return const Color(0xFFE91E63); // Rose
      case 'presentations':
        return const Color(0xFF673AB7); // Violet foncé
      default:
        return Colors.grey;
    }
  }

  // Helper: Obtenir l'icône selon la catégorie
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'rh':
        return Icons.people_alt_rounded;
      case 'finance':
        return Icons.payments_rounded;
      case 'contrats':
        return Icons.description_outlined;
      case 'juridique':
        return Icons.gavel_rounded;
      case 'factures':
        return Icons.receipt_long_outlined;
      case 'rapports':
        return Icons.assessment_outlined;
      case 'technique':
        return Icons.engineering_outlined;
      case 'marketing':
        return Icons.campaign_outlined;
      case 'presentations':
        return Icons.slideshow_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  String _formatDetailDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy à HH:mm').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  IconData _getAgentIcon(String agentName) {
    switch (agentName.toLowerCase()) {
      case 'hera':
        return Icons.people_alt_outlined;
      case 'echo':
        return Icons.campaign_outlined;
      case 'timo':
        return Icons.schedule_outlined;
      case 'dexo':
        return Icons.admin_panel_settings_outlined;
      default:
        return Icons.smart_toy_outlined;
    }
  }
}