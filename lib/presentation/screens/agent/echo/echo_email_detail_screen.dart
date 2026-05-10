import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:e_team/data/services/echo_service.dart';
import 'package:e_team/domain/models/echo/echo_models.dart';
import 'package:e_team/presentation/widgets/echo/email_detail/echo_email_detail_widgets.dart';

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
  @override
  Widget build(BuildContext context) {
    final email = widget.email;

    return Scaffold(
      backgroundColor: EchoEmailDetailColors.bg,
      appBar: EchoEmailDetailAppBar(onDelete: _showDeleteDialog),
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
                color: EchoEmailDetailColors.textMain,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            EchoEmailSenderHeader(email: email),
            const Divider(height: 48, color: EchoEmailDetailColors.border),
            EchoEmailAiSmartCard(email: email),
            const SizedBox(height: 32),
            EchoEmailMessageBody(email: email),
            const SizedBox(height: 40),
          ],
        ),
      ),
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
}
