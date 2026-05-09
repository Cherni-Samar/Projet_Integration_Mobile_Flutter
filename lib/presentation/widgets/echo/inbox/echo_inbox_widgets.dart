import 'package:flutter/material.dart';

import 'package:e_team/domain/models/echo_models.dart';
import 'package:e_team/presentation/widgets/echo/inbox/echo_inbox_helpers.dart';

class EchoInboxHeader extends StatelessWidget {
  final int pendingCount;
  final int urgentCount;
  final bool showOnlyUrgent;
  final VoidCallback onBack;
  final VoidCallback onRefresh;
  final VoidCallback onPendingTap;
  final VoidCallback onUrgentTap;
  final VoidCallback onSendTap;

  const EchoInboxHeader({
    super.key,
    required this.pendingCount,
    required this.urgentCount,
    required this.showOnlyUrgent,
    required this.onBack,
    required this.onRefresh,
    required this.onPendingTap,
    required this.onUrgentTap,
    required this.onSendTap,
  });

  @override
  Widget build(BuildContext context) {
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
                onTap: onBack,
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
                onTap: onRefresh,
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
                  onTap: onPendingTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: EchoInboxHeaderAction(
                  icon: showOnlyUrgent
                      ? Icons.warning_rounded
                      : Icons.warning_amber_rounded,
                  label: 'Urgent',
                  value: '$urgentCount',
                  color: Colors.red,
                  onTap: onUrgentTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: EchoInboxHeaderAction(
                  icon: Icons.send_rounded,
                  label: 'Send',
                  value: '',
                  color: const Color(0xFF7C3AED),
                  onTap: onSendTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EchoInboxTabs extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onSelect;

  const EchoInboxTabs({
    super.key,
    required this.selectedTab,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _EchoInboxTabButton(
              label: 'Received',
              index: 0,
              selectedTab: selectedTab,
              onSelect: onSelect,
            ),
          ),
          Expanded(
            child: _EchoInboxTabButton(
              label: 'Sent',
              index: 1,
              selectedTab: selectedTab,
              onSelect: onSelect,
            ),
          ),
        ],
      ),
    );
  }
}

class _EchoInboxTabButton extends StatelessWidget {
  final String label;
  final int index;
  final int selectedTab;
  final ValueChanged<int> onSelect;

  const _EchoInboxTabButton({
    required this.label,
    required this.index,
    required this.selectedTab,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final selected = selectedTab == index;

    return GestureDetector(
      onTap: () => onSelect(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
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
}

class EchoInboxHeaderAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const EchoInboxHeaderAction({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.16)),
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
}

class EchoInboxErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const EchoInboxErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}

class EchoInboxEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EchoInboxEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }
}

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
