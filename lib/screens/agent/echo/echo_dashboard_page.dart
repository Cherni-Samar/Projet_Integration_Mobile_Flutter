import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/echo_service.dart';
import 'echo_email_detail_screen.dart';
import 'product_marketing_screen.dart';

// CLASSES DE DONNÉES
class SocialPost {
  final String platform;
  final String text;
  final String time;

  SocialPost({
    required this.platform,
    required this.text,
    required this.time,
  });
}

// --- PALETTE DE COULEURS LIGHT MODE ---
class EchoTheme {
  static const bg = Color(0xFFFFFFFF);           // Blanc pur
  static const card = Color(0xFFFFFFFF);         // Cartes blanches
  static const border = Color(0xFFE0E0E0);       // Bordure grise légère
  static const violet = Color(0xFF9C27B0);       // Violet accent
  static const neon = Color(0xFF4CAF50);         // Vert pour statut online
  static const textMain = Color(0xFF1A1A1A);     // Gris anthracite
  static const textMuted = Color(0xFF757575);    // Gris moyen
  static const shadow = Color(0x08000000);       // Ombre ultra-légère
}

class EchoDashboardPage extends StatefulWidget {
  final String? token;
  const EchoDashboardPage({super.key, this.token});

  @override
  State<EchoDashboardPage> createState() => _EchoDashboardPageState();
}

class _EchoDashboardPageState extends State<EchoDashboardPage> with TickerProviderStateMixin {

  int _selectedTab = 0;

  // ✅ ANIMATION CONTROLLER POUR PULSATION
  late AnimationController _pulseController;

  // Echo agent stats
  Map<String, dynamic>? _stats;
  List<EmailItem> _recentEmails = [];
  List<DocumentItem> _recentDocuments = [];

  bool _loadingEmails = true;
  bool _loadingDocuments = true;

  // Email management from inbox
  List<EmailItem> _emails = [];
  bool _showOnlyUrgent = false;
  bool _showOnlySpam = false;
  int _emailSubTab = 0; // 0 = Recus, 1 = Envoyes

  // Document management
  final TextEditingController _documentController = TextEditingController();
  DocumentClassification? _currentClassification;
  bool _isClassifying = false;
  bool _isSaving = false;

  // Cyber animations - SUPPRIMÉES pour stabilité
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    
    // ✅ INITIALISER LE CONTROLLER DE PULSATION
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _loadDashboardData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadDashboardData());
  }

  @override
  void dispose() {
    // ✅ DISPOSER LE CONTROLLER
    _pulseController.dispose();
    _refreshTimer?.cancel();
    _documentController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    _loadStats();
    _loadRecentEmails();
    _loadRecentDocuments();
    _loadAllEmails();
    _loadSocialPosts(); // Add this line
  }

  // ═══════════════════════════════════════════════════════════════
  // 📱 MOBILE POSTS MANAGEMENT METHODS
  // ═══════════════════════════════════════════════════════════════

  List<PostItem> _posts = []; // Change from SocialPost to PostItem
  bool _loadingSocial = false;

  Future<void> _loadSocialPosts() async {
    setState(() => _loadingSocial = true);
    try {
      final result = await EchoService.getMobilePosts(token: widget.token, limit: 20);
      if (result.success && mounted) {
        setState(() {
          _posts = result.posts; // Use real PostItem objects
          _loadingSocial = false;
        });
      } else {
        setState(() => _loadingSocial = false);
      }
    } catch (e) {
      print('❌ Error loading social posts: $e');
      setState(() => _loadingSocial = false);
    }
  }



  Future<void> _loadStats() async {
    try {
      final result = await EchoService.getStats(token: widget.token);
      if (!mounted) return;
      setState(() {
        _stats = {
          'totalProcessed': result.totalProcessed,
          'spamBlocked': result.spamBlocked,
          'uptime': result.uptime,
        };
      });
      _applyEmailDerivedOverviewStats();
    } catch (e) {
      // Error handling without using _loadingStats
    }
  }

  /// Messages reçus utiles (hors spam, hors réponses auto Echo) pour combler l'API stats si elle renvoie 0.
  int _countInboxMessagesForStats() {
    return _emails
        .where((e) =>
    !e.isSpam &&
        e.category != 'auto_reply' &&
        e.category != 'auto_reply_pending' &&
        e.sender != 'echo@e-team.com')
        .length;
  }

  void _applyEmailDerivedOverviewStats() {
    if (!mounted) return;
    final localProcessed = _countInboxMessagesForStats();
    final localSpam = _emails.where((e) => e.isSpam).length;
    setState(() {
      _stats ??= {};
      int asInt(dynamic v) {
        if (v is int) return v;
        if (v is num) return v.toInt();
        return int.tryParse('$v') ?? 0;
      }

      final apiP = asInt(_stats!['totalProcessed']);
      final apiS = asInt(_stats!['spamBlocked']);
      _stats!['totalProcessed'] =
      localProcessed > apiP ? localProcessed : apiP;
      _stats!['spamBlocked'] = localSpam > apiS ? localSpam : apiS;
    });
  }

  Future<void> _loadAllEmails() async {
    setState(() {
      _loadingEmails = true;
    });

    final emailsResponse = await EchoService.getEmails(token: widget.token);

    if (!mounted) return;

    setState(() {
      if (emailsResponse.success) {
        _emails = emailsResponse.emails;
      }
      _loadingEmails = false;
    });
    _applyEmailDerivedOverviewStats();
  }

  Future<void> _loadRecentEmails() async {
    setState(() => _loadingEmails = true);
    try {
      final result = await EchoService.getEmails(token: widget.token);
      if (result.success) {
        setState(() {
          _recentEmails = result.emails.take(5).toList();
          _loadingEmails = false;
        });
      } else {
        setState(() => _loadingEmails = false);
      }
    } catch (e) {
      setState(() => _loadingEmails = false);
    }
  }

  Future<void> _loadRecentDocuments() async {
    setState(() => _loadingDocuments = true);
    try {
      // Load documents from different categories
      final categories = ['Commercial', 'Finance', 'Juridique', 'Marketing', 'RH', 'Technique'];
      List<DocumentItem> allDocs = [];

      for (String category in categories) {
        final result = await EchoService.getDocumentsByCategory(
          category: category,
          token: widget.token,
        );
        if (result.success) {
          allDocs.addAll(result.documents);
        }
      }

      // Sort by creation date and take the 5 most recent
      allDocs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _recentDocuments = allDocs.take(5).toList();
        _loadingDocuments = false;
      });
    } catch (e) {
      setState(() => _loadingDocuments = false);
    }
  }

  // Document classification methods
  Future<void> _classifyDocument() async {
    if (_documentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir du contenu à classifier')),
      );
      return;
    }

    setState(() {
      _isClassifying = true;
      _currentClassification = null;
    });

    try {
      final response = await EchoService.classifyDocument(
        content: _documentController.text.trim(),
        token: widget.token,
      );

      if (response.success && response.classification != null) {
        setState(() {
          _currentClassification = response.classification;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${response.error ?? 'Classification échouée'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() {
        _isClassifying = false;
      });
    }
  }

  Future<void> _saveDocument() async {
    if (_currentClassification == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez d\'abord classifier le document')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final response = await EchoService.saveClassifiedDocument(
        content: _documentController.text.trim(),
        classification: _currentClassification!.toJson(),
        token: widget.token,
      );

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Document sauvegardé avec succès'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear the form
        _documentController.clear();
        setState(() {
          _currentClassification = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${response['error'] ?? 'Sauvegarde échouée'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // --- WIDGETS DE CONSTRUCTION ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EchoTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildProfessionalHeader(),
            _buildCleanNavigation(),
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  // 1. PROFESSIONAL HEADER - CLEAN & STATIC
  Widget _buildProfessionalHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: EchoTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EchoTheme.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: EchoTheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header avec bouton retour
          Row(
            children: [
              // Bouton de retour
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: EchoTheme.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: EchoTheme.border, width: 0.5),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                  color: EchoTheme.textMain,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 16),
              _buildStaticAvatar(),
              const SizedBox(width: 20),
              Expanded( // Garde le Expanded ici
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ECHO COMMAND CENTER',
                      style: GoogleFonts.inter(color: EchoTheme.textMain, fontSize: 18, fontWeight: FontWeight.bold),
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
                                color: Color(0xFFFF00DD).withOpacity(0.4 + 0.6 * _pulseController.value),
                                shape: BoxShape.circle,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'AUTONOMOUS COMMUNICATION ACTIVE',
                            style: GoogleFonts.inter(
                              color: Color(0xFF9C27B0),
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
          const SizedBox(height: 20),
          _buildStaticStatusBar(),
        ],
      ),
    );
  }

  Widget _buildStaticAvatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: EchoTheme.violet, width: 2),
        boxShadow: [
          BoxShadow(
            color: EchoTheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Image.asset(
          'assets/images/voxi.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: EchoTheme.violet.withOpacity(0.1),
              ),
              child: Icon(
                Icons.psychology,
                color: EchoTheme.violet,
                size: 24,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStaticOnlineIndicator() {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: EchoTheme.neon,
      ),
    );
  }

  Widget _buildStaticStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: EchoTheme.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EchoTheme.border, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _buildStatusMetric(
              'MESSAGES',
              '${_stats?['totalProcessed'] ?? 0}',
              Icons.email_outlined,
              EchoTheme.violet,
            ),
          ),
          Container(width: 1, height: 30, color: EchoTheme.border),
          Expanded(
            child: _buildStatusMetric(
              'SPAM',
              '${_stats?['spamBlocked'] ?? 0}',
              Icons.shield_outlined,
              Colors.redAccent,
            ),
          ),
          Container(width: 1, height: 30, color: EchoTheme.border),
          Expanded(
            child: _buildStatusMetric(
              'ALERTS',
              '${_emails.where((e) => e.sender == 'hera@e-team.com').length}',
              Icons.timeline_outlined,
              Colors.orangeAccent,
            ),
          ),
          Container(width: 1, height: 30, color: EchoTheme.border),
          Expanded(
            child: _buildStatusMetric(
              'POSTS',
              '${_posts.length}',
              Icons.article_outlined,
              EchoTheme.violet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            color: EchoTheme.textMain,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            color: EchoTheme.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // 2. CLEAN PROFESSIONAL NAVIGATION
  Widget _buildCleanNavigation() {
    final tabs = [
      {'label': 'OVERVIEW', 'icon': Icons.dashboard_outlined},
      {'label': 'MESSAGES', 'icon': Icons.email_outlined},
      {'label': 'LOGS', 'icon': Icons.timeline_outlined},
      {'label': 'POSTS', 'icon': Icons.article_outlined}, // NEW POSTS TAB
    ];

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFB57BFF),
            Color(0xFFA855F7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFB57BFF).withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = _selectedTab == index;

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.25)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: Colors.white.withOpacity(0.3), width: 0.5)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tab['icon'] as IconData,
                        color: Colors.white,
                        size: isSelected ? 20 : 18,
                      ),
                      const SizedBox(height: 4),
                      if (isSelected)
                        Text(
                          tab['label'] as String,
                          style: GoogleFonts.inter(
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
                            color: Colors.white.withOpacity(0.4),
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

  Widget _buildTabContent() {
    if (!mounted) return Container();

    switch (_selectedTab) {
      case 0: return _buildOverviewTab();
      case 1: return _buildMessagesTab();
      case 2: return _buildAutomationLogsTab();
      case 3: return _buildPostsTab(); // NEW POSTS TAB
      default: return _buildOverviewTab();
    }
  }

  // 3. OVERVIEW TAB - CLEAN PROFESSIONAL LAYOUT
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('OPERATIONAL METRICS'),
          const SizedBox(height: 16),
          _buildCleanStats(),
          const SizedBox(height: 24),
          _buildSectionTitle('RECENT ACTIVITY'),
          const SizedBox(height: 16),
          _buildRecentActivityCards(),
        ],
      ),
    );
  }

  Widget _buildCleanStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'MESSAGES\nPROCESSED',
            '${_stats?['totalProcessed'] ?? 0}',
            Icons.analytics_outlined,
            EchoTheme.violet,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'SPAM\nBLOCKED',
            '${_stats?['spamBlocked'] ?? 0}',
            Icons.shield_outlined,
            Colors.redAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EchoTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EchoTheme.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: EchoTheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  color: EchoTheme.textMain,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.inter(
                  color: EchoTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }




  Widget _buildRecentActivityCards() {
    if (_loadingEmails) {
      return const Center(
        child: CircularProgressIndicator(color: EchoTheme.violet),
      );
    }

    if (_recentEmails.isEmpty) {
      return _buildEmptyState('No recent activity', Icons.inbox_outlined);
    }

    return Column(
      children: _recentEmails.take(3).map((email) => _buildActivityCard(email)).toList(),
    );
  }

  Widget _buildActivityCard(EmailItem email) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EchoTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EchoTheme.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: EchoTheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: _getSenderColor(email.sender),
            child: Text(
              email.sender[0].toUpperCase(),
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email.subject,
                  style: GoogleFonts.inter(
                    color: EchoTheme.textMain,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email.summary,
                  style: GoogleFonts.inter(
                    color: EchoTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (email.isUrgent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'URGENT',
                style: GoogleFonts.inter(
                  color: Colors.redAccent,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }









  // --- HELPERS ---
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        color: EchoTheme.violet,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: EchoTheme.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.inter(
              color: EchoTheme.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 5. MESSAGES TAB
  Widget _buildMessagesTab() {
    return Column(
      children: [
        _buildEmailControls(),
        _buildEmailSubTabs(),
        Expanded(
          child: _buildEmailList(),
        ),
      ],
    );
  }

  Widget _buildEmailControls() {
    final urgentCount = _emails.where((e) => e.isUrgent && !e.isRead && e.sender != 'echo@e-team.com').length;
    final spamCount = _emails.where((e) => e.isSpam).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EchoTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EchoTheme.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: EchoTheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    'URGENT',
                    urgentCount,
                    _showOnlyUrgent,
                    Colors.redAccent,
                        () {
                      setState(() {
                        _showOnlyUrgent = !_showOnlyUrgent;
                        if (_showOnlyUrgent) _showOnlySpam = false;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'SPAM',
                    spamCount,
                    _showOnlySpam,
                    Colors.orangeAccent,
                        () {
                      setState(() {
                        _showOnlySpam = !_showOnlySpam;
                        if (_showOnlySpam) _showOnlyUrgent = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: _loadAllEmails,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: EchoTheme.bg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: EchoTheme.border, width: 0.5),
              ),
              child: Icon(
                Icons.refresh,
                color: EchoTheme.textMain,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count, bool isActive, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color : EchoTheme.border,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: isActive ? color : EchoTheme.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toString(),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 8,
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

  Widget _buildEmailSubTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: EchoTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EchoTheme.border, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _emailSubTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _emailSubTab == 0 ? EchoTheme.violet : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '📥 RECEIVED',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: _emailSubTab == 0 ? Colors.white : EchoTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _emailSubTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _emailSubTab == 1 ? EchoTheme.violet : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '📤 SENT',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: _emailSubTab == 1 ? Colors.white : EchoTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailList() {
    if (_loadingEmails) {
      return const Center(
        child: CircularProgressIndicator(color: EchoTheme.violet),
      );
    }

    final receivedEmails = _emails.where((email) {
      if (_showOnlyUrgent && !email.isUrgent) return false;
      if (_showOnlySpam) {
        if (!email.isSpam) return false;
      } else if (email.isSpam) {
        return false;
      }
      if (email.category == 'auto_reply' || email.category == 'auto_reply_pending') return false;
      if (email.sender == 'echo@e-team.com') return false;
      return true;
    }).toList();

    final sentEmails = _emails.where((email) {
      if (email.sender == 'echo@e-team.com') return true;
      if (email.category == 'auto_reply' || email.category == 'auto_reply_pending') return true;
      return false;
    }).toList();

    final emailsToShow = _emailSubTab == 0 ? receivedEmails : sentEmails;

    if (emailsToShow.isEmpty) {
      return _buildEmptyState(
        _emailSubTab == 0 ? 'No received emails' : 'No sent emails',
        Icons.inbox_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: emailsToShow.length,
      itemBuilder: (context, index) => _buildEmailCard(emailsToShow[index]),
    );
  }

  Widget _buildEmailCard(EmailItem email) {
    final bool isFromHera = email.sender.contains('hera@e-team.com');
    final bool isUnread = !email.isRead;

    return GestureDetector(
      // Dans _buildEmailCard, remplace la partie onTap :
      onTap: () async {
        await _markAsRead(email);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EchoEmailDetailScreen(
                email: email,
                token: widget.token,
                // ✅ AJOUTE CES DEUX LIGNES POUR RÉPARER L'ERREUR
                isPending: false,
                remainingMinutes: 0,
                onReply: _loadAllEmails,
                onAfterReply: _loadStats,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Fond spécial si c'est une alerte de Hera
          color: isFromHera ? const Color(0xFFFBF4FF) : EchoTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isFromHera ? EchoTheme.violet.withOpacity(0.3) : (email.isUrgent ? Colors.redAccent.withOpacity(0.3) : EchoTheme.border),
              width: isFromHera ? 1 : 0.5
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: isFromHera ? EchoTheme.violet : _getSenderColor(email.sender),
              child: Icon(isFromHera ? Icons.bolt : Icons.person, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFromHera ? "INTERNAL: HERA RH" : email.sender,
                    style: TextStyle(fontWeight: FontWeight.bold, color: isFromHera ? EchoTheme.violet : EchoTheme.textMain),
                  ),
                  Text(email.subject, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  // BADGE D'INTELLIGENCE ECHO
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: EchoTheme.violet.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text("Echo detected: ${email.category}", style: TextStyle(fontSize: 9, color: EchoTheme.violet, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            if (isUnread) const Icon(Icons.circle, size: 10, color: EchoTheme.violet),
          ],
        ),
      ),
    );
  }

  // 6. AUTOMATION LOGS TAB - NOUVEAU PIPELINE DYNAMIQUE
  Widget _buildAutomationLogsTab() {
    return Container(
      color: const Color(0xFFFFFFFF), // Fond blanc pur
      child: Column(
        children: [
          _buildAutomationHeader(),
          Expanded(
            child: _buildDynamicAutomationLogs(),
          ),
        ],
      ),
    );
  }

  Widget _buildAutomationHeader() {
    final heraEmails = _emails.where((email) => email.sender == 'hera@e-team.com').length;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EchoTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EchoTheme.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: EchoTheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: EchoTheme.violet.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.timeline_outlined,
              color: EchoTheme.violet,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AUTOMATION PIPELINE',
                  style: GoogleFonts.inter(
                    color: EchoTheme.textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Real-time Echo activity logs',
                  style: GoogleFonts.inter(
                    color: EchoTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: EchoTheme.violet.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: EchoTheme.violet.withOpacity(0.3), width: 0.5),
            ),
            child: Text(
              '$heraEmails ALERTS',
              style: GoogleFonts.inter(
                color: EchoTheme.violet,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicAutomationLogs() {
    // Filtrer uniquement les emails de Hera
    final heraEmails = _emails.where((email) => email.sender == 'hera@e-team.com').toList();
    
    if (heraEmails.isEmpty) {
      return _buildEmptyAutomationState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: heraEmails.length,
      itemBuilder: (context, index) => _buildAutomationPipelineCard(heraEmails[index]),
    );
  }

  Widget _buildEmptyAutomationState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: EchoTheme.violet.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.timeline_outlined,
              size: 48,
              color: EchoTheme.violet.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No automation logs',
            style: GoogleFonts.inter(
              color: EchoTheme.textMuted,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Waiting for Hera alerts to trigger automation',
            style: GoogleFonts.inter(
              color: EchoTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAutomationPipelineCard(EmailItem email) {
    // Extraire le département du sujet
    final department = _extractDepartmentFromSubject(email.subject);
    
    // Déterminer l'état des étapes - Logique réaliste du workflow Echo
    final step1Complete = true; // Toujours vrai car l'email est présent
    
    // Step 2 : Echo génère automatiquement du contenu pour toutes les alertes Hera
    // Considéré comme complété après quelques minutes (simulation)
    final emailAge = DateTime.now().difference(email.receivedAt).inMinutes;
    final step2Complete = emailAge >= 2; // Complété après 2 minutes
    
    // Step 3 : Réponse envoyée à Hera - Logique basée sur l'âge de l'email
    // Simulation : Echo répond automatiquement après 5 minutes
    final step3Complete = emailAge >= 5 || email.isRead || email.category.contains('auto_reply');
    
    /* 
    LOGIQUE DU PIPELINE ECHO :
    1. TRIGGER : Alerte reçue de Hera → Toujours ✅
    2. AI ACTION : Echo génère du contenu → ✅ après 2min (simulation temps de traitement)
    3. FEEDBACK : Echo répond à Hera → ✅ quand email lu ou auto_reply envoyé
    */
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EchoTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EchoTheme.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: EchoTheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header du pipeline
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getDepartmentColor(department).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getDepartmentIcon(department),
                  color: _getDepartmentColor(department),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HERA ALERT • ${department.toUpperCase()}',
                      style: GoogleFonts.inter(
                        color: EchoTheme.textMain,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(email.receivedAt),
                      style: GoogleFonts.inter(
                        color: EchoTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: step3Complete ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  step3Complete ? 'COMPLETED' : 'PROCESSING',
                  style: GoogleFonts.inter(
                    color: step3Complete ? Colors.green : Colors.orange,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Pipeline Steps
          _buildPipelineStep(
            1,
            'TRIGGER',
            'Hera Alert Received',
            step1Complete,
            false,
            Icons.notification_important_outlined,
          ),
          _buildPipelineConnector(),
          _buildPipelineStep(
            2,
            'AI ACTION',
            step2Complete ? 'Content Generated ✓' : 'Generating LinkedIn Post...',
            step2Complete,
            !step2Complete && step1Complete,
            Icons.auto_awesome_outlined,
          ),
          _buildPipelineConnector(),
          _buildPipelineStep(
            3,
            'FEEDBACK',
            step3Complete ? 'Reply Sent ✓' : 'Preparing Response...',
            step3Complete,
            !step3Complete && step2Complete,
            Icons.reply_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineStep(int stepNumber, String type, String description, bool isComplete, bool isProcessing, IconData icon) {
    Color stepColor;
    Widget stepIcon;
    
    if (isComplete) {
      stepColor = Colors.green;
      stepIcon = const Icon(Icons.check_circle, color: Colors.green, size: 20);
    } else if (isProcessing) {
      stepColor = EchoTheme.violet;
      stepIcon = SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(EchoTheme.violet),
        ),
      );
    } else {
      stepColor = EchoTheme.textMuted;
      stepIcon = Icon(Icons.radio_button_unchecked, color: EchoTheme.textMuted, size: 20);
    }
    
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: stepColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: stepColor.withOpacity(0.3)),
          ),
          child: Center(child: stepIcon),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'STEP $stepNumber',
                    style: GoogleFonts.inter(
                      color: stepColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: stepColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      type,
                      style: GoogleFonts.inter(
                        color: stepColor,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.inter(
                  color: EchoTheme.textMain,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Icon(
          icon,
          color: stepColor.withOpacity(0.7),
          size: 16,
        ),
      ],
    );
  }

  Widget _buildPipelineConnector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Container(
            width: 2,
            height: 20,
            decoration: BoxDecoration(
              color: EchoTheme.border,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                color: EchoTheme.border,
                borderRadius: BorderRadius.circular(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods pour le pipeline
  String _extractDepartmentFromSubject(String subject) {
    final lowerSubject = subject.toLowerCase();
    if (lowerSubject.contains('tech') || lowerSubject.contains('développeur') || lowerSubject.contains('developer')) {
      return 'Tech';
    } else if (lowerSubject.contains('design') || lowerSubject.contains('ui') || lowerSubject.contains('ux')) {
      return 'Design';
    } else if (lowerSubject.contains('marketing') || lowerSubject.contains('commercial')) {
      return 'Marketing';
    } else if (lowerSubject.contains('rh') || lowerSubject.contains('recrutement') || lowerSubject.contains('hr')) {
      return 'RH';
    } else if (lowerSubject.contains('finance') || lowerSubject.contains('comptable')) {
      return 'Finance';
    }
    return 'General';
  }

  Color _getDepartmentColor(String department) {
    switch (department) {
      case 'Tech': return Colors.blue;
      case 'Design': return Colors.purple;
      case 'Marketing': return Colors.orange;
      case 'RH': return Colors.green;
      case 'Finance': return Colors.teal;
      default: return EchoTheme.violet;
    }
  }

  IconData _getDepartmentIcon(String department) {
    switch (department) {
      case 'Tech': return Icons.code_outlined;
      case 'Design': return Icons.palette_outlined;
      case 'Marketing': return Icons.campaign_outlined;
      case 'RH': return Icons.people_outline;
      case 'Finance': return Icons.account_balance_outlined;
      default: return Icons.work_outline;
    }
  }

  // 6. TASKS TAB - ANCIEN CODE SUPPRIMÉ
  
  // 7. POSTS TAB - NEW SOCIAL MEDIA POSTS
  Widget _buildPostsTab() {
    return Container(
      color: const Color(0xFFFFFFFF),
      child: Column(
        children: [
          _buildPostsHeader(),
          Expanded(
            child: _buildPostsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EchoTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EchoTheme.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: EchoTheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: EchoTheme.violet.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.article_outlined,
                  color: EchoTheme.violet,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SOCIAL MEDIA POSTS',
                      style: GoogleFonts.inter(
                        color: EchoTheme.textMain,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Automated LinkedIn & Mastodon posts',
                      style: GoogleFonts.inter(
                        color: EchoTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3), width: 0.5),
                ),
                child: Text(
                  'ACTIVE',
                  style: GoogleFonts.inter(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Product Marketing Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductMarketingScreen(token: widget.token),
                  ),
                );
                // Refresh posts if campaign was started
                if (result == true) {
                  _loadSocialPosts();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: EchoTheme.violet,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Product Marketing Setup',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    if (_loadingSocial) {
      return const Center(
        child: CircularProgressIndicator(color: EchoTheme.violet),
      );
    }

    if (_posts.isEmpty) {
      return _buildEmptyPostsState();
    }

    return RefreshIndicator(
      onRefresh: _loadSocialPosts,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _posts.length,
        itemBuilder: (context, index) => _buildPostCard(_posts[index]),
      ),
    );
  }

  Widget _buildEmptyPostsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: EchoTheme.violet.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.article_outlined,
              size: 48,
              color: EchoTheme.violet.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: GoogleFonts.inter(
              color: EchoTheme.textMuted,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Automated posts will appear here',
            style: GoogleFonts.inter(
              color: EchoTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(PostItem post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EchoTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EchoTheme.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: EchoTheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: EchoTheme.violet.withOpacity(0.1),
                child: const Text(
                  'E',
                  style: TextStyle(
                    color: EchoTheme.violet,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Echo Agent',
                      style: GoogleFonts.inter(
                        color: EchoTheme.textMain,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _formatTime(post.createdAt),
                      style: GoogleFonts.inter(
                        color: EchoTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Post content
          Text(
            post.fullContent,
            style: GoogleFonts.inter(
              color: EchoTheme.textMain,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          
          // AI-generated image
          if (post.image != null) _buildPostImage(post),
          
          // Platform badges (clickable)
          if (post.platforms.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildPlatformBadges(post),
          ],
          
          const SizedBox(height: 16),
          
          // Engagement stats
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: EchoTheme.bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: EchoTheme.border, width: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('👍', post.stats.likes),
                Container(width: 1, height: 20, color: EchoTheme.border),
                _buildStatItem('💬', post.stats.comments),
                Container(width: 1, height: 20, color: EchoTheme.border),
                _buildStatItem('🔄', post.stats.shares),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage(PostItem post) {
    if (post.image == null || post.image!.url.isEmpty) {
      return const SizedBox.shrink();
    }

    // Construct full image URL
    const String baseUrl = 'http://10.0.2.2:3000'; // Android emulator
    final String imageUrl = '$baseUrl${post.image!.url}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: EchoTheme.violet,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Image badge (AI-generated or Original)
        if (post.image!.type == 'ai-generated')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, size: 14, color: Colors.purple),
                const SizedBox(width: 4),
                Text(
                  'AI Generated',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.purple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPlatformBadges(PostItem post) {
    return Wrap(
      spacing: 8,
      children: post.platforms.map((platform) {
        return InkWell(
          onTap: () => _openPostUrl(platform.url),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: platform.name == 'mastodon' 
                  ? Colors.purple.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: platform.name == 'mastodon' 
                    ? Colors.purple
                    : Colors.blue,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  platform.icon,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
                Text(
                  platform.name.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: platform.name == 'mastodon' 
                        ? Colors.purple
                        : Colors.blue,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.open_in_new,
                  size: 14,
                  color: platform.name == 'mastodon' 
                      ? Colors.purple
                      : Colors.blue,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Method to open URL
  Future<void> _openPostUrl(String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post URL not available')),
      );
      return;
    }

    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open post URL')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening URL: $e')),
      );
    }
  }

  Widget _buildStatItem(String emoji, int count) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(
          count.toString(),
          style: GoogleFonts.inter(
            color: EchoTheme.textMain,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // 6. TASKS TAB - ANCIEN CODE SUPPRIMÉ
  // ═══════════════════════════════════════════════════════════════
  // 🔧 HELPER METHODS
  // ═══════════════════════════════════════════════════════════════

  Future<void> _markAsRead(EmailItem email) async {
    if (email.isRead) return;
    final success = await EchoService.markAsRead(email.id, token: widget.token);
    if (success && mounted) {
      setState(() {
        final index = _emails.indexWhere((e) => e.id == email.id);
        if (index != -1) {
          _emails[index] = email.copyWith(isRead: true);
        }
      });
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'now';
  }

  Color _getSenderColor(String sender) {
    final colors = [
      Colors.blueAccent,
      EchoTheme.neon,
      Colors.orangeAccent,
      EchoTheme.violet,
      Colors.tealAccent,
      Colors.pinkAccent,
      Colors.indigoAccent
    ];
    return colors[sender.length % colors.length];
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Commercial': return Colors.blueAccent;
      case 'Finance': return EchoTheme.neon;
      case 'Juridique': return Colors.redAccent;
      case 'Marketing': return Colors.orangeAccent;
      case 'RH': return EchoTheme.violet;
      case 'Technique': return Colors.tealAccent;
      default: return EchoTheme.textMuted;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Commercial': return Icons.business;
      case 'Finance': return Icons.account_balance;
      case 'Juridique': return Icons.gavel;
      case 'Marketing': return Icons.campaign;
      case 'RH': return Icons.people;
      case 'Technique': return Icons.engineering;
      default: return Icons.folder;
    }
  }
}