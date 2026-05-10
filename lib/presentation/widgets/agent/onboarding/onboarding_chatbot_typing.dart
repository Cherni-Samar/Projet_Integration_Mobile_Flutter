import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:e_team/presentation/widgets/agent/onboarding/onboarding_chatbot_theme.dart';

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

class _DotDelay extends StatefulWidget {
  const _DotDelay({required this.delay});

  final int delay;

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
