import 'package:flutter/material.dart';
import '../../../services/echo_service.dart';
import '../agent_communication_screen.dart';
import 'echo_email_detail_screen.dart';
import 'echo_document_category_page.dart';

class EchoInboxScreen extends StatefulWidget {
  final String? token;

  const EchoInboxScreen({super.key, this.token});

  @override
  State<EchoInboxScreen> createState() => _EchoInboxScreenState();
}

class _EchoInboxScreenState extends State<EchoInboxScreen> {
  List<EmailItem> _emails = [];
  List<PendingItem> _pending = [];
  bool _isLoading = true;
  bool _showOnlyUrgent = false;
  bool _showOnlySpam = false;
  int _selectedTab = 0; // 0 = Recus, 1 = Envoyes, 2 = Documents
  String? _errorMessage;

  // Document management
  final TextEditingController _documentController = TextEditingController();
  DocumentClassification? _currentClassification;
  bool _isClassifying = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _documentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final emailsResponse = await EchoService.getEmails(token: widget.token);
    final pendingResponse = await EchoService.getPending(token: widget.token);

    if (emailsResponse.success && mounted) {
      setState(() {
        _emails = emailsResponse.emails;
        _pending = pendingResponse.pending;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _errorMessage = emailsResponse.error ?? 'Erreur de chargement';
        _isLoading = false;
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email supprime')));
      }
    }
  }

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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Agent Echo', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.timer), onPressed: () => _showPendingDialog(), tooltip: 'Reponses en attente'),
              if (pendingCount > 0)
                Positioned(
                  right: 8, top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text('$pendingCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.deepPurple),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AgentCommunicationScreen(token: widget.token, fromAgent: 'echo')));
            },
            tooltip: 'Envoyer a Hera',
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(_showOnlyUrgent ? Icons.warning : Icons.warning_amber_rounded, color: _showOnlyUrgent ? Colors.red : Colors.grey),
                onPressed: () {
                  setState(() {
                    _showOnlyUrgent = !_showOnlyUrgent;
                    if (_showOnlyUrgent) _showOnlySpam = false;
                  });
                },
                tooltip: 'Urgents',
              ),
              if (urgentCount > 0 && !_showOnlyUrgent)
                Positioned(
                  right: 8, top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text('$urgentCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(_showOnlySpam ? Icons.report : Icons.report_outlined, color: _showOnlySpam ? Colors.orange : Colors.grey),
            onPressed: () {
              setState(() {
                _showOnlySpam = !_showOnlySpam;
                if (_showOnlySpam) _showOnlyUrgent = false;
              });
            },
            tooltip: 'Spams',
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData, tooltip: 'Rafraichir'),
        ],
      ),
      body: Column(
        children: [
          // Onglets
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0 ? Colors.deepPurple : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '📥 Recus',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedTab == 0 ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1 ? Colors.deepPurple : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '📤 Envoyes',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedTab == 1 ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 2 ? Colors.deepPurple : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '📄 Documents',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedTab == 2 ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedTab == 0
                ? _buildBody(receivedEmails)
                : _selectedTab == 1
                ? _buildSentEmails(sentEmails)
                : _buildDocumentsTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List<EmailItem> emails) {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Reessayer')),
          ],
        ),
      );
    }

    if (emails.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(_getEmptyMessage(), style: TextStyle(color: Colors.grey[500], fontSize: 16)),
            const SizedBox(height: 8),
            Text(_getEmptySubMessage(), style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: emails.length,
        itemBuilder: (context, index) => _buildEmailCard(emails[index]),
      ),
    );
  }

  Widget _buildSentEmails(List<EmailItem> emails) {
    if (emails.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Aucun email envoye', style: TextStyle(color: Colors.grey[500])),
            const SizedBox(height: 8),
            Text('Les emails que vous envoyez apparaitront ici', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: emails.length,
        itemBuilder: (context, index) => _buildEmailCard(emails[index]),
      ),
    );
  }

  String _getEmptyMessage() {
    if (_showOnlyUrgent) return 'Aucun message urgent';
    if (_showOnlySpam) return 'Aucun spam detecte';
    return 'Aucun email recu';
  }

  String _getEmptySubMessage() {
    if (_showOnlyUrgent) return 'Les nouveaux messages urgents apparaitront ici';
    if (_showOnlySpam) return 'Les spams detectes apparaitront ici';
    return 'Les emails recus apparaitront ici';
  }

  Widget _buildEmailCard(EmailItem email) {
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
                onReply: _loadData,
              ),
            ),
          );
        }
      },
      onLongPress: () => _showEmailOptions(email),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
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
                          child: Text(email.sender, style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.w500, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Text(_formatTime(email.receivedAt), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(email.subject, style: TextStyle(fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(email.summary.length > 100 ? '${email.summary.substring(0, 100)}...' : email.summary, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
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
                            decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(8)),
                            child: Text(email.category, style: TextStyle(fontSize: 9, color: Colors.deepPurple.shade700, fontWeight: FontWeight.w500)),
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
                            child: const Text('📤 Envoye', style: TextStyle(fontSize: 9, color: Colors.blue, fontWeight: FontWeight.w500)),
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
            ListTile(leading: const Icon(Icons.info_outline), title: const Text('Details'), onTap: () {
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverAppBar(
                title: Text(email.subject, style: const TextStyle(fontSize: 16)),
                floating: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
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
                              Text(email.sender, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text(_formatDateTime(email.receivedAt), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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
                            Expanded(child: Text('⚠️ Message urgent - A traiter immediatement', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    const Text('📧 Message original', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                      child: Text(email.content, style: const TextStyle(fontSize: 14, height: 1.4)),
                    ),
                    const SizedBox(height: 20),
                    const Text('🔍 Analyse intelligente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('📝 Resume', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(email.summary),
                          const SizedBox(height: 12),
                          if (email.actions.isNotEmpty) ...[
                            const Text('✅ Actions recommandees', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 8),
                            ...email.actions.map((action) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(children: [const Text('• ', style: TextStyle(fontSize: 14)), Expanded(child: Text(action))]),
                            )),
                            const SizedBox(height: 12),
                          ],
                          Row(
                            children: [
                              const Text('⭐ Priorite : ', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                              Text(_getPriorityText(email.priority), style: TextStyle(color: _getPriorityColor(email.priority), fontWeight: FontWeight.w500)),
                            ],
                          ),
                          if (email.category.isNotEmpty && email.category != 'auto_reply' && email.category != 'auto_reply_pending') ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text('📂 Categorie : ', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                                Text(email.category),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⏰ Reponses en attente'),
        content: _pending.isEmpty
            ? const Text('Aucune reponse en attente')
            : SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _pending.length,
            itemBuilder: (context, index) {
              final p = _pending[index];
              return ListTile(
                title: Text(p.subject),
                subtitle: Text('De: ${p.sender}'),
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

  Color _getSenderColor(String sender) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.pink, Colors.indigo];
    return colors[sender.length % colors.length];
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
    return 'A l instant';
  }

  String _formatDateTime(DateTime time) {
    return '${time.day}/${time.month}/${time.year} a ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildDocumentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document Classification Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.description, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Text(
                      'Classification de Document',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _documentController,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: 'Collez ici le contenu du document à classifier...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.deepPurple),
                    ),
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
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.auto_awesome),
                        label: Text(_isClassifying ? 'Classification...' : 'Classifier'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
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
                          child: CircularProgressIndicator(strokeWidth: 2),
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

          // Document Categories Section
          const Text(
            '📂 Catégories de Documents',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 12),
          _buildDocumentCategories(),
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
          Text(value, style: const TextStyle(color: Colors.deepPurple)),
        ],
      ),
    );
  }

  Widget _buildDocumentCategories() {
    final categories = [
      {'name': 'Commercial', 'icon': Icons.business, 'color': Colors.blue},
      {'name': 'Finance', 'icon': Icons.account_balance, 'color': Colors.green},
      {'name': 'Juridique', 'icon': Icons.gavel, 'color': Colors.red},
      {'name': 'Marketing', 'icon': Icons.campaign, 'color': Colors.orange},
      {'name': 'RH', 'icon': Icons.people, 'color': Colors.purple},
      {'name': 'Technique', 'icon': Icons.engineering, 'color': Colors.teal},
    ];

    return GridView.builder(
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}