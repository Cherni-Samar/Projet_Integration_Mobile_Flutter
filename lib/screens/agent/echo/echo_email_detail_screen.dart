import 'package:flutter/material.dart';
import '../../../services/echo_service.dart';

class EchoEmailDetailScreen extends StatefulWidget {
  final EmailItem email;
  final String? token;
  final bool isPending;
  final double remainingMinutes;
  final VoidCallback onReply;

  const EchoEmailDetailScreen({
    super.key,
    required this.email,
    this.token,
    required this.isPending,
    required this.remainingMinutes,
    required this.onReply,
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
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Réponse envoyée'), backgroundColor: Colors.green),
        );
        widget.onReply();
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

          // Zone de réponse (seulement pour les emails originaux)
          if (!isAutoReply)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, -2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Suggestions de réponses
                  if (_showSuggestions && _suggestions.isNotEmpty) ...[
                    const Text(
                      '💡 Suggestions de réponses',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...(_suggestions.map((suggestion) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => _selectSuggestion(suggestion),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.deepPurple.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _getSuggestionIcon(suggestion.type),
                                    size: 16,
                                    color: Colors.deepPurple,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    suggestion.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.touch_app,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                suggestion.content,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ))),
                    const SizedBox(height: 16),
                  ],
                  
                  // Boutons d'action
                  Row(
                    children: [
                      // Bouton extraction de tâches
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: _isExtractingTasks
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
                                )
                              : const Icon(Icons.task_alt, color: Colors.orange),
                          onPressed: _isExtractingTasks ? null : _extractTasks,
                          tooltip: 'Extraire tâches',
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // Bouton suggestions
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: _isLoadingSuggestions
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.deepPurple),
                                )
                              : const Icon(Icons.lightbulb_outline, color: Colors.deepPurple),
                          onPressed: _isLoadingSuggestions ? null : _loadResponseSuggestions,
                          tooltip: 'Proposer réponses automatiques',
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Champ de texte
                      Expanded(
                        child: TextField(
                          controller: _replyController,
                          maxLines: 3,
                          minLines: 1,
                          decoration: InputDecoration(
                            hintText: 'Écrivez votre réponse...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Bouton envoyer
                      Container(
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.deepPurple),
                        child: IconButton(
                          icon: _isReplying
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.send, color: Colors.white),
                          onPressed: _isReplying ? null : _sendReply,
                        ),
                      ),
                    ],
                  ),
                ],
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