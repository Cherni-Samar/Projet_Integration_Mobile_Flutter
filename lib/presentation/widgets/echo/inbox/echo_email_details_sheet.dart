import 'package:flutter/material.dart';

import 'package:e_team/domain/models/echo/echo_models.dart';
import 'package:e_team/presentation/widgets/echo/inbox/echo_inbox_helpers.dart';

class EchoEmailDetailsSheet extends StatelessWidget {
  final EmailItem email;
  final VoidCallback onDelete;

  const EchoEmailDetailsSheet({
    super.key,
    required this.email,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
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
              title: Text(email.subject, style: const TextStyle(fontSize: 16)),
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
                  onPressed: onDelete,
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _EmailDetailsHeader(email: email),
                  const SizedBox(height: 20),
                  if (email.isUrgent) const _UrgentWarning(),
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
                  _BoxText(text: email.content),
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
                  _AnalysisBox(email: email),
                  const SizedBox(height: 30),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmailDetailsHeader extends StatelessWidget {
  final EmailItem email;

  const _EmailDetailsHeader({required this.email});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: echoSenderColor(email.sender),
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
                echoFormatDateTime(email.receivedAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UrgentWarning extends StatelessWidget {
  const _UrgentWarning();

  @override
  Widget build(BuildContext context) {
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
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoxText extends StatelessWidget {
  final String text;

  const _BoxText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14, height: 1.4)),
    );
  }
}

class _AnalysisBox extends StatelessWidget {
  final EmailItem email;

  const _AnalysisBox({required this.email});

  @override
  Widget build(BuildContext context) {
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
                echoPriorityText(email.priority),
                style: TextStyle(
                  color: echoPriorityColor(email.priority),
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
}
