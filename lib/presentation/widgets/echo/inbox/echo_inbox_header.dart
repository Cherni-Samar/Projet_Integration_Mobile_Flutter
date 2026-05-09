import 'package:flutter/material.dart';

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
