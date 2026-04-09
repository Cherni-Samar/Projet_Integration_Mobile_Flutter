import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/hr_agent_service.dart';

class DexoDashboardPage extends StatefulWidget {
  const DexoDashboardPage({super.key});

  @override
  State<DexoDashboardPage> createState() => _DexoDashboardPageState();
}

class _DexoDashboardPageState extends State<DexoDashboardPage> {
  int _selectedTab = 0;
  bool _isLoading = true;
  String _dailyReport = "";
  List<Map<String, dynamic>> _recentActions = [];
  static const _dexoBlue = Color(0xFF007BFF);

  // ✅ Timer pour le rafraîchissement automatique
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadDexoData();

    // ✅ Relance l'analyse toutes le 30 secondes sans bloquer l'écran
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadDexoData(isAuto: true);
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel(); // ✅ Toujours annuler le timer
    super.dispose();
  }

  // ── CHARGEMENT DES DONNÉES ──
  Future<void> _loadDexoData({bool isAuto = false}) async {
    if (!mounted) return;

    // On ne montre le loader que pour le premier chargement ou si manuel
    if (!isAuto && _dailyReport.isEmpty) {
      setState(() => _isLoading = true);
    }

    try {
      final result = await HrAgentService.getDexoCheckup();
      if (mounted) {
        setState(() {
          _dailyReport = result['report'] ?? "Analyse terminée.";
          _recentActions = List<Map<String, dynamic>>.from(result['rawActions'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return "il y a ${diff.inMinutes}m";
    if (diff.inHours < 24) return "il y a ${diff.inHours}h";
    return DateFormat('dd MMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF050505) : const Color(0xFFF8F9FA),
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
                  _buildReportTab(isDark),   // Index 0
                  _buildSecurityTab(isDark), // Index 1
                  _buildAgentsTab(isDark),   // Index 2
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER AMÉLIORÉ (SANS REFRESH) ──
  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Dexo", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  const Text("LIVE SUPERVISOR", style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Badge Statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: _dexoBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.radar, color: _dexoBlue, size: 18),
          )
        ],
      ),
    );
  }

  Widget _buildQuickStats(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _statCard("Logs", _recentActions.length.toString(), isDark),
          const SizedBox(width: 10),
          _statCard("Santé", "Stable", isDark),
          const SizedBox(width: 10),
          _statCard("Sécurité", "Protégé", isDark),
        ],
      ),
    );
  }

  Widget _statCard(String l, String v, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Column(
          children: [
            Text(v, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
            Text(l, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(bool isDark) {
    final tabs = ["Synthèse IA", "Sécurité", "Agents"];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        children: tabs.asMap().entries.map((e) {
          bool sel = _selectedTab == e.key;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = e.key),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                color: sel ? _dexoBlue : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(e.value, style: TextStyle(color: sel ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── ONGLET 1 : SYNTHÈSE IA (STRATÉGIQUE) ──
  Widget _buildReportTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111111) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _dexoBlue.withOpacity(0.3)),
            boxShadow: isDark ? [] : [BoxShadow(color: _dexoBlue.withOpacity(0.1), blurRadius: 20)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(color: _dexoBlue.withOpacity(0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
                child: Row(
                  children: [
                    const Icon(Icons.analytics_outlined, color: _dexoBlue, size: 18),
                    const SizedBox(width: 10),
                    const Text("ANALYSE DÉCISIONNELLE", style: TextStyle(color: _dexoBlue, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.1)),
                    const Spacer(),
                    Text(DateFormat('HH:mm').format(DateTime.now()), style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.format_quote_rounded, color: _dexoBlue.withOpacity(0.2), size: 40),
                    Transform.translate(
                      offset: const Offset(0, -15),
                      child: Text(_dailyReport, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15, height: 1.6, fontStyle: FontStyle.italic)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Text("Derniers Mouvements", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 15),
        ..._recentActions.take(3).map((a) => _logTile(a['action_type'], a['details'] ?? {}, a['created_at'], isDark)).toList(),
      ],
    );
  }

  // ── ONGLET 2 : SÉCURITÉ (PRO SOC DESIGN) ──
  Widget _buildSecurityTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── NOUVEAU VISUEL : PROTECTION SHIELD ──
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _dexoBlue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _dexoBlue.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              const Icon(Icons.verified_user_rounded, color: _dexoBlue, size: 40),
              const SizedBox(height: 12),
              const Text("Intégrité du Système", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              const Text("Tous les protocoles sont opérationnels", style: TextStyle(color: Colors.grey, fontSize: 11)),
              const SizedBox(height: 20),

              // Lignes de vérification
              _protectionCheckRow("Chiffrement de la base", "SÉCURISÉ", isDark),
              _protectionCheckRow("Tunnel Agents IA", "ISOLÉ", isDark),
              _protectionCheckRow("Audit Logs", "ACTIF", isDark),
            ],
          ),
        ),

        const SizedBox(height: 35),
        Text("Journal d'Audit (${_recentActions.length})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 15),

        // Liste des logs (utilise la fonction _logTile mise à jour ci-dessous)
        ..._recentActions.take(5).map((a) => _logTile(a['action_type'], a['details'] ?? {}, a['created_at'], isDark)).toList(),
      ],
    );
  }

// Widget utilitaire pour les lignes de check
  Widget _protectionCheckRow(String label, String status, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 14),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const Spacer(),
          Text(status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _dexoBlue)),
        ],
      ),
    );
  }
  Widget _securityMiniCard(String title, String status, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: _dexoBlue, size: 18),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  // ── ONGLET 3 : AGENTS ──
  Widget _buildAgentsTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text("Orchestration des Agents", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 20),
        _agentStatusCard("Hera", "RH AI", "ACTIVE", Icons.person_search, Colors.green, isDark),
        _agentStatusCard("Echo", "Com AI", "STANDBY", Icons.campaign, Colors.orange, isDark),
        _agentStatusCard("Dexo", "Supervisor", "CORE ACTIVE", Icons.layers, _dexoBlue, isDark),
      ],
    );
  }

  Widget _agentStatusCard(String name, String role, String status, IconData icon, Color color, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 22)),
        const SizedBox(width: 15),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text(role, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        ])),
        Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _logTile(String type, Map<String, dynamic> details, String dateStr, bool isDark) {
    // ── LOGIQUE DE TRADUCTION POUR LE CEO ──
    String displayTitle = "";
    IconData icon = Icons.circle;

    if (type == 'absence_alert') {
      String dept = (details['department'] ?? "ÉQUIPE").toString().toUpperCase();
      displayTitle = "ALERTE STAFFING : $dept"; // ✅ Affiche enfin le département
      icon = Icons.campaign_rounded;
    } else if (type == 'contract_renewal') {
      displayTitle = "ONBOARDING : CONTRAT ÉDITÉ";
      icon = Icons.description_rounded;
    } else if (type == 'leave_approved') {
      displayTitle = "PLANNING : CONGÉ VALIDÉ";
      icon = Icons.event_available_rounded;
    } else {
      displayTitle = type.replaceAll('_', ' ').toUpperCase();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: _dexoBlue, size: 16),
          const SizedBox(width: 15),
          Expanded(
              child: Text(
                  displayTitle,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.3)
              )
          ),
          Text(_timeAgo(DateTime.parse(dateStr)), style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }
}