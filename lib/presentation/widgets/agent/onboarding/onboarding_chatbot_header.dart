import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:e_team/presentation/widgets/agent/onboarding/onboarding_chatbot_theme.dart';

class OnboardingChatbotHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const OnboardingChatbotHeader({
    super.key,
    required this.pulseController,
    required this.onBack,
  });

  final AnimationController pulseController;
  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        color: OnboardingChatbotTheme.dark,
        onPressed: onBack,
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: pulseController,
            builder: (_, _) {
              return Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: OnboardingChatbotTheme.green.withValues(
                    alpha: 0.4 + 0.6 * pulseController.value,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: OnboardingChatbotTheme.green.withValues(
                        alpha: 0.25,
                      ),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          Text(
            'DEXO CONSULTATION',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: OnboardingChatbotTheme.dark,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 0.5, color: OnboardingChatbotTheme.border),
      ),
    );
  }
}
