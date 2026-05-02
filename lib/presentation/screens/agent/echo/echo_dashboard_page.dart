import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:e_team/data/services/echo_service.dart';
import 'package:e_team/data/services/api_config.dart';
import 'package:e_team/domain/models/echo_models.dart';
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
  static const violet = Color(0xFF7C3AED);      // Violet accent
  static const neon = Color(0xFF4CAF50);         // Vert pour statut online
  static const textMain = Color(0xFF1A1A1A);     // Gris anthracite
  static const textMuted = Color(0xFF757575);    // Gris moyen
  static const shadow = Color(0x08000000);
  static const softViolet = Color(0xFFF3E8FF);
  static const softBlue = Color(0xFFEFF6FF);// Ombre ultra-légère
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

  bool _loadingEmails = true;

  // Email management from inbox
  List<EmailItem> _emails = [];
  bool _showOnlyUrgent = false;
  bool _showOnlySpam = false;
  int _emailSubTab = 0; // 0 = Recus, 1 = Envoyes

  // Document management
  final TextEditingController _documentController = TextEditingController();
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
                      'ECHO BRAIN',
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
                            'COMMUNICATION AGENT ONLINE',
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
      {'label': 'OVERVIEW', 'icon': Icons.dashboard_rounded},
      {'label': 'MESSAGES', 'icon': Icons.mark_email_unread_rounded},
      {'label': 'POSTS', 'icon': Icons.auto_awesome_rounded},
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
      case 2: return _buildPostsTab();
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

          const SizedBox(height: 24),
          _buildSectionTitle('LATEST COMMUNICATIONS'),
          const SizedBox(height: 16),
          _buildRecentActivityCards(),
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

    final recent = _recentEmails.take(3).toList();

    if (recent.isEmpty) {
      return _buildEmptyState('No recent communications', Icons.inbox_outlined);
    }

    return Column(
      children: recent.map((email) => _buildActivityCard(email)).toList(),
    );
  }

  Widget _buildActivityCard(EmailItem email) {
    final bool isRecruitment = email.subject.toLowerCase().contains('recrutement');
    final bool isApproved = email.subject.toLowerCase().contains('validé');
    final bool isFromHera = email.sender.contains('hera@e-team.com');

    final Color accentColor = isApproved
        ? Colors.green
        : isRecruitment
        ? Colors.orange
        : EchoTheme.violet;

    final IconData icon = isApproved
        ? Icons.check_circle_rounded
        : isRecruitment
        ? Icons.campaign_rounded
        : Icons.mail_rounded;

    final String badge = isApproved
        ? 'APPROVED'
        : email.isUrgent
        ? 'URGENT'
        : 'INFO';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: EchoTheme.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accentColor.withOpacity(0.22),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFromHera ? 'Hera → Echo' : 'Incoming communication',
                  style: GoogleFonts.inter(
                    color: EchoTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email.subject,
                  style: GoogleFonts.inter(
                    color: EchoTheme.textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  email.summary.isNotEmpty
                      ? email.summary
                      : 'Echo processed this communication automatically.',
                  style: GoogleFonts.inter(
                    color: EchoTheme.textMuted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.inter(
                    color: accentColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _formatTime(email.receivedAt),
                style: GoogleFonts.inter(
                  color: EchoTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
    return const SizedBox.shrink();
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7C3AED),
            Color(0xFFA855F7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Social Media Studio',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AI-generated posts, campaigns and engagement tracking',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.82),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.22)),
                ),
                child: Text(
                  '${_posts.length} POSTS',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
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
                if (result == true) {
                  _loadSocialPosts();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: EchoTheme.violet,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.campaign_rounded, size: 19),
                  const SizedBox(width: 8),
                  Text(
                    'Launch Product Campaign',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
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
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  EchoTheme.violet.withOpacity(0.14),
                  EchoTheme.violet.withOpacity(0.06),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 44,
              color: EchoTheme.violet.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'No social posts yet',
            style: GoogleFonts.inter(
              color: EchoTheme.textMain,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a product campaign and Echo will generate posts automatically.',
            style: GoogleFonts.inter(
              color: EchoTheme.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(PostItem post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: EchoTheme.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: EchoTheme.border.withOpacity(0.75), width: 0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.white,
                    size: 23,
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
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatTime(post.createdAt),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: EchoTheme.violet.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'AI POST',
                    style: GoogleFonts.inter(
                      color: EchoTheme.violet,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (post.image != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _buildPostImage(post),
            ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              post.fullContent,
              style: GoogleFonts.inter(
                color: EchoTheme.textMain,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                height: 1.55,
              ),
            ),
          ),

          if (post.platforms.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _buildPlatformBadges(post),
            ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(color: EchoTheme.border.withOpacity(0.7)),
              ),
            ),
            child: Row(
              children: [
                Expanded(child: _buildStatItem('👍', post.stats.likes)),
                Expanded(child: _buildStatItem('💬', post.stats.comments)),
                Expanded(child: _buildStatItem('🔄', post.stats.shares)),
                GestureDetector(
                  onTap: _loadSocialPosts,
                  child: Icon(
                    Icons.refresh_rounded,
                    color: EchoTheme.textMuted,
                    size: 18,
                  ),
                ),
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
    final String imageUrl = '${ApiConfig.baseUrl}${post.image!.url}';

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

}
