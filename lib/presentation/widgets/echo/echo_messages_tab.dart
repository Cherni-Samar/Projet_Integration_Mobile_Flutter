import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:e_team/domain/models/echo_models.dart';
import 'echo_theme.dart';
import 'package:e_team/presentation/screens/agent/echo/echo_email_detail_screen.dart';

/// Messages tab for Echo dashboard showing received and sent emails
class EchoMessagesTab extends StatelessWidget {
  final bool loadingEmails;
  final List<EmailItem> emails;
  final bool showOnlyUrgent;
  final bool showOnlySpam;
  final int emailSubTab;
  final Function(int) onSubTabChanged;
  final Future<void> Function(EmailItem) onMarkAsRead;
  final VoidCallback onReply;
  final VoidCallback onAfterReply;
  final Widget Function(String message, IconData icon) buildEmptyState;
  final String? token;

  const EchoMessagesTab({
    Key? key,
    required this.loadingEmails,
    required this.emails,
    required this.showOnlyUrgent,
    required this.showOnlySpam,
    required this.emailSubTab,
    required this.onSubTabChanged,
    required this.onMarkAsRead,
    required this.onReply,
    required this.onAfterReply,
    required this.buildEmptyState,
    this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildEmailControls(),
        _buildEmailSubTabs(),
        Expanded(child: _buildEmailList(context)),
      ],
    );
  }

  Widget _buildEmailControls() {
    return const SizedBox.shrink();
  }

  Widget _buildEmailSubTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: EchoTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EchoTheme.border, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onSubTabChanged(0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: emailSubTab == 0
                      ? EchoTheme.violet
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '📥 RECEIVED',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: emailSubTab == 0
                        ? Colors.white
                        : EchoTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onSubTabChanged(1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: emailSubTab == 1
                      ? EchoTheme.violet
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '📤 SENT',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: emailSubTab == 1
                        ? Colors.white
                        : EchoTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailList(BuildContext context) {
    if (loadingEmails) {
      return const Center(
        child: CircularProgressIndicator(color: EchoTheme.violet),
      );
    }

    final receivedEmails = emails.where((email) {
      if (showOnlyUrgent && !email.isUrgent) return false;
      if (showOnlySpam) {
        if (!email.isSpam) return false;
      } else if (email.isSpam) {
        return false;
      }
      if (email.category == 'auto_reply' ||
          email.category == 'auto_reply_pending')
        return false;
      if (email.sender == 'echo@e-team.com') return false;
      return true;
    }).toList();

    final sentEmails = emails.where((email) {
      if (email.sender == 'echo@e-team.com') return true;
      if (email.category == 'auto_reply' ||
          email.category == 'auto_reply_pending')
        return true;
      return false;
    }).toList();

    final emailsToShow = emailSubTab == 0 ? receivedEmails : sentEmails;

    if (emailsToShow.isEmpty) {
      return buildEmptyState(
        emailSubTab == 0 ? 'No received emails' : 'No sent emails',
        Icons.inbox_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: emailsToShow.length,
      itemBuilder: (context, index) =>
          _buildEmailCard(context, emailsToShow[index]),
    );
  }

  Widget _buildEmailCard(BuildContext context, EmailItem email) {
    final bool isFromHera = email.sender.contains('hera@e-team.com');
    final bool isUnread = !email.isRead;

    return GestureDetector(
      // Dans _buildEmailCard, remplace la partie onTap :
      onTap: () async {
        await onMarkAsRead(email);
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EchoEmailDetailScreen(
                email: email,
                token: token,
                // ✅ AJOUTE CES DEUX LIGNES POUR RÉPARER L'ERREUR
                isPending: false,
                remainingMinutes: 0,
                onReply: onReply,
                onAfterReply: onAfterReply,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Fond spécial si c'est une alerte de Hera
          color: isFromHera ? const Color(0xFFFBF4FF) : EchoTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFromHera
                ? EchoTheme.violet.withOpacity(0.3)
                : (email.isUrgent
                      ? Colors.redAccent.withOpacity(0.3)
                      : EchoTheme.border),
            width: isFromHera ? 1 : 0.5,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: isFromHera
                  ? EchoTheme.violet
                  : _getSenderColor(email.sender),
              child: Icon(
                isFromHera ? Icons.bolt : Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFromHera ? "INTERNAL: HERA RH" : email.sender,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isFromHera ? EchoTheme.violet : EchoTheme.textMain,
                    ),
                  ),
                  Text(
                    email.subject,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // BADGE D'INTELLIGENCE ECHO
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: EchoTheme.violet.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "Echo detected: ${email.category}",
                      style: TextStyle(
                        fontSize: 9,
                        color: EchoTheme.violet,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isUnread)
              const Icon(Icons.circle, size: 10, color: EchoTheme.violet),
          ],
        ),
      ),
    );
  }

  Color _getSenderColor(String sender) {
    final colors = [
      Colors.blueAccent,
      EchoTheme.neon,
      Colors.orangeAccent,
      EchoTheme.violet,
      Colors.tealAccent,
      Colors.pinkAccent,
      Colors.indigoAccent,
    ];
    return colors[sender.length % colors.length];
  }
}
