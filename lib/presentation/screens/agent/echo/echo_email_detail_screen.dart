import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:e_team/data/services/echo_service.dart';
import 'package:e_team/domain/models/echo_models.dart';

class EchoEmailDetailScreen extends StatefulWidget {
  final EmailItem email;
  final String? token;
  final bool isPending;
  final double remainingMinutes;
  final VoidCallback onReply;
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
  // Couleurs Thème Pro
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _violet = Color(0xFF6366F1);
  static const Color _border = Color(0xFFF1F5F9);
  static const Color _textMain = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final email = widget.email;
    final isFromHera = email.sender.contains('hera@e-team.com');

    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. OBJET DU MAIL
            Text(
              email.subject,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _textMain,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),

            // 2. HEADER EXPÉDITEUR
            _buildSenderHeader(email, isFromHera),
            const Divider(height: 48, color: _border),

            // 3. SMART INSIGHT (AI SUMMARY)
            _buildAISmartCard(email),
            const SizedBox(height: 32),

            // 4. CORPS DU MESSAGE
            _buildMessageBody(email),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _bg,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: _textMain,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.archive_outlined, size: 22, color: _textMuted),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(
            Icons.delete_outline_rounded,
            size: 22,
            color: Colors.redAccent,
          ),
          onPressed: _showDeleteDialog,
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildSenderHeader(EmailItem email, bool isFromHera) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: isFromHera ? _violet : _getSenderColor(email.sender),
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
                  color: isFromHera ? _violet : _textMain,
                ),
              ),
              Text(
                DateFormat('EEEE, d MMM • HH:mm').format(email.receivedAt),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: _textMuted,
                ),
              ),
            ],
          ),
        ),
        if (email.isUrgent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
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

  Widget _buildAISmartCard(EmailItem email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _violet.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_outlined, color: _violet, size: 18),
              const SizedBox(width: 8),
              Text(
                'ECHO INTELLIGENCE',
                style: GoogleFonts.plusJakartaSans(
                  color: _violet,
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
              color: _textMain,
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
              children: email.actions.map((a) => _buildActionChip(a)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
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
              color: _textMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBody(EmailItem email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ORIGINAL MESSAGE',
          style: GoogleFonts.plusJakartaSans(
            color: _textMuted,
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
            color: _textMain.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Email'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await EchoService.deleteEmail(widget.email.id, token: widget.token);
      if (mounted) {
        widget.onReply();
        Navigator.pop(context);
      }
    }
  }

  Color _getSenderColor(String sender) {
    final colors = [
      Color(0xFF3B82F6),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFF8B5CF6),
    ];
    return colors[sender.length % colors.length];
  }
}
