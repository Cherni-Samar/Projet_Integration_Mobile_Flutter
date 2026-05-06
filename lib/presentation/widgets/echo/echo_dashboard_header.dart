import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'echo_theme.dart';

/// Professional header for Echo dashboard with avatar, status, and metrics
class EchoDashboardHeader extends StatelessWidget {
  final AnimationController pulseController;
  final int totalProcessed;
  final int alertsCount;
  final int postsCount;
  final VoidCallback onBackPressed;

  const EchoDashboardHeader({
    Key? key,
    required this.pulseController,
    required this.totalProcessed,
    required this.alertsCount,
    required this.postsCount,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: EchoTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EchoTheme.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: EchoTheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header avec bouton retour
          Row(
            children: [
              // Bouton de retour
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: EchoTheme.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: EchoTheme.border, width: 0.5),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                  color: EchoTheme.textMain,
                  onPressed: onBackPressed,
                ),
              ),
              const SizedBox(width: 16),
              _buildStaticAvatar(),
              const SizedBox(width: 20),
              Expanded(
                // Garde le Expanded ici
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ECHO BRAIN',
                      style: GoogleFonts.inter(
                        color: EchoTheme.textMain,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // ✅ PULSATION ANIMATION
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Color(0xFFFF00DD).withValues(
                                  alpha: 0.4 + 0.6 * pulseController.value,
                                ),
                                shape: BoxShape.circle,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'COMMUNICATION AGENT ONLINE',
                            style: GoogleFonts.inter(
                              color: Color(0xFF9C27B0),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStaticStatusBar(),
        ],
      ),
    );
  }

  Widget _buildStaticAvatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: EchoTheme.violet, width: 2),
        boxShadow: [
          BoxShadow(
            color: EchoTheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Image.asset(
          'assets/images/voxi.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: EchoTheme.violet.withValues(alpha: 0.1),
              ),
              child: Icon(Icons.psychology, color: EchoTheme.violet, size: 24),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStaticStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: EchoTheme.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EchoTheme.border, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _buildStatusMetric(
              'MESSAGES',
              '$totalProcessed',
              Icons.email_outlined,
              EchoTheme.violet,
            ),
          ),
          Container(width: 1, height: 30, color: EchoTheme.border),
          Container(width: 1, height: 30, color: EchoTheme.border),
          Expanded(
            child: _buildStatusMetric(
              'ALERTS',
              '$alertsCount',
              Icons.timeline_outlined,
              Colors.orangeAccent,
            ),
          ),
          Container(width: 1, height: 30, color: EchoTheme.border),
          Expanded(
            child: _buildStatusMetric(
              'POSTS',
              '$postsCount',
              Icons.article_outlined,
              EchoTheme.violet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMetric(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            color: EchoTheme.textMain,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            color: EchoTheme.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
