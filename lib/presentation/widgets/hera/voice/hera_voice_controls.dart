import 'package:flutter/material.dart';

import 'package:e_team/presentation/widgets/hera/voice/hera_voice_theme.dart';

class HeraVoiceTopBar extends StatelessWidget {
  const HeraVoiceTopBar({
    super.key,
    required this.statusText,
    required this.onBack,
  });

  final String statusText;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final textSecondary = Colors.white.withValues(alpha: 0.65);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      child: Row(
        children: [
          HeraVoiceCircleButton(icon: Icons.arrow_back_rounded, onTap: onBack),
          const Spacer(),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: HeraVoiceTheme.accent.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Hera Voice',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                statusText,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 46),
        ],
      ),
    );
  }
}

class HeraVoiceControls extends StatelessWidget {
  const HeraVoiceControls({
    super.key,
    required this.isActive,
    required this.onToggleText,
    required this.onToggleListening,
    required this.onClose,
  });

  final bool isActive;
  final VoidCallback onToggleText;
  final VoidCallback onToggleListening;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HeraVoiceCircleButton(
          icon: Icons.chat_bubble_outline_rounded,
          onTap: onToggleText,
          size: 52,
        ),
        const SizedBox(width: 26),
        GestureDetector(
          onTap: onToggleListening,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: HeraVoiceTheme.accent,
              boxShadow: [
                BoxShadow(
                  color: HeraVoiceTheme.accent.withValues(
                    alpha: isActive ? 0.55 : 0.30,
                  ),
                  blurRadius: isActive ? 34 : 22,
                  spreadRadius: isActive ? 4 : 0,
                ),
              ],
            ),
            child: Icon(
              isActive ? Icons.graphic_eq_rounded : Icons.mic_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ),
        const SizedBox(width: 26),
        HeraVoiceCircleButton(
          icon: Icons.close_rounded,
          onTap: onClose,
          size: 52,
        ),
      ],
    );
  }
}

class HeraVoiceCircleButton extends StatelessWidget {
  const HeraVoiceCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 46,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Icon(icon, color: Colors.white70, size: 22),
      ),
    );
  }
}
