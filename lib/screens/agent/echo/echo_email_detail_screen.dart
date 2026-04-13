import 'package:flutter/material.dart';
import '../../../services/echo_service.dart';

class EchoEmailDetailScreen extends StatefulWidget {
  final EmailItem email;
  final String? token;
  final bool isPending;
  final double remainingMinutes;
  final VoidCallback onReply;
  /// Appelé après une réponse envoyée avec succès (ex. rafraîchir les stats du dashboard).
  final VoidCallback? onAfterReply;

  const EchoEmailDetailScreen({
    super.key,
    required this.email,
    this.token,
    required this.isPending,
    required this.remainingMinutes,
    required this.onReply,
    this.onAfterReply,
  });

  @override
  State<EchoEmailDetailScreen> createState() => _EchoEmailDetailScreenState();
}

class _EchoEmailDetailScreenState extends State<EchoEmailDetailScreen> {
  final TextEditingController _replyController = TextEditingController();
  bool _isReplying = false;
  bool _isLoadingSuggestions = false;
  bool _isExtractingTasks = false;
  List<ResponseSuggestion> _suggestions = [];
  bool _showSuggestions = false;

  Future<void> _sendReply() async {
    if (_replyController.text.trim().isEmpty) return;

    setState(() => _isReplying = true);

    final result = await EchoService.replyToEmail(
      emailId: widget.email.id,
      replyContent: _replyController.text.trim(),
      token: widget.token,
    );

    if (mounted) {
      setState(() => _isReplying = false);
      if (EchoService.replySucceeded(result)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Réponse envoyée'), backgroundColor: Colors.green),
        );
        widget.onReply();
        widget.onAfterReply?.call();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: ${result['error']}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadResponseSuggestions() async {
    setState(() => _isLoadingSuggestions = true);

    try {
      final response = await EchoService.getResponseSuggestions(
        message: widget.email.content,
        sender: widget.email.sender,
        context: {
          'subject': widget.email.subject,
          'isUrgent': widget.email.isUrgent,
          'priority': widget.email.priority,
          'category': widget.email.category,
        },
        analysis: {
          'summary': widget.email.summary,
          'actions': widget.email.actions,
        },
        token: widget.token,
      );

      if (mounted) {
        setState(() {
          _suggestions = response.suggestions;
          _showSuggestions = true;
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSuggestions = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _extractTasks() async {
    setState(() => _isExtractingTasks = true);

    try {
      final response = await EchoService.extractAndSaveTasks(
        message: widget.email.content,
        sender: widget.email.sender,
        emailId: widget.email.id,
        subject: widget.email.subject,
        token: widget.token,
      );

      if (mounted) {
        setState(() => _isExtractingTasks = false);
        
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${response.message}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${response.error ?? "Erreur d'extraction"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExtractingTasks = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _selectSuggestion(ResponseSuggestion suggestion) {
    _replyController.text = suggestion.content;
    setState(() => _showSuggestions = false);
  }

  String _typeSectionLabel(String type) {
    switch (type.toLowerCase()) {
      case 'formal':
        return 'Ton professionnel';
      case 'friendly':
        return 'Ton amical';
      case 'concise':
        return 'Réponse concise';
      default:
        return type.isEmpty ? 'Suggestions' : type;
    }
  }

  /// Regroupe par catégorie métier si fournie, sinon par type de ton (formel / amical / concis).
  List<MapEntry<String, List<ResponseSuggestion>>> _groupedSuggestions() {
    final map = <String, List<ResponseSuggestion>>{};
    for (final s in _suggestions) {
      final key = (s.category != null && s.category!.trim().isNotEmpty)
          ? s.category!.trim()
          : _typeSectionLabel(s.type);
      map.putIfAbsent(key, () => []).add(s);
    }
    final keys = map.keys.toList()..sort();
    return keys.map((k) => MapEntry(k, map[k]!)).toList();
  }

  Widget _mailMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.email;
    final isAutoReply = email.category == 'auto_reply' || email.category == 'auto_reply_pending';

    return Scaffold(
      appBar: AppBar(
        title: Text(email.subject, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Supprimer'),
                  content: const Text('Voulez-vous vraiment supprimer cet email ?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) {
                await EchoService.deleteEmail(email.id, token: widget.token);
                if (mounted) {
                  widget.onReply();
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ============================================================
                  // SI C'EST UNE RÉPONSE AUTO (AFFICHER JUSTE LA RÉPONSE)
                  // ============================================================
                  if (isAutoReply) ...[
                    const Text(
                      '🤖 Réponse automatique',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.isPending)
                            Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.timer, size: 16, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Text(
                                    '⏰ Envoi automatique dans ${widget.remainingMinutes.toStringAsFixed(0)} minute${widget.remainingMinutes > 1 ? 's' : ''}',
                                    style: const TextStyle(color: Colors.orange),
                                  ),
                                ],
                              ),
                            ),
                          Text(
                            email.content,
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Cordialement,\nAgent Echo',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
                  // ============================================================
                  // SI C'EST UN EMAIL ORIGINAL (AFFICHER L'ANALYSE COMPLÈTE)
                  // ============================================================
                  else ...[
                    // Badge d'attente si réponse planifiée
                    if (widget.isPending)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '⏰ Réponse automatique planifiée - Envoi dans ${widget.remainingMinutes.toStringAsFixed(0)} minute${widget.remainingMinutes > 1 ? 's' : ''}',
                                style: const TextStyle(color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Expéditeur
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: _getSenderColor(email.sender),
                          child: Text(
                            email.sender[0].toUpperCase(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
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

                    // Badge urgence
                    if (email.isUrgent)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                        child: const Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '⚠️ Message urgent - À traiter immédiatement',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Message original
                    const Text('📧 Message original', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                      child: Text(email.content, style: const TextStyle(fontSize: 14, height: 1.4)),
                    ),
                    const SizedBox(height: 20),

                    // Analyse intelligente
                    const Text('🔍 Analyse intelligente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('📝 Résumé', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(email.summary),
                          const SizedBox(height: 12),
                          if (email.actions.isNotEmpty) ...[
                            const Text('✅ Actions recommandées', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 8),
                            ...email.actions.map((action) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  const Text('• ', style: TextStyle(fontSize: 14)),
                                  Expanded(child: Text(action)),
                                ],
                              ),
                            )),
                            const SizedBox(height: 12),
                          ],
                          Row(
                            children: [
                              const Text('⭐ Priorité : ', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                              Text(_getPriorityText(email.priority), style: TextStyle(color: _getPriorityColor(email.priority), fontWeight: FontWeight.w500)),
                            ],
                          ),
                          if (email.category.isNotEmpty && email.category != 'auto_reply_pending') ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text('📂 Catégorie : ', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                                Text(email.category),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Zone de réponse façon client mail (pas pour spam ni brouillon auto)
          if (!isAutoReply && !email.isSpam)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_showSuggestions && _suggestions.isNotEmpty) ...[
                      const Text(
                        'Suggestions par catégorie',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._groupedSuggestions().map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.deepPurple.shade700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ...entry.value.map((suggestion) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Material(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      child: InkWell(
                                        onTap: () => _selectSuggestion(suggestion),
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: Colors.deepPurple.shade100),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    _getSuggestionIcon(suggestion.type),
                                                    size: 14,
                                                    color: Colors.deepPurple,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      suggestion.title,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 12,
                                                        color: Colors.deepPurple,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                suggestion.content,
                                                style: const TextStyle(fontSize: 12, height: 1.35),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.reply, size: 18, color: Colors.black54),
                                const SizedBox(width: 8),
                                const Text(
                                  'Répondre',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: _isExtractingTasks
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
                                        )
                                      : Icon(Icons.task_alt, color: Colors.orange.shade700, size: 22),
                                  onPressed: _isExtractingTasks ? null : _extractTasks,
                                  tooltip: 'Extraire les tâches',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                ),
                                IconButton(
                                  icon: _isLoadingSuggestions
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.deepPurple),
                                        )
                                      : Icon(Icons.lightbulb_outline, color: Colors.deepPurple.shade700, size: 22),
                                  onPressed: _isLoadingSuggestions ? null : _loadResponseSuggestions,
                                  tooltip: 'Suggestions intelligentes',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            _mailMetaRow('De', 'hera@e-team.com'),
                            _mailMetaRow('À', email.sender),
                            _mailMetaRow('Objet', email.subject.startsWith('Re:') ? email.subject : 'Re: ${email.subject}'),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _replyController,
                              minLines: 5,
                              maxLines: 12,
                              keyboardType: TextInputType.multiline,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                hintText: 'Corps du message…',
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.deepPurple, width: 1.2),
                                ),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.icon(
                                onPressed: _isReplying ? null : _sendReply,
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                                icon: _isReplying
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.send, size: 18),
                                label: Text(_isReplying ? 'Envoi…' : 'Envoyer la réponse'),
                              ),
                            ),
                          ],
                        ),
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

  String _formatDateTime(DateTime time) {
    return '${time.day}/${time.month}/${time.year} à ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  IconData _getSuggestionIcon(String type) {
    switch (type) {
      case 'formal':
        return Icons.business;
      case 'friendly':
        return Icons.sentiment_satisfied;
      case 'concise':
        return Icons.short_text;
      default:
        return Icons.message;
    }
  }
}