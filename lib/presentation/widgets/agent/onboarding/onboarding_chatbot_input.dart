import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:e_team/presentation/widgets/agent/onboarding/onboarding_chatbot_theme.dart';

class OnboardingInputBar extends StatelessWidget {
  const OnboardingInputBar({
    super.key,
    required this.controller,
    required this.hasBlueprint,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool hasBlueprint;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: OnboardingChatbotTheme.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !hasBlueprint,
              minLines: 1,
              maxLines: 4,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: OnboardingChatbotTheme.textMain,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hasBlueprint
                    ? 'Blueprint generated'
                    : 'Describe your company...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: OnboardingChatbotTheme.textMuted,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: OnboardingChatbotTheme.botBubble,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 13,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: hasBlueprint
                    ? OnboardingChatbotTheme.textMuted
                    : OnboardingChatbotTheme.dark,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: OnboardingChatbotTheme.dark.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: OnboardingChatbotTheme.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
