import 'package:flutter/material.dart';
import 'package:e_team/data/services/echo_service.dart';
import 'package:e_team/domain/models/echo_models.dart';
import 'package:e_team/presentation/screens/agent/agent_communication_screen.dart';
import 'echo_email_detail_screen.dart';
import 'package:e_team/presentation/widgets/echo/inbox/echo_inbox_widgets.dart';
import 'package:e_team/presentation/widgets/echo/inbox/echo_email_details_sheet.dart';

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

  int _selectedTab = 0; // 0 = Reçus, 1 = Envoyés
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await EchoService.deleteEmail(
        email.id,
        token: widget.token,
      );

      if (success && mounted) {
        setState(() {
          _emails.removeWhere((e) => e.id == email.id);
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Email supprimé')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final receivedEmails = _emails.where((email) {
      if (_showOnlyUrgent && !email.isUrgent) return false;
      if (email.isSpam) return false;
      if (email.category == 'auto_reply' ||
          email.category == 'auto_reply_pending') {
        return false;
      }
      if (email.sender == 'echo@e-team.com') return false;
      return true;
    }).toList();

    final sentEmails = _emails.where((email) {
      if (email.sender == 'echo@e-team.com') return true;
      if (email.category == 'auto_reply' ||
          email.category == 'auto_reply_pending') {
        return true;
      }
      return false;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildEchoInboxHeader(),
            _buildTabs(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF7C3AED),
                      ),
                    )
                  : _selectedTab == 0
                  ? _buildBody(receivedEmails)
                  : _buildSentEmails(sentEmails),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return EchoInboxTabs(
      selectedTab: _selectedTab,
      onSelect: (index) => setState(() => _selectedTab = index),
    );
  }

  Widget _buildEchoInboxHeader() {
    final urgentCount = _emails
        .where((e) => e.isUrgent && !e.isRead && e.sender != 'echo@e-team.com')
        .length;

    final pendingCount = _pending.length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 17,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.mark_email_unread_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Echo Inbox',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Communication triage center',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _loadData,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: Color(0xFF7C3AED),
                    size: 21,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: EchoInboxHeaderAction(
                  icon: Icons.timer_rounded,
                  label: 'Pending',
                  value: '$pendingCount',
                  color: Colors.orange,
                  onTap: _showPendingDialog,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: EchoInboxHeaderAction(
                  icon: _showOnlyUrgent
                      ? Icons.warning_rounded
                      : Icons.warning_amber_rounded,
                  label: 'Urgent',
                  value: '$urgentCount',
                  color: Colors.red,
                  onTap: () {
                    setState(() {
                      _showOnlyUrgent = !_showOnlyUrgent;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: EchoInboxHeaderAction(
                  icon: Icons.send_rounded,
                  label: 'Send',
                  value: '',
                  color: const Color(0xFF7C3AED),
                  onTap: () {
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List<EmailItem> emails) {
    if (_errorMessage != null) {
      return _buildErrorState();
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
      return _buildEmptyState(
        icon: Icons.send,
        title: 'Aucun email envoyé',
        subtitle: 'Les emails que vous envoyez apparaîtront ici',
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

  Widget _buildErrorState() {
    return EchoInboxErrorState(message: _errorMessage!, onRetry: _loadData);
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return EchoInboxEmptyState(icon: icon, title: title, subtitle: subtitle);
  }

  Widget _buildEmailCard(EmailItem email) {
    final pendingItem = _pending.firstWhere(
      (p) => p.emailId == email.id,
      orElse: () => PendingItem(
        emailId: '',
        subject: '',
        sender: '',
        scheduledAt: DateTime.now(),
        remainingMinutes: 0,
        willSendIn: '',
      ),
    );

    final isPending = pendingItem.emailId.isNotEmpty;

    return EchoEmailCard(
      email: email,
      pendingItem: pendingItem,
      onTap: () async {
        await _markAsRead(email);

        if (!mounted) return;

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
      },
      onLongPress: () => _showEmailOptions(email),
    );
  }

  void _showEmailOptions(EmailItem email) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Supprimer'),
              onTap: () {
                Navigator.pop(context);
                _deleteEmail(email);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Détails'),
              onTap: () {
                Navigator.pop(context);
                _showEmailDetails(email);
              },
            ),
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
      builder: (context) => EchoEmailDetailsSheet(
        email: email,
        onDelete: () {
          Navigator.pop(context);
          _deleteEmail(email);
        },
      ),
    );
  }

  void _showPendingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⏰ Réponses en attente'),
        content: _pending.isEmpty
            ? const Text('Aucune réponse en attente')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _pending.length,
                  itemBuilder: (context, index) {
                    final item = _pending[index];

                    return ListTile(
                      title: Text(item.subject),
                      subtitle: Text('De: ${item.sender}'),
                      trailing: Text(
                        item.willSendIn,
                        style: const TextStyle(color: Colors.orange),
                      ),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
