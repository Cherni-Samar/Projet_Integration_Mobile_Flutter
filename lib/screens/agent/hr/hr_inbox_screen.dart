import 'package:flutter/material.dart';
import '../../../services/echo_service.dart';

class HrInboxScreen extends StatefulWidget {
  final String? token;

  const HrInboxScreen({super.key, this.token});

  @override
  State<HrInboxScreen> createState() => _HrInboxScreenState();
}

class _HrInboxScreenState extends State<HrInboxScreen> {
  List<EmailItem> _emails = [];
  bool _isLoading = true;
  int _selectedTab = 0; // 0 = Reçus, 1 = Envoyés

  @override
  void initState() {
    super.initState();
    _loadEmails();
  }

  Future<void> _loadEmails() async {
    setState(() => _isLoading = true);
    final response = await EchoService.getEmails(token: widget.token);
    if (response.success && mounted) {
      setState(() {
        _emails = response.emails;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final receivedEmails = _emails
        .where((e) =>
            e.sender != 'echo@e-team.com' &&
            e.category != 'auto_reply' &&
            e.category != 'auto_reply_pending' &&
            e.sender != 'hera@e-team.com')
        .toList();

    final sentEmails = _emails
        .where((e) =>
            e.sender == 'hera@e-team.com' ||
            (e.category == 'reply' && e.sender == 'echo@e-team.com'))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Agent Hera - Messages'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmails,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: Column(
        children: [
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
                        color: _selectedTab == 0
                            ? Colors.orange
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '📥 Reçus',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedTab == 0
                              ? Colors.white
                              : Colors.grey[600],
                          fontWeight: FontWeight.bold,
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
                        color: _selectedTab == 1
                            ? Colors.orange
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '📤 Envoyés',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedTab == 1
                              ? Colors.white
                              : Colors.grey[600],
                          fontWeight: FontWeight.bold,
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
                    ? _buildEmailList(receivedEmails, 'reçus')
                    : _buildEmailList(sentEmails, 'envoyés'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailList(List<EmailItem> emails, String type) {
    if (emails.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(type == 'reçus' ? Icons.inbox : Icons.send,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              type == 'reçus' ? 'Aucun message reçu' : 'Aucun message envoyé',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              type == 'reçus'
                  ? 'Les messages reçus apparaîtront ici'
                  : 'Les messages que vous envoyez apparaîtront ici',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEmails,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: emails.length,
        itemBuilder: (context, index) => _buildEmailCard(emails[index]),
      ),
    );
  }

  Widget _buildEmailCard(EmailItem email) {
    final isFromEcho = email.sender == 'echo@e-team.com';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    isFromEcho ? Colors.deepPurple : _getSenderColor(email.sender),
                child: Text(
                  email.sender[0].toUpperCase(),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          email.sender,
                          style: TextStyle(
                            fontWeight:
                                isFromEcho ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        if (isFromEcho)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Echo',
                              style: TextStyle(fontSize: 9, color: Colors.deepPurple),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      email.subject,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                _formatTime(email.receivedAt),
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            email.summary.length > 80
                ? '${email.summary.substring(0, 80)}...'
                : email.summary,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          if (email.isUrgent)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8)),
                child: const Text('Urgent',
                    style: TextStyle(fontSize: 10, color: Colors.red)),
              ),
            ),
          if (isFromEcho && email.category == 'reply')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8)),
                child: const Text('Réponse',
                    style: TextStyle(fontSize: 10, color: Colors.green)),
              ),
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
      Colors.indigo
    ];
    return colors[sender.length % colors.length];
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return 'il y a ${diff.inDays}j';
    if (diff.inHours > 0) return 'il y a ${diff.inHours}h';
    if (diff.inMinutes > 0) return 'il y a ${diff.inMinutes}min';
    return 'À l\'instant';
  }
}
