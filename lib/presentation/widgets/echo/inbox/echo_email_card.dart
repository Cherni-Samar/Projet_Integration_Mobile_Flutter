import 'package:e_team/domain/models/echo_models.dart';
import 'package:e_team/presentation/widgets/echo/inbox/echo_inbox_helpers.dart';
import 'package:flutter/material.dart';

class EchoEmailCard extends StatelessWidget {
  final EmailItem email;
  final PendingItem pendingItem;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const EchoEmailCard({
    super.key,
    required this.email,
    required this.pendingItem,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !email.isRead && !email.isSpam;
    final isPending = pendingItem.emailId.isNotEmpty;
    final isAutoReply =
        email.category == 'auto_reply' ||
        email.category == 'auto_reply_pending';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
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
                backgroundColor: echoSenderColor(email.sender),
                child: Text(
                  email.sender.isNotEmpty ? email.sender[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _EchoEmailInfo(
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
}

class _EchoEmailInfo extends StatelessWidget {
  final EmailItem email;
  final bool isUnread;
  final bool isPending;
  final bool isAutoReply;
  final PendingItem pendingItem;

  const _EchoEmailInfo({
    required this.email,
    required this.isUnread,
    required this.isPending,
    required this.isAutoReply,
    required this.pendingItem,
  });

  @override
  Widget build(BuildContext context) {
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
              echoFormatTime(email.receivedAt),
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
        _EchoEmailTags(
          email: email,
          isPending: isPending,
          isAutoReply: isAutoReply,
          pendingItem: pendingItem,
        ),
      ],
    );
  }
}

class _EchoEmailTags extends StatelessWidget {
  final EmailItem email;
  final bool isPending;
  final bool isAutoReply;
  final PendingItem pendingItem;

  const _EchoEmailTags({
    required this.email,
    required this.isPending,
    required this.isAutoReply,
    required this.pendingItem,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        if (email.isUrgent) const _EchoUrgentChip(),
        if (email.category.isNotEmpty && !email.isSpam && !isAutoReply)
          _EchoTextChip(
            text: email.category,
            bg: Colors.deepPurple.shade50,
            color: Colors.deepPurple.shade700,
          ),
        if (isPending && !isAutoReply)
          _EchoTextChip(
            text: '⏰ ${pendingItem.willSendIn}',
            bg: Colors.orange.shade50,
            color: Colors.orange,
          ),
        if (isAutoReply)
          _EchoTextChip(
            text: '📤 Envoyé',
            bg: Colors.blue.shade50,
            color: Colors.blue,
          ),
      ],
    );
  }
}

class _EchoUrgentChip extends StatelessWidget {
  const _EchoUrgentChip();

  @override
  Widget build(BuildContext context) {
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
}

class _EchoTextChip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color color;

  const _EchoTextChip({
    required this.text,
    required this.bg,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
}
