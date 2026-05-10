import 'package:e_team/domain/models/dexo/dexo_onboarding_models.dart';
import 'package:e_team/presentation/widgets/agent/onboarding/onboarding_chatbot_theme.dart';
import 'package:e_team/presentation/widgets/dexo/organization_blueprint_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingChatMessageView extends StatelessWidget {
  const OnboardingChatMessageView({
    super.key,
    required this.message,
    required this.onConfirmBlueprint,
  });

  final ChatMessage message;
  final Future<void> Function(WorkforcePlan plan) onConfirmBlueprint;

  @override
  Widget build(BuildContext context) {
    if (message.type == ChatMessageType.blueprint) {
      final plan = message.blueprintPlan;
      if (plan == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Align(
          alignment: Alignment.centerLeft,
          child: OrganizationBlueprintCard(
            initialPlan: plan,
            onConfirm: onConfirmBlueprint,
          ),
        ),
      );
    }

    final isBot = message.type == ChatMessageType.bot;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Align(
        alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isBot
                ? OnboardingChatbotTheme.botBubble
                : OnboardingChatbotTheme.dark,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isBot ? 4 : 20),
              bottomRight: Radius.circular(isBot ? 20 : 4),
            ),
            border: isBot
                ? Border.all(color: OnboardingChatbotTheme.border, width: 0.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            message.text,
            style: GoogleFonts.plusJakartaSans(
              color: isBot
                  ? OnboardingChatbotTheme.textMain
                  : OnboardingChatbotTheme.primary,
              fontSize: 14,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
