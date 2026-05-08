import 'dart:math' as math;

import 'package:flutter/material.dart';

class HeraVoiceTheme {
  const HeraVoiceTheme._();

  static const bg = Color(0xFF050505);
  static const accent = Color(0xFFB57BFF);
  static const textPrimary = Colors.white;
}

class HeraVoiceMessage {
  final String text;
  final bool isUser;

  HeraVoiceMessage({required this.text, required this.isUser});
}

class HeraVoiceBackground extends StatelessWidget {
  const HeraVoiceBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _LinesPainter(), size: Size.infinite);
  }
}

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

class HeraVoiceOrbStage extends StatelessWidget {
  const HeraVoiceOrbStage({
    super.key,
    required this.pulseController,
    required this.floatController,
    required this.pulseAnimation,
    required this.floatAnimation,
  });

  final AnimationController pulseController;
  final AnimationController floatController;
  final Animation<double> pulseAnimation;
  final Animation<double> floatAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([pulseController, floatController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, floatAnimation.value),
          child: Transform.scale(scale: pulseAnimation.value, child: child),
        );
      },
      child: const HeraOrb(),
    );
  }
}

class HeraVoiceTranscript extends StatelessWidget {
  const HeraVoiceTranscript({
    super.key,
    required this.messages,
    required this.accent,
  });

  final List<HeraVoiceMessage> messages;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      height: messages.isEmpty ? 0 : 170,
      width: double.infinity,
      child: messages.isEmpty
          ? const SizedBox.shrink()
          : Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return Align(
                    alignment: msg.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      constraints: const BoxConstraints(maxWidth: 260),
                      decoration: BoxDecoration(
                        color: msg.isUser
                            ? accent
                            : Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        msg.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class HeraVoiceTextInputPanel extends StatelessWidget {
  const HeraVoiceTextInputPanel({
    super.key,
    required this.show,
    required this.controller,
    required this.onSend,
  });

  final bool show;
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 220),
      offset: show ? Offset.zero : const Offset(0, 1),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: show ? 1 : 0,
        child: show
            ? Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: HeraVoiceTheme.accent.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          inputDecorationTheme: const InputDecorationTheme(
                            filled: false,
                            fillColor: Colors.transparent,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                        child: TextField(
                          controller: controller,
                          autofocus: true,
                          cursorColor: Colors.white,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Écrire un message à Hera...',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.38),
                            ),
                          ),
                          onSubmitted: (_) => onSend(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: onSend,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: HeraVoiceTheme.accent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
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

class HeraOrb extends StatelessWidget {
  const HeraOrb({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: HeraVoiceTheme.accent.withValues(alpha: 0.18),
                  blurRadius: 60,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
          Container(
            width: 214,
            height: 214,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF7B4FD4),
                  HeraVoiceTheme.accent,
                  Color(0xFFD4A8FF),
                  Color(0xFF7B4FD4),
                  Color(0xFF3A1F6E),
                  Color(0xFF1A1A2E),
                ],
              ),
            ),
          ),
          Container(
            width: 194,
            height: 194,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.35),
                  HeraVoiceTheme.accent.withValues(alpha: 0.50),
                  const Color(0xFF080808),
                ],
                stops: const [0.0, 0.38, 1.0],
              ),
            ),
          ),
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  HeraVoiceTheme.accent.withValues(alpha: 0.80),
                  const Color(0xFF6B3FA0).withValues(alpha: 0.60),
                  Colors.black,
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = HeraVoiceTheme.accent.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width * 0.74, size.height * 0.14);

    for (double r = 30; r < 180; r += 18) {
      final path = Path();
      for (double a = 0; a <= math.pi * 2; a += 0.12) {
        final wobble = math.sin(a * 3) * 4 + math.cos(a * 5) * 2;
        final x = center.dx + math.cos(a) * (r + wobble);
        final y = center.dy + math.sin(a) * (r + wobble);
        if (a == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
