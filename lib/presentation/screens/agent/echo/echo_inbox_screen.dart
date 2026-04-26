import 'package:flutter/material.dart';
import 'package:e_team/data/services/echo_service.dart';
import 'package:e_team/domain/models/echo_models.dart';
import '../agent_communication_screen.dart';
import 'echo_email_detail_screen.dart';

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

    final success = await EchoService.markAsRead(
      email.id,
      token: widget.token,
    );

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
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
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

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email supprimé')),
        );
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

    final urgentCount = _emails
        .where(
          (e) =>
      e.isUrgent &&
          !e.isRead &&
          e.sender != 'echo@e-team.com',
    )
        .length;

    final pendingCount = _pending.length;

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabButton(label: 'Received', index: 0)),
          Expanded(child: _buildTabButton(label: 'Sent', index: 1)),
        ],
      ),
    );
  }
  Widget _buildTabButton({
    required String label,
    required int index,
  }) {
    final selected = _selectedTab == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ]
              : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.black87 : Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
  Widget _buildHeaderAction({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.16)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value.isEmpty ? label : value,
              style: TextStyle(
                color: const Color(0xFF111827),
                fontSize: value.isEmpty ? 11 : 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (value.isNotEmpty)
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
          ],
        ),
      ),
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
            color: Colors.black.withOpacity(0.035),
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
                child: _buildHeaderAction(
                  icon: Icons.timer_rounded,
                  label: 'Pending',
                  value: '$pendingCount',
                  color: Colors.orange,
                  onTap: _showPendingDialog,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildHeaderAction(
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
                child: _buildHeaderAction(
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }



  String _getEmptySubMessage() {
    if (_showOnlyUrgent) {
      return 'Les nouveaux messages urgents apparaîtront ici';
    }
    return 'Les emails reçus apparaîtront ici';
  }

  Widget _buildEmailCard(EmailItem email) {
    final isUnread = !email.isRead && !email.isSpam;

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
    final isAutoReply = email.category == 'auto_reply' ||
        email.category == 'auto_reply_pending';

    return GestureDetector(
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
          border: email.isUrgent
              ? Border.all(color: Colors.red.shade300, width: 1)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              if (isUnread)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(width: 10),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 24,
                backgroundColor: _getSenderColor(email.sender),
                child: Text(
                  email.sender.isNotEmpty
                      ? email.sender[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEmailInfo(
                  email: email,
                  isUnread: isUnread,
                  isPending: isPending,
                  isAutoReply: isAutoReply,
                  pendingItem: pendingItem,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailInfo({
    required EmailItem email,
    required bool isUnread,
    required bool isPending,
    required bool isAutoReply,
    required PendingItem pendingItem,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                email.sender,
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatTime(email.receivedAt),
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          email.subject,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          email.summary.length > 100
              ? '${email.summary.substring(0, 100)}...'
              : email.summary,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        _buildTags(
          email: email,
          isPending: isPending,
          isAutoReply: isAutoReply,
          pendingItem: pendingItem,
        ),
      ],
    );
  }

  Widget _buildTags({
    required EmailItem email,
    required bool isPending,
    required bool isAutoReply,
    required PendingItem pendingItem,
  }) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        if (email.isUrgent) _chipUrgent(),
        if (email.category.isNotEmpty && !email.isSpam && !isAutoReply)
          _chipText(
            text: email.category,
            bg: Colors.deepPurple.shade50,
            color: Colors.deepPurple.shade700,
          ),
        if (isPending && !isAutoReply)
          _chipText(
            text: '⏰ ${pendingItem.willSendIn}',
            bg: Colors.orange.shade50,
            color: Colors.orange,
          ),
        if (isAutoReply)
          _chipText(
            text: '📤 Envoyé',
            bg: Colors.blue.shade50,
            color: Colors.blue,
          ),
      ],
    );
  }

  Widget _chipUrgent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, size: 10, color: Colors.red),
          SizedBox(width: 2),
          Text(
            'Urgent',
            style: TextStyle(
              fontSize: 9,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }



  Widget _chipText({
    required String text,
    required Color bg,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
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
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverAppBar(
                title: Text(
                  email.subject,
                  style: const TextStyle(fontSize: 16),
                ),
                floating: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteEmail(email);
                    },
                  )
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildEmailDetailsHeader(email),
                    const SizedBox(height: 20),
                    if (email.isUrgent) _buildUrgentWarning(),
                    const SizedBox(height: 20),
                    const Text(
                      '📧 Message original',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _boxText(email.content),
                    const SizedBox(height: 20),
                    const Text(
                      '🔍 Analyse intelligente',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAnalysisBox(email),
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

  Widget _buildEmailDetailsHeader(EmailItem email) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: _getSenderColor(email.sender),
          child: Text(
            email.sender.isNotEmpty ? email.sender[0].toUpperCase() : '?',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                email.sender,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                _formatDateTime(email.receivedAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUrgentWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '⚠️ Message urgent - À traiter immédiatement',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _boxText(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, height: 1.4),
      ),
    );
  }

  Widget _buildAnalysisBox(EmailItem email) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📝 Résumé',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(email.summary),
          const SizedBox(height: 12),
          if (email.actions.isNotEmpty) ...[
            const Text(
              '✅ Actions recommandées',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 8),
            ...email.actions.map(
                  (action) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 14)),
                    Expanded(child: Text(action)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              const Text(
                '⭐ Priorité : ',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              ),
              Text(
                _getPriorityText(email.priority),
                style: TextStyle(
                  color: _getPriorityColor(email.priority),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (email.category.isNotEmpty &&
              email.category != 'auto_reply' &&
              email.category != 'auto_reply_pending') ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  '📂 Catégorie : ',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                ),
                Text(email.category),
              ],
            ),
          ],
        ],
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

  Color _getSenderColor(String sender) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return colors[sender.length % colors.length];
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'Haute';
      case 'medium':
        return 'Moyenne';
      default:
        return 'Basse';
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inDays > 0) return 'il y a ${diff.inDays}j';
    if (diff.inHours > 0) return 'il y a ${diff.inHours}h';
    if (diff.inMinutes > 0) return 'il y a ${diff.inMinutes}min';

    return 'À l’instant';
  }

  String _formatDateTime(DateTime time) {
    final day = time.day.toString().padLeft(2, '0');
    final month = time.month.toString().padLeft(2, '0');
    final year = time.year;
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$day/$month/$year à $hour:$minute';
  }
}