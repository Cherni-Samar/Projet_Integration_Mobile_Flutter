import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:e_team/domain/models/echo/echo_models.dart';

class EchoEmailDetailColors {
  static const bg = Color(0xFFFFFFFF);
  static const violet = Color(0xFF6366F1);
  static const border = Color(0xFFF1F5F9);
  static const textMain = Color(0xFF0F172A);
  static const textMuted = Color(0xFF64748B);
}

class EchoEmailDetailAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onDelete;

  const EchoEmailDetailAppBar({super.key, required this.onDelete});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: EchoEmailDetailColors.bg,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: EchoEmailDetailColors.textMain,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.archive_outlined,
            size: 22,
            color: EchoEmailDetailColors.textMuted,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(
            Icons.delete_outline_rounded,
            size: 22,
            color: Colors.redAccent,
          ),
          onPressed: onDelete,
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}

class EchoEmailSenderHeader extends StatelessWidget {
  final EmailItem email;

  const EchoEmailSenderHeader({super.key, required this.email});

  Color _getSenderColor(String sender) {
    final colors = [
      Color(0xFF3B82F6),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFF8B5CF6),
    ];
    return colors[sender.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final isFromHera = email.sender.contains('hera@e-team.com');

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: isFromHera
              ? EchoEmailDetailColors.violet
              : _getSenderColor(email.sender),
          child: Icon(
            isFromHera ? Icons.auto_awesome : Icons.person,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFromHera ? 'HERA SYSTEM ADVISOR' : email.sender,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isFromHera
                      ? EchoEmailDetailColors.violet
                      : EchoEmailDetailColors.textMain,
                ),
              ),
              Text(
                DateFormat('EEEE, d MMM • HH:mm').format(email.receivedAt),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: EchoEmailDetailColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        if (email.isUrgent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'URGENT',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.red,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class EchoEmailAiSmartCard extends StatelessWidget {
  final EmailItem email;

  const EchoEmailAiSmartCard({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: EchoEmailDetailColors.violet.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.psychology_outlined,
                color: EchoEmailDetailColors.violet,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'ECHO INTELLIGENCE',
                style: GoogleFonts.plusJakartaSans(
                  color: EchoEmailDetailColors.violet,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            email.summary,
            style: GoogleFonts.plusJakartaSans(
              color: EchoEmailDetailColors.textMain,
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (email.actions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: email.actions
                  .map((action) => EchoEmailActionChip(text: action))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class EchoEmailActionChip extends StatelessWidget {
  final String text;

  const EchoEmailActionChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EchoEmailDetailColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 12,
            color: Colors.green,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: EchoEmailDetailColors.textMain,
            ),
          ),
        ],
      ),
    );
  }
}

class EchoEmailMessageBody extends StatelessWidget {
  final EmailItem email;

  const EchoEmailMessageBody({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ORIGINAL MESSAGE',
          style: GoogleFonts.plusJakartaSans(
            color: EchoEmailDetailColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          email.content,
          style: GoogleFonts.inter(
            fontSize: 15,
            height: 1.7,
            color: EchoEmailDetailColors.textMain.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}
