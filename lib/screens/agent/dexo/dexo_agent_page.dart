import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/hr_agent_service.dart';
import '../../../services/vocal_service.dart';

class DexoDashboardPage extends StatefulWidget {
  const DexoDashboardPage({super.key});

  @override
  State<DexoDashboardPage> createState() => _DexoDashboardPageState();
}

class _DexoDashboardPageState extends State<DexoDashboardPage> {
  int _selectedTab = 0;
  bool _isLoading = true;
  bool _isAiThinking = true;
  String _dailyReport = "";
  List<Map<String, dynamic>> _recentActions = [];

  static const _dexoBlue = Color(0xFF7DBDFF);
  static const _dexoDeepBlue = Color(0xFF6095FF);
  static const _dexoLightBlue = Color(0xFFE6F0FF);

  Timer? _autoRefreshTimer;
  final VocalService _vocalService = VocalService();

  @override
  void initState() {
    super.initState();
    _initDexo();
  }

  void _initDexo() async {
    _loadDexoData();
    await _vocalService.init();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 45), (timer) {
      _loadDexoData(isAuto: true);
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _vocalService.stop();
    super.dispose();
  }

  String get _cleanReport {
    return _dailyReport.replaceAll('*', '').trim();
  }

  Future<void> _loadDexoData({bool isAuto = false}) async {
    if (!mounted) return;
    if (!isAuto) setState(() => _isAiThinking = true);

    try {
      final result = await HrAgentService.getDexoCheckup();
      if (mounted) {
        setState(() {
          _dailyReport = result['report'] ?? "Analyse terminée.";
          _recentActions = List<Map<String, dynamic>>.from(result['rawActions'] ?? []);
          _isAiThinking = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isAiThinking = false; _isLoading = false; });
    }
  }

  Future<void> _downloadReportPdf() async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

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
                pw.Text("ID Session: ${DateTime.now().millisecondsSinceEpoch}", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
                pw.SizedBox(height: 40),
                pw.Text(_cleanReport, style: const pw.TextStyle(fontSize: 13, lineSpacing: 1.8)),
                pw.Spacer(),
                pw.Divider(),
                pw.Text("Document certifié par l'Agent Dexo IA - E-Team Group 2026", style: const pw.TextStyle(fontSize: 8, color: PdfColors.blueGrey)),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'Rapport_Dexo_CEO.pdf');
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return "${diff.inMinutes}m";
    return DateFormat('dd MMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020202) : const Color(0xFFF0F4F8),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: _dexoBlue))
            : Column(
          children: [
            _buildHeader(isDark),
            _buildQuickStats(isDark),
            _buildTabs(isDark),
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _buildReportTab(isDark),
                  _buildSecurityTab(isDark),
                  _buildAgentsTab(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
      child: Row(
        children: [
          _circleBtn(Icons.arrow_back_ios_new_rounded, () => Navigator.pop(context), isDark),
          const SizedBox(width: 15),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: _dexoBlue),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset('assets/images/dexo.png', width: 52, height: 52, fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const CircleAvatar(radius: 26, backgroundColor: _dexoBlue, child: Icon(Icons.admin_panel_settings, color: Colors.white))),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Dexo", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 22, fontWeight: FontWeight.w900)),
                const Text("IA SUPERVISEUR", style: TextStyle(color: _dexoBlue, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ],
            ),
          ),
          const Icon(Icons.verified_rounded, color: _dexoBlue, size: 24),
        ],
      ),
    );
  }

  Widget _buildQuickStats(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _statCard("Mouvements", _recentActions.length.toString(), isDark),
          const SizedBox(width: 10),
          _statCard("Système", "Optimal", isDark),
          const SizedBox(width: 10),
          _statCard("Protection", "High", isDark),
        ],
      ),
    );
  }

  Widget _statCard(String l, String v, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_dexoBlue, _dexoDeepBlue],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: _dexoBlue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Column(
          children: [
            Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(l, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(bool isDark) {
    final tabs = ["Synthèse IA", "Sécurité", "Agents"];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: tabs.asMap().entries.map((e) {
            bool sel = _selectedTab == e.key;
            return Expanded(child: GestureDetector(
              onTap: () => setState(() => _selectedTab = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: sel ? (isDark ? Colors.white24 : Colors.white) : Colors.transparent, borderRadius: BorderRadius.circular(14), boxShadow: sel && !isDark ? [BoxShadow(color: Colors.black12, blurRadius: 10)] : []),
                child: Center(child: Text(e.value, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: sel ? FontWeight.bold : FontWeight.normal, fontSize: 12))),
              ),
            ));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildReportTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161618) : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _dexoBlue.withOpacity(0.2)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.5 : 0.05), blurRadius: 30)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: _dexoBlue.withOpacity(0.08), borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome_mosaic_rounded, color: _dexoBlue, size: 22),
                    SizedBox(width: 12),
                    Text("RAPPORT DÉCISIONNEL", style: TextStyle(color: _dexoBlue, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: _isAiThinking
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: _dexoBlue))
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _cleanReport,
                      style: TextStyle(
                          color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                          fontSize: 16,
                          height: 1.8,
                          fontFamily: 'serif',
                          fontStyle: FontStyle.italic
                      ),
                    ),
                    const SizedBox(height: 35),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _dexoBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 8,
                          shadowColor: _dexoBlue.withOpacity(0.4),
                        ),
                        onPressed: _downloadReportPdf,
                        icon: const Icon(Icons.file_upload_outlined, size: 20),
                        label: const Text("TÉLÉCHARGER LE PDF CERTIFIÉ", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text("Audit des Activités", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        const SizedBox(height: 15),
        ..._recentActions.take(3).map((a) => _logTile(a['action_type'], a['details'] ?? {}, a['created_at'] ?? DateTime.now().toString(), isDark)).toList(),
      ],
    );
  }

  Widget _buildSecurityTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(color: _dexoBlue.withOpacity(0.08), borderRadius: BorderRadius.circular(30), border: Border.all(color: _dexoBlue.withOpacity(0.2))),
          child: Column(
            children: [
              const Icon(Icons.shield_rounded, color: _dexoBlue, size: 50),
              const SizedBox(height: 15),
              const Text("Protection Active", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 20),
              _row("Chiffrement base", "ACTIF"),
              _row("Tunnel Agents IA", "SÉCURISÉ"),
              _row("Journal d'Audit", "EN LIGNE"),
            ],
          ),
        ),
        const SizedBox(height: 30),
        ..._recentActions.take(5).map((a) => _logTile(a['action_type'], a['details'] ?? {}, a['created_at'] ?? DateTime.now().toString(), isDark)).toList(),
      ],
    );
  }

  Widget _row(String l, String s) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [const Icon(Icons.check_circle, color: Colors.green, size: 16), const SizedBox(width: 10), Text(l, style: const TextStyle(fontSize: 13, color: Colors.grey)), const Spacer(), Text(s, style: const TextStyle(color: _dexoBlue, fontWeight: FontWeight.bold, fontSize: 11))]));

  Widget _buildAgentsTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text("Statut du Hub IA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 20),
        _agentCard("Hera", "RH", "Active", Icons.person, isDark),
        _agentCard("Echo", "Com", "Veille", Icons.campaign, isDark),
        _agentCard("Timo", "Logs", "Active", Icons.calendar_month, isDark),
      ],
    );
  }

  Widget _agentCard(String n, String r, String s, IconData i, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF161618) : Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _dexoBlue.withOpacity(0.1), shape: BoxShape.circle), child: Icon(i, color: _dexoBlue, size: 24)),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(n, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(r, style: const TextStyle(color: Colors.grey, fontSize: 12))])),
        Text(s, style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _logTile(String type, Map<String, dynamic> details, String date, bool isDark) {
    String title = type.replaceAll('_', ' ').toUpperCase();
    if (type == 'absence_alert') title = "STAFFING : ${details['department'] ?? 'REQUIS'}";
    try {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: isDark ? const Color(0xFF161618) : Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          const Icon(Icons.circle, color: _dexoBlue, size: 8),
          const SizedBox(width: 15),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
          Text(_timeAgo(DateTime.parse(date)), style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ]),
      );
    } catch (e) {
      return Container();
    }
  }

  Widget _circleBtn(IconData i, VoidCallback onTap, bool isDark) => GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)), child: Icon(i, color: isDark ? Colors.white : Colors.black, size: 18)));
}
