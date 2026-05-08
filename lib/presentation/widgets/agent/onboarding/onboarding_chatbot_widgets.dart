import 'package:e_team/domain/models/dexo/dexo_onboarding_models.dart';
import 'package:e_team/presentation/widgets/dexo/organization_blueprint_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingChatbotTheme {
  const OnboardingChatbotTheme._();

  static const primary = Color(0xFFCDFF00);
  static const dark = Color(0xFF0A0A0A);
  static const bg = Color(0xFFFFFFFF);
  static const botBubble = Color(0xFFF8FAFC);
  static const border = Color(0xFFE5E7EB);
  static const textMain = Color(0xFF0F172A);
  static const textMuted = Color(0xFF64748B);
  static const green = Color(0xFF22C55E);
}

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

class OnboardingTypingIndicator extends StatelessWidget {
  const OnboardingTypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: OnboardingChatbotTheme.botBubble,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: OnboardingChatbotTheme.border,
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _DotDelay(delay: 0),
              const SizedBox(width: 4),
              const _DotDelay(delay: 150),
              const SizedBox(width: 4),
              const _DotDelay(delay: 300),
              const SizedBox(width: 10),
              Text(
                'Dexo is analyzing your company...',
                style: GoogleFonts.plusJakartaSans(
                  color: OnboardingChatbotTheme.textMuted,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

class _DotDelay extends StatefulWidget {
  final int delay;

  const _DotDelay({required this.delay});

  @override
  State<_DotDelay> createState() => _DotDelayState();
}

class _DotDelayState extends State<_DotDelay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _opacity = Tween<double>(begin: 0.25, end: 1).animate(_controller);

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: OnboardingChatbotTheme.textMuted,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
