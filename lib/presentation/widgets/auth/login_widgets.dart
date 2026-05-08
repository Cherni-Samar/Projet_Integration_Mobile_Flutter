import 'dart:math' as math;

import 'package:e_team/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class LoginGlowBackground extends StatelessWidget {
  const LoginGlowBackground({
    super.key,
    required this.glowController,
    required this.isDark,
  });

  final AnimationController glowController;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -100,
      right: -100,
      child: AnimatedBuilder(
        animation: glowController,
        builder: (context, child) {
          return Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFCDFF00).withValues(
                    alpha: isDark ? 0.15 : 0.08 + glowController.value * 0.04,
                  ),
                  Colors.transparent,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key, required this.isDark, required this.progress});

  final bool isDark;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFFCDFF00), Color(0xFFAADD00)],
                )
              : const LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A)]),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0xFFCDFF00).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: CustomPaint(
          size: const Size(50, 50),
          painter: NeuralCorePainter(progress: progress, isDark: isDark),
        ),
      ),
    );
  }
}

class LoginTextField extends StatelessWidget {
  const LoginTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.isFocused,
    required this.onFocusChange,
    required this.isDark,
    this.isPassword = false,
    this.obscurePassword = false,
    this.onTogglePassword,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isFocused;
  final Function(bool) onFocusChange;
  final bool isDark;
  final bool isPassword;
  final bool obscurePassword;
  final VoidCallback? onTogglePassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: onFocusChange,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isFocused
                ? (isDark
                      ? const Color(0xFFCDFF00)
                      : Colors.black.withValues(alpha: 0.3))
                : (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.transparent),
            width: isFocused ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isFocused
                  ? (isDark
                        ? const Color(0xFFCDFF00).withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.06))
                  : (isDark
                        ? Colors.transparent
                        : Colors.black.withValues(alpha: 0.03)),
              blurRadius: isFocused ? 15 : 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          obscureText: isPassword ? obscurePassword : false,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.3),
              fontWeight: FontWeight.w400,
            ),
            labelStyle: TextStyle(
              color: isFocused
                  ? (isDark
                        ? const Color(0xFFCDFF00)
                        : Colors.black.withValues(alpha: 0.7))
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.4)),
              fontWeight: FontWeight.w500,
            ),
            floatingLabelStyle: TextStyle(
              color: isDark ? const Color(0xFFCDFF00) : Colors.black,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(
              icon,
              color: isFocused
                  ? (isDark
                        ? const Color(0xFFCDFF00)
                        : Colors.black.withValues(alpha: 0.6))
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.3)),
              size: 22,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.4)
                          : Colors.black.withValues(alpha: 0.3),
                      size: 22,
                    ),
                    onPressed: onTogglePassword,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
          ),
          validator: validator,
        ),
      ),
    );
  }
}

class LoginRememberForgotRow extends StatelessWidget {
  const LoginRememberForgotRow({
    super.key,
    required this.rememberMe,
    required this.onRememberChanged,
    required this.onForgotPassword,
    required this.isDark,
    required this.l10n,
  });

  final bool rememberMe;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onForgotPassword;
  final bool isDark;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: rememberMe,
                onChanged: onRememberChanged,
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF8B5CF6);
                  }
                  return null;
                }),
                checkColor: Colors.white,
                side: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.authRememberMe,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.black.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: onForgotPassword,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            l10n.authForgotPassword,
            style: const TextStyle(
              color: Color(0xFF8B5CF6),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class LoginSubmitButton extends StatelessWidget {
  const LoginSubmitButton({
    super.key,
    required this.isDark,
    required this.isLoading,
    required this.onPressed,
    required this.l10n,
  });

  final bool isDark;
  final bool isLoading;
  final VoidCallback onPressed;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? const Color(0xFFCDFF00) : Colors.black,
          foregroundColor: isDark ? Colors.black : const Color(0xFFCDFF00),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: isDark ? 8 : 0,
          shadowColor: isDark
              ? const Color(0xFFCDFF00).withValues(alpha: 0.5)
              : null,
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? Colors.black : const Color(0xFFCDFF00),
                  ),
                ),
              )
            : Text(
                l10n.authSignIn,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}

class LoginSignupPrompt extends StatelessWidget {
  const LoginSignupPrompt({
    super.key,
    required this.isDark,
    required this.onSignup,
    required this.l10n,
  });

  final bool isDark;
  final VoidCallback onSignup;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.authNewHere,
          style: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.black.withValues(alpha: 0.5),
            fontSize: 15,
          ),
        ),
        GestureDetector(
          onTap: onSignup,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFFCDFF00).withValues(alpha: 0.2)
                  : const Color(0xFFCDFF00).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              l10n.authCreateAccount,
              style: TextStyle(
                color: isDark ? const Color(0xFFCDFF00) : Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NeuralCorePainter extends CustomPainter {
  final double progress;
  final bool isDark;

  NeuralCorePainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final centerPaint = Paint()
      ..color = isDark ? Colors.black : const Color(0xFFCDFF00)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 6, centerPaint);

    final linePaint = Paint()
      ..color = isDark
          ? Colors.black.withValues(alpha: 0.6)
          : const Color(0xFFCDFF00).withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final nodePaint = Paint()
      ..color = isDark ? Colors.black : const Color(0xFFCDFF00)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 6; i++) {
      final angle = (i / 6) * math.pi * 2 + progress * math.pi * 0.5;
      final radius = 18 + math.sin(progress * math.pi * 2) * 2;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;

      final lineOpacity =
          0.3 + (math.sin(progress * math.pi * 2 + i) + 1) / 2 * 0.4;
      canvas.drawLine(
        Offset(x, y),
        center,
        linePaint
          ..color = isDark
              ? Colors.black.withValues(alpha: lineOpacity)
              : const Color(0xFFCDFF00).withValues(alpha: lineOpacity),
      );

      final nodeSize = 2.5 + math.sin(progress * math.pi * 2 + i * 0.5) * 0.8;
      canvas.drawCircle(Offset(x, y), nodeSize.abs(), nodePaint);
    }

    final outerPaint = Paint()
      ..color = isDark
          ? Colors.black.withValues(alpha: 0.2 + progress * 0.2)
          : const Color(0xFFCDFF00).withValues(alpha: 0.2 + progress * 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, 24 + progress * 3, outerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
