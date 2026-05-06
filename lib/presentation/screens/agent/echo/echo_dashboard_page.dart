import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:e_team/data/services/echo_service.dart';
import 'package:e_team/domain/models/echo_models.dart';
import 'package:e_team/presentation/widgets/echo/echo_theme.dart';
import 'package:e_team/presentation/widgets/echo/echo_dashboard_header.dart';
import 'package:e_team/presentation/widgets/echo/echo_dashboard_navigation.dart';
import 'package:e_team/presentation/widgets/echo/echo_overview_tab.dart';
import 'package:e_team/presentation/widgets/echo/echo_messages_tab.dart';
import 'package:e_team/presentation/widgets/echo/echo_posts_tab.dart';

// CLASSES DE DONNÉES
class SocialPost {
  final String platform;
  final String text;
  final String time;

  SocialPost({required this.platform, required this.text, required this.time});
}

class EchoDashboardPage extends StatefulWidget {
  final String? token;
  const EchoDashboardPage({super.key, this.token});

  @override
  State<EchoDashboardPage> createState() => _EchoDashboardPageState();
}

class _EchoDashboardPageState extends State<EchoDashboardPage>
    with TickerProviderStateMixin {
  int _selectedTab = 0;

  // ✅ ANIMATION CONTROLLER POUR PULSATION
  late AnimationController _pulseController;

  // Echo agent stats
  Map<String, dynamic>? _stats;
  List<EmailItem> _recentEmails = [];

  bool _loadingEmails = true;

  // Email management from inbox
  List<EmailItem> _emails = [];
  final bool _showOnlyUrgent = false;
  final bool _showOnlySpam = false;
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
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadDashboardData(),
    );
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
      final result = await EchoService.getMobilePosts(
        token: widget.token,
        limit: 20,
      );
      if (result.success && mounted) {
        setState(() {
          _posts = result.posts; // Use real PostItem objects
          _loadingSocial = false;
        });
      } else {
        setState(() => _loadingSocial = false);
      }
    } catch (_) {
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
        .where(
          (e) =>
              !e.isSpam &&
              e.category != 'auto_reply' &&
              e.category != 'auto_reply_pending' &&
              e.sender != 'echo@e-team.com',
        )
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
      _stats!['totalProcessed'] = localProcessed > apiP ? localProcessed : apiP;
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
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  // 1. PROFESSIONAL HEADER - CLEAN & STATIC
  Widget _buildProfessionalHeader() {
    return EchoDashboardHeader(
      pulseController: _pulseController,
      totalProcessed: _stats?['totalProcessed'] ?? 0,
      alertsCount: _emails.where((e) => e.sender == 'hera@e-team.com').length,
      postsCount: _posts.length,
      onBackPressed: () => Navigator.pop(context),
    );
  }

  // 2. CLEAN PROFESSIONAL NAVIGATION
  Widget _buildCleanNavigation() {
    return EchoDashboardNavigation(
      selectedTab: _selectedTab,
      onTabSelected: (index) => setState(() => _selectedTab = index),
    );
  }

  Widget _buildTabContent() {
    if (!mounted) return Container();

    switch (_selectedTab) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildMessagesTab();
      case 2:
        return _buildPostsTab();
      default:
        return _buildOverviewTab();
    }
  }

  // 3. OVERVIEW TAB - CLEAN PROFESSIONAL LAYOUT
  Widget _buildOverviewTab() {
    return EchoOverviewTab(
      loadingEmails: _loadingEmails,
      recentEmails: _recentEmails,
      buildEmptyState: _buildEmptyState,
      formatTime: _formatTime,
    );
  }

  // --- HELPERS ---
  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(icon, size: 48, color: EchoTheme.textMuted),
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
    return EchoMessagesTab(
      loadingEmails: _loadingEmails,
      emails: _emails,
      showOnlyUrgent: _showOnlyUrgent,
      showOnlySpam: _showOnlySpam,
      emailSubTab: _emailSubTab,
      onSubTabChanged: (index) => setState(() => _emailSubTab = index),
      onMarkAsRead: _markAsRead,
      onReply: _loadAllEmails,
      onAfterReply: _loadStats,
      buildEmptyState: _buildEmptyState,
      token: widget.token,
    );
  }

  // 6. TASKS TAB - ANCIEN CODE SUPPRIMÉ

  // 7. POSTS TAB - NEW SOCIAL MEDIA POSTS
  Widget _buildPostsTab() {
    return EchoPostsTab(
      loadingSocial: _loadingSocial,
      posts: _posts,
      token: widget.token,
      formatTime: _formatTime,
      onLoadSocialPosts: _loadSocialPosts,
      onLaunchCampaign: _loadSocialPosts,
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
}
