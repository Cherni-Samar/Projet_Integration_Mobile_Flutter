import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../services/echo_service.dart';
import '../agent_communication_screen.dart';
import 'echo_document_category_page.dart';
import 'echo_email_detail_screen.dart';

class EchoDashboardPage extends StatefulWidget {
  final String? token;

  const EchoDashboardPage({super.key, this.token});

  @override
  State<EchoDashboardPage> createState() => _EchoDashboardPageState();
}

class _EchoDashboardPageState extends State<EchoDashboardPage>
    with SingleTickerProviderStateMixin {

  int _selectedTab = 0;
  
  // Echo agent stats
  Map<String, dynamic>? _stats;
  List<EmailItem> _recentEmails = [];
  List<DocumentItem> _recentDocuments = [];
  
  bool _loadingStats = true;
  bool _loadingEmails = true;
  bool _loadingDocuments = true;
  
  // Email management from inbox
  List<EmailItem> _emails = [];
  List<PendingItem> _pending = [];
  bool _showOnlyUrgent = false;
  bool _showOnlySpam = false;
  int _emailSubTab = 0; // 0 = Recus, 1 = Envoyes
  String? _errorMessage;
  
  // Document management
  final TextEditingController _documentController = TextEditingController();
  DocumentClassification? _currentClassification;
  bool _isClassifying = false;
  bool _isSaving = false;

  // Task management
  List<TaskItem> _tasks = [];
  List<TaskItem> _todoTasks = [];
  List<TaskItem> _inProgressTasks = [];
  List<TaskItem> _completedTasks = [];
  List<TaskItem> _overdueTasks = [];
  TaskStats _taskStats = TaskStats.empty();
  bool _loadingTasks = true;
  String _selectedTaskFilter = 'all'; // all, todo, in_progress, completed, overdue

  late AnimationController _pulseController;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadDashboardData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadDashboardData());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _refreshTimer?.cancel();
    _documentController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    _loadStats();
    _loadRecentEmails();
    _loadRecentDocuments();
    _loadAllEmails(); // Load all emails for the Messages tab
    _loadTasks(); // Load tasks for the Tasks tab
  }

  Future<void> _loadStats() async {
    setState(() => _loadingStats = true);
    try {
      final result = await EchoService.getStats(token: widget.token);
      if (result.success ||
          result.totalProcessed > 0 ||
          result.spamBlocked > 0) {
        setState(() {
          _stats = {
            'totalProcessed': result.totalProcessed,
            'spamBlocked': result.spamBlocked,
            'uptime': result.uptime,
          };
          _loadingStats = false;
        });
      } else {
        setState(() => _loadingStats = false);
      }
    } catch (e) {
      setState(() => _loadingStats = false);
    }
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

  Future<void> _loadTasks() async {
    setState(() => _loadingTasks = true);
    try {
      final result = await EchoService.getTasks(token: widget.token);
      if (result.success && mounted) {
        setState(() {
          _tasks = result.tasks;
          _todoTasks = result.groupedTasks['todo'] ?? [];
          _inProgressTasks = result.groupedTasks['in_progress'] ?? [];
          _completedTasks = result.groupedTasks['completed'] ?? [];
          _overdueTasks = result.overdueTasks;
          _taskStats = result.stats;
          _loadingTasks = false;
        });
      } else {
        setState(() => _loadingTasks = false);
      }
    } catch (e) {
      setState(() => _loadingTasks = false);
    }
  }

  Future<void> _updateTaskStatus(String taskId, String newStatus) async {
    try {
      final result = await EchoService.updateTaskStatus(
        taskId: taskId,
        status: newStatus,
        token: widget.token,
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Tâche mise à jour'),
            backgroundColor: Colors.green,
          ),
        );
        _loadTasks(); // Reload tasks
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['error'] ?? "Erreur de mise à jour"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      final result = await EchoService.deleteTask(
        taskId: taskId,
        token: widget.token,
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Tâche supprimée'),
            backgroundColor: Colors.green,
          ),
        );
        _loadTasks(); // Reload tasks
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['error'] ?? "Erreur de suppression"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _loadAllEmails() async {
    setState(() {
      _loadingEmails = true;
      _errorMessage = null;
    });

    final emailsResponse = await EchoService.getEmails(token: widget.token);
    final pendingResponse = await EchoService.getPending(token: widget.token);

    if (emailsResponse.success && mounted) {
      setState(() {
        _emails = emailsResponse.emails;
        _pending = pendingResponse.pending;
        _loadingEmails = false;
      });
    } else if (mounted) {
      setState(() {
        _errorMessage = emailsResponse.error ?? 'Erreur de chargement';
        _loadingEmails = false;
      });
    }
  }

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

  Future<void> _deleteEmail(EmailItem email) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Supprimer "${email.subject}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await EchoService.deleteEmail(email.id, token: widget.token);
      if (success && mounted) {
        setState(() {
          _emails.removeWhere((e) => e.id == email.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email supprimé')));
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 📄 DOCUMENT CLASSIFICATION METHODS (from EchoInboxScreen)
  // ═══════════════════════════════════════════════════════════════

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(isDark),
            
            // Tab Navigation
            _buildTabNavigation(isDark),
            
            // Content
            Expanded(
              child: _buildTabContent(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF9C27B0),
            const Color(0xFF673AB7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9C27B0).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(56, 10, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Echo Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/images/voxi.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.purple.shade300, Colors.purple.shade600],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.psychology,
                            color: Colors.white,
                            size: 30,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Echo Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Echo Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Message Analysis Agent',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                                SizedBox(width: 4),
                                Text(
                                  'Active',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
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

                // Action Buttons
                Column(
                  children: [
                    // Send to Hera Button
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AgentCommunicationScreen(
                                token: widget.token,
                                fromAgent: 'echo',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 22,
                        ),
                        tooltip: 'Envoyer à Hera',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: SafeArea(
              top: false,
              bottom: false,
              left: false,
              right: false,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.black26,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Retour',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          _buildTabButton('📊 Aperçu', 0, isDark),
          _buildTabButton('📧 Messages', 1, isDark),
          _buildTabButton('📄 Documents', 2, isDark),
          _buildTabButton('📋 Tâches', 3, isDark),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index, bool isDark) {
    final isSelected = _selectedTab == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected 
                ? const Color(0xFF9C27B0)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected 
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black54),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(bool isDark) {
    switch (_selectedTab) {
      case 0:
        return _buildOverviewTab(isDark);
      case 1:
        return _buildMessagesTab(isDark);
      case 2:
        return _buildDocumentsTab(isDark);
      case 3:
        return _buildTasksTab(isDark);
      default:
        return _buildOverviewTab(isDark);
    }
  }

  Widget _buildOverviewTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Messages traités',
                  _stats?['totalProcessed']?.toString() ?? '0',
                  Icons.analytics,
                  Colors.blue,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Spam bloqués',
                  _stats?['spamBlocked']?.toString() ?? '0',
                  Icons.shield,
                  Colors.red,
                  isDark,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          _buildQuickActions(isDark),
          
          const SizedBox(height: 24),
          
          // Recent Activity
          _buildSectionHeader('Activité récente', isDark),
          const SizedBox(height: 12),
          
          if (_loadingEmails)
            const Center(child: CircularProgressIndicator())
          else if (_recentEmails.isEmpty)
            _buildEmptyState('Aucune activité récente', Icons.inbox, isDark)
          else
            ..._recentEmails.take(3).map((email) => _buildActivityCard(email, isDark)),
        ],
      ),
    );
  }

  Widget _buildMessagesTab(bool isDark) {
    final receivedEmails = _emails.where((email) {
      if (_showOnlyUrgent && !email.isUrgent) return false;
      if (_showOnlySpam && !email.isSpam) return false;
      if (email.category == 'auto_reply' || email.category == 'auto_reply_pending') return false;
      if (email.sender == 'echo@e-team.com') return false;
      return true;
    }).toList();

    final sentEmails = _emails.where((email) {
      if (email.sender == 'echo@e-team.com') return true;
      if (email.category == 'auto_reply' || email.category == 'auto_reply_pending') return true;
      return false;
    }).toList();

    final urgentCount = _emails.where((e) => e.isUrgent && !e.isRead && e.sender != 'echo@e-team.com').length;
    final pendingCount = _pending.length;

    return Column(
      children: [
        // Email Controls
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
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
              // Filter buttons
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterButton(
                        icon: _showOnlyUrgent ? Icons.warning : Icons.warning_amber_rounded,
                        label: 'Urgent',
                        count: urgentCount,
                        isActive: _showOnlyUrgent,
                        color: Colors.red,
                        onTap: () {
                          setState(() {
                            _showOnlyUrgent = !_showOnlyUrgent;
                            if (_showOnlyUrgent) _showOnlySpam = false;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterButton(
                        icon: _showOnlySpam ? Icons.report : Icons.report_outlined,
                        label: 'Spam',
                        count: 0,
                        isActive: _showOnlySpam,
                        color: Colors.orange,
                        onTap: () {
                          setState(() {
                            _showOnlySpam = !_showOnlySpam;
                            if (_showOnlySpam) _showOnlyUrgent = false;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterButton(
                        icon: Icons.timer,
                        label: 'Pending',
                        count: pendingCount,
                        isActive: false,
                        color: Colors.blue,
                        onTap: () => _showPendingDialog(),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadAllEmails,
                tooltip: 'Rafraîchir',
              ),
            ],
          ),
        ),

        // Email Sub-tabs
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _emailSubTab = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _emailSubTab == 0 ? const Color(0xFF9C27B0) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '📥 Reçus',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _emailSubTab == 0 ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                        fontWeight: _emailSubTab == 0 ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
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
                      color: _emailSubTab == 1 ? const Color(0xFF9C27B0) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '📤 Envoyés',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _emailSubTab == 1 ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                        fontWeight: _emailSubTab == 1 ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Email List
        Expanded(
          child: _loadingEmails
              ? const Center(child: CircularProgressIndicator())
              : _buildEmailList(_emailSubTab == 0 ? receivedEmails : sentEmails, isDark),
        ),
      ],
    );
  }

  Widget _buildDocumentsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document Classification Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.description, color: const Color(0xFF9C27B0)),
                    const SizedBox(width: 8),
                    Text(
                      'Classification de Document',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _documentController,
                  maxLines: 6,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Collez ici le contenu du document à classifier...',
                    hintStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF9C27B0)),
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isClassifying ? null : _classifyDocument,
                        icon: _isClassifying
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(_isClassifying ? 'Classification...' : 'Classifier'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9C27B0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: (_currentClassification != null && !_isSaving) ? _saveDocument : null,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.save),
                        label: Text(_isSaving ? 'Sauvegarde...' : 'Sauvegarder'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Classification Results
          if (_currentClassification != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Résultat de la Classification',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildClassificationDetail('Catégorie', _currentClassification!.category, Icons.folder),
                  _buildClassificationDetail('Confidentialité', _currentClassification!.confidentialityLevel, Icons.security),
                  _buildClassificationDetail('Type', _currentClassification!.documentType, Icons.description),
                  _buildClassificationDetail('Urgence', _currentClassification!.urgency, Icons.priority_high),
                  const SizedBox(height: 8),
                  const Text('📝 Résumé:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_currentClassification!.summary),
                  if (_currentClassification!.keyTopics.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text('🏷️ Sujets clés:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: _currentClassification!.keyTopics.map((topic) => Chip(
                        label: Text(topic, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.blue.shade100,
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.psychology, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Confiance: ${(_currentClassification!.confidence * 100).toInt()}%',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Recent Documents
          _buildSectionHeader('Documents récents', isDark),
          const SizedBox(height: 12),
          
          if (_loadingDocuments)
            const Center(child: CircularProgressIndicator())
          else if (_recentDocuments.isEmpty)
            _buildEmptyState('Aucun document', Icons.description, isDark)
          else
            ..._recentDocuments.map((doc) => _buildDocumentCard(doc, isDark)),
            
          const SizedBox(height: 16),
          
          // Document Categories
          _buildDocumentCategories(isDark),
        ],
      ),
    );
  }

  Widget _buildTasksTab(bool isDark) {
    return Column(
      children: [
        // Task Stats and Filters
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.task_alt, color: Colors.orange, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Gestion des Tâches',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Task Stats
              Row(
                children: [
                  Expanded(
                    child: _buildTaskStatCard('À faire', _taskStats.todo, Colors.blue, isDark),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTaskStatCard('En cours', _taskStats.inProgress, Colors.orange, isDark),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTaskStatCard('Terminées', _taskStats.completed, Colors.green, isDark),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTaskStatCard('En retard', _taskStats.overdue, Colors.red, isDark),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Filter Buttons
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTaskFilterButton('Toutes', 'all', isDark),
                    const SizedBox(width: 8),
                    _buildTaskFilterButton('À faire', 'todo', isDark),
                    const SizedBox(width: 8),
                    _buildTaskFilterButton('En cours', 'in_progress', isDark),
                    const SizedBox(width: 8),
                    _buildTaskFilterButton('Terminées', 'completed', isDark),
                    const SizedBox(width: 8),
                    _buildTaskFilterButton('En retard', 'overdue', isDark),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Task List
        Expanded(
          child: _loadingTasks
              ? const Center(child: CircularProgressIndicator())
              : _buildTaskList(isDark),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildActivityCard(EmailItem email, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: email.isUrgent ? Border.all(color: Colors.red.shade300) : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: _getSenderColor(email.sender),
            child: Text(
              email.sender[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email.subject,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  email.summary,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (email.isUrgent)
            const Icon(Icons.warning, color: Colors.red, size: 16),
        ],
      ),
    );
  }

  Widget _buildEmailCard(EmailItem email, bool isDark) {
    final isUnread = !email.isRead && !email.isSpam;
    final pendingItem = _pending.firstWhere(
          (p) => p.emailId == email.id,
      orElse: () => PendingItem(emailId: '', subject: '', sender: '', scheduledAt: DateTime.now(), remainingMinutes: 0, willSendIn: ''),
    );
    final isPending = pendingItem.emailId.isNotEmpty;
    final isAutoReply = email.category == 'auto_reply' || email.category == 'auto_reply_pending';

    return GestureDetector(
      onTap: () async {
        await _markAsRead(email);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EchoEmailDetailScreen(
                email: email,
                token: widget.token,
                isPending: isPending,
                remainingMinutes: pendingItem.remainingMinutes,
                onReply: _loadAllEmails,
                onAfterReply: _loadStats,
              ),
            ),
          );
        }
      },
      onLongPress: () => _showEmailOptions(email),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1)),
          ],
          border: email.isUrgent ? Border.all(color: Colors.red.shade300, width: 1) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              if (isUnread) Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle)) else const SizedBox(width: 10),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 24,
                backgroundColor: _getSenderColor(email.sender),
                child: Text(email.sender[0].toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(email.sender, style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.w500, fontSize: 14, color: isDark ? Colors.white : Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Text(_formatTime(email.receivedAt), style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.grey[500])),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(email.subject, style: TextStyle(fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal, fontSize: 13, color: isDark ? Colors.white : Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(email.summary.length > 100 ? '${email.summary.substring(0, 100)}...' : email.summary, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        if (email.isUrgent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.warning, size: 10, color: Colors.red), SizedBox(width: 2), Text('Urgent', style: TextStyle(fontSize: 9, color: Colors.red, fontWeight: FontWeight.w500))]),
                          ),
                        if (email.isSpam)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                            child: const Text('Spam', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w500)),
                          ),
                        if (email.category.isNotEmpty && !email.isSpam && !isAutoReply)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFF9C27B0).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(email.category, style: const TextStyle(fontSize: 9, color: Color(0xFF9C27B0), fontWeight: FontWeight.w500)),
                          ),
                        if (isPending && !isAutoReply)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                            child: Text('⏰ ${pendingItem.willSendIn}', style: TextStyle(fontSize: 9, color: Colors.orange, fontWeight: FontWeight.w500)),
                          ),
                        if (isAutoReply)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                            child: const Text('📤 Envoyé', style: TextStyle(fontSize: 9, color: Colors.blue, fontWeight: FontWeight.w500)),
                          ),
                      ],
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

  Widget _buildDocumentCard(DocumentItem doc, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getCategoryColor(doc.category).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(doc.category),
              color: _getCategoryColor(doc.category),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${doc.category} • ${doc.confidentialityLevel}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Actions rapides', isDark),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Analyser message',
                Icons.analytics,
                Colors.blue,
                () => setState(() => _selectedTab = 1), // Switch to Messages tab
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Classifier document',
                Icons.description,
                Colors.green,
                () => setState(() => _selectedTab = 2), // Switch to Documents tab
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCategories(bool isDark) {
    final categories = [
      {'name': 'Commercial', 'icon': Icons.business, 'color': Colors.blue},
      {'name': 'Finance', 'icon': Icons.account_balance, 'color': Colors.green},
      {'name': 'Juridique', 'icon': Icons.gavel, 'color': Colors.red},
      {'name': 'Marketing', 'icon': Icons.campaign, 'color': Colors.orange},
      {'name': 'RH', 'icon': Icons.people, 'color': Colors.purple},
      {'name': 'Technique', 'icon': Icons.engineering, 'color': Colors.teal},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Catégories de documents', isDark),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EchoDocumentCategoryPage(
                      category: category['name'] as String,
                      token: widget.token,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (category['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        category['icon'] as IconData,
                        size: 32,
                        color: category['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      category['name'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: isDark ? Colors.white30 : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassificationDetail(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Color(0xFF9C27B0))),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔧 HELPER METHODS (from EchoInboxScreen)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTaskStatCard(String title, int count, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskFilterButton(String title, String filter, bool isDark) {
    final isSelected = _selectedTaskFilter == filter;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedTaskFilter = filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(bool isDark) {
    List<TaskItem> filteredTasks;
    
    switch (_selectedTaskFilter) {
      case 'todo':
        filteredTasks = _todoTasks;
        break;
      case 'in_progress':
        filteredTasks = _inProgressTasks;
        break;
      case 'completed':
        filteredTasks = _completedTasks;
        break;
      case 'overdue':
        filteredTasks = _overdueTasks;
        break;
      default:
        filteredTasks = _tasks;
    }

    if (filteredTasks.isEmpty) {
      return _buildEmptyState(
        _selectedTaskFilter == 'all' 
            ? 'Aucune tâche trouvée'
            : 'Aucune tâche ${_getFilterDisplayName(_selectedTaskFilter)}',
        Icons.task_alt,
        isDark,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        return _buildTaskCard(filteredTasks[index], isDark);
      },
    );
  }

  Widget _buildTaskCard(TaskItem task, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: task.isOverdue ? Border.all(color: Colors.red.shade300) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTaskCategoryColor(task.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTaskCategoryIcon(task.category),
                  color: _getTaskCategoryColor(task.category),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black,
                        decoration: task.status == 'completed' ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getTaskPriorityColor(task.priority).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getTaskPriorityText(task.priority),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getTaskPriorityColor(task.priority),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getTaskStatusColor(task.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getTaskStatusText(task.status),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getTaskStatusColor(task.status),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (task.isOverdue) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.warning, color: Colors.red, size: 14),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Task Actions
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'todo':
                    case 'in_progress':
                    case 'completed':
                      _updateTaskStatus(task.id, value);
                      break;
                    case 'delete':
                      _showDeleteTaskDialog(task);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (task.status != 'todo')
                    const PopupMenuItem(value: 'todo', child: Text('📋 À faire')),
                  if (task.status != 'in_progress')
                    const PopupMenuItem(value: 'in_progress', child: Text('🔄 En cours')),
                  if (task.status != 'completed')
                    const PopupMenuItem(value: 'completed', child: Text('✅ Terminé')),
                  const PopupMenuDivider(),
                  const PopupMenuItem(value: 'delete', child: Text('🗑️ Supprimer', style: TextStyle(color: Colors.red))),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Task Description
          Text(
            task.description,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          
          // Task Details
          if (task.assignee != null || task.deadline != null || task.extractedFrom != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (task.assignee != null)
                  _buildTaskDetailChip(Icons.person, task.assignee!, Colors.blue),
                if (task.deadline != null)
                  _buildTaskDetailChip(
                    Icons.schedule,
                    _formatTaskDeadline(task.deadline!),
                    task.isOverdue ? Colors.red : Colors.green,
                  ),
                if (task.extractedFrom?.sender != null)
                  _buildTaskDetailChip(Icons.email, 'De: ${task.extractedFrom!.sender}', Colors.purple),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskDetailChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteTaskDialog(TaskItem task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la tâche'),
        content: Text('Voulez-vous vraiment supprimer "${task.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTask(task.id);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Task Helper Methods
  Color _getTaskCategoryColor(String category) {
    switch (category) {
      case 'meeting': return Colors.blue;
      case 'development': return Colors.green;
      case 'communication': return Colors.purple;
      case 'admin': return Colors.orange;
      case 'research': return Colors.teal;
      default: return Colors.grey;
    }
  }

  IconData _getTaskCategoryIcon(String category) {
    switch (category) {
      case 'meeting': return Icons.meeting_room;
      case 'development': return Icons.code;
      case 'communication': return Icons.message;
      case 'admin': return Icons.admin_panel_settings;
      case 'research': return Icons.search;
      default: return Icons.task;
    }
  }

  Color _getTaskPriorityColor(String priority) {
    switch (priority) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      default: return Colors.green;
    }
  }

  String _getTaskPriorityText(String priority) {
    switch (priority) {
      case 'high': return 'Haute';
      case 'medium': return 'Moyenne';
      default: return 'Basse';
    }
  }

  Color _getTaskStatusColor(String status) {
    switch (status) {
      case 'todo': return Colors.blue;
      case 'in_progress': return Colors.orange;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.grey;
      default: return Colors.grey;
    }
  }

  String _getTaskStatusText(String status) {
    switch (status) {
      case 'todo': return 'À faire';
      case 'in_progress': return 'En cours';
      case 'completed': return 'Terminé';
      case 'cancelled': return 'Annulé';
      default: return 'Inconnu';
    }
  }

  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'todo': return 'à faire';
      case 'in_progress': return 'en cours';
      case 'completed': return 'terminées';
      case 'overdue': return 'en retard';
      default: return '';
    }
  }

  String _formatTaskDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    
    if (difference.isNegative) {
      return 'En retard';
    } else if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Demain';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} jours';
    } else {
      return '${deadline.day}/${deadline.month}/${deadline.year}';
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔧 EXISTING HELPER METHODS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required int count,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? color : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? color : Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? color : Colors.grey,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmailList(List<EmailItem> emails, bool isDark) {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadAllEmails, child: const Text('Réessayer')),
          ],
        ),
      );
    }

    if (emails.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: isDark ? Colors.white30 : Colors.grey[400]),
            const SizedBox(height: 16),
            Text(_getEmptyMessage(), style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[500], fontSize: 16)),
            const SizedBox(height: 8),
            Text(_getEmptySubMessage(), style: TextStyle(color: isDark ? Colors.white30 : Colors.grey[400], fontSize: 14)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllEmails,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: emails.length,
        itemBuilder: (context, index) => _buildEmailCard(emails[index], isDark),
      ),
    );
  }

  String _getEmptyMessage() {
    if (_showOnlyUrgent) return 'Aucun message urgent';
    if (_showOnlySpam) return 'Aucun spam détecté';
    return 'Aucun email reçu';
  }

  String _getEmptySubMessage() {
    if (_showOnlyUrgent) return 'Les nouveaux messages urgents apparaîtront ici';
    if (_showOnlySpam) return 'Les spams détectés apparaîtront ici';
    return 'Les emails reçus apparaîtront ici';
  }

  void _showEmailOptions(EmailItem email) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.delete_outline, color: Colors.red), title: const Text('Supprimer'), onTap: () {
              Navigator.pop(context);
              _deleteEmail(email);
            }),
            ListTile(leading: const Icon(Icons.info_outline), title: const Text('Détails'), onTap: () {
              Navigator.pop(context);
              _showEmailDetails(email);
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showEmailDetails(EmailItem email) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverAppBar(
                title: Text(email.subject, style: const TextStyle(fontSize: 16)),
                floating: true,
                backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                foregroundColor: isDark ? Colors.white : Colors.black,
                elevation: 0,
                leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                actions: [IconButton(icon: const Icon(Icons.delete_outline), onPressed: () {
                  Navigator.pop(context);
                  _deleteEmail(email);
                })],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      children: [
                        CircleAvatar(radius: 28, backgroundColor: _getSenderColor(email.sender), child: Text(email.sender[0].toUpperCase(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(email.sender, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black)),
                              Text(_formatDateTime(email.receivedAt), style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey[500])),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (email.isUrgent)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                        child: const Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red),
                            SizedBox(width: 8),
                            Expanded(child: Text('⚠️ Message urgent - À traiter immédiatement', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    const Text('📧 Message original', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(email.content, style: TextStyle(fontSize: 14, height: 1.4, color: isDark ? Colors.white : Colors.black)),
                    ),
                    const SizedBox(height: 20),
                    const Text('🔍 Analyse intelligente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C27B0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('📝 Résumé', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(email.summary, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                          const SizedBox(height: 12),
                          if (email.actions.isNotEmpty) ...[
                            const Text('✅ Actions recommandées', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 8),
                            ...email.actions.map((action) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(children: [const Text('• ', style: TextStyle(fontSize: 14)), Expanded(child: Text(action, style: TextStyle(color: isDark ? Colors.white : Colors.black)))]),
                            )),
                            const SizedBox(height: 12),
                          ],
                          Row(
                            children: [
                              const Text('⭐ Priorité : ', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                              Text(_getPriorityText(email.priority), style: TextStyle(color: _getPriorityColor(email.priority), fontWeight: FontWeight.w500)),
                            ],
                          ),
                          if (email.category.isNotEmpty && email.category != 'auto_reply' && email.category != 'auto_reply_pending') ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text('📂 Catégorie : ', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                                Text(email.category, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPendingDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text('⏰ Réponses en attente', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: _pending.isEmpty
            ? Text('Aucune réponse en attente', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54))
            : SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _pending.length,
            itemBuilder: (context, index) {
              final p = _pending[index];
              return ListTile(
                title: Text(p.subject, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                subtitle: Text('De: ${p.sender}', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
                trailing: Text(p.willSendIn, style: const TextStyle(color: Colors.orange)),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      default: return Colors.green;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority.toLowerCase()) {
      case 'high': return 'Haute';
      case 'medium': return 'Moyenne';
      default: return 'Basse';
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return 'il y a ${diff.inDays}j';
    if (diff.inHours > 0) return 'il y a ${diff.inHours}h';
    if (diff.inMinutes > 0) return 'il y a ${diff.inMinutes}min';
    return 'À l\'instant';
  }

  String _formatDateTime(DateTime time) {
    return '${time.day}/${time.month}/${time.year} à ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Color _getSenderColor(String sender) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.pink, Colors.indigo];
    return colors[sender.length % colors.length];
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Commercial': return Colors.blue;
      case 'Finance': return Colors.green;
      case 'Juridique': return Colors.red;
      case 'Marketing': return Colors.orange;
      case 'RH': return Colors.purple;
      case 'Technique': return Colors.teal;
      default: return Colors.grey;
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