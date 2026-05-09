import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';

class ForgotPasswordGlow extends StatelessWidget {
  final Animation<double> animation;

  const ForgotPasswordGlow({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -50,
      left: -50,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(
                    0xFF8B5CF6,
                  ).withValues(alpha: 0.08 + animation.value * 0.04),
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

class ForgotPasswordBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ForgotPasswordBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black.withValues(alpha: 0.7),
            size: 18,
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordFormView extends StatelessWidget {
  final AppLocalizations l10n;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final Animation<double> animation;
  final bool isLoading;
  final bool isEmailFocused;
  final ValueChanged<bool> onEmailFocusChanged;
  final VoidCallback onSubmit;
  final VoidCallback onBackToLogin;

  const ForgotPasswordFormView({
    super.key,
    required this.l10n,
    required this.formKey,
    required this.emailController,
    required this.animation,
    required this.isLoading,
    required this.isEmailFocused,
    required this.onEmailFocusChanged,
    required this.onSubmit,
    required this.onBackToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 100),
          ForgotPasswordNeuralIcon(animation: animation),
          const SizedBox(height: 50),
          Text(
            l10n.authForgotPasswordTitle,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.authForgotPasswordSubtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black.withValues(alpha: 0.5),
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 50),
          ForgotPasswordEmailField(
            l10n: l10n,
            controller: emailController,
            isFocused: isEmailFocused,
            onFocusChanged: onEmailFocusChanged,
          ),
          const SizedBox(height: 32),
          ForgotPasswordSubmitButton(
            l10n: l10n,
            isLoading: isLoading,
            onPressed: onSubmit,
          ),
          const SizedBox(height: 32),
          ForgotPasswordBackToLoginLink(l10n: l10n, onPressed: onBackToLogin),
        ],
      ),
    );
  }
}

class ForgotPasswordNeuralIcon extends StatelessWidget {
  final Animation<double> animation;

  const ForgotPasswordNeuralIcon({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: CustomPaint(
              size: const Size(50, 50),
              painter: NeuralCorePainter(
                progress: animation.value,
                color: const Color(0xFF8B5CF6),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ForgotPasswordEmailField extends StatelessWidget {
  final AppLocalizations l10n;
  final TextEditingController controller;
  final bool isFocused;
  final ValueChanged<bool> onFocusChanged;

  const ForgotPasswordEmailField({
    super.key,
    required this.l10n,
    required this.controller,
    required this.isFocused,
    required this.onFocusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: onFocusChanged,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isFocused
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isFocused
                  ? Colors.black.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: isFocused ? 15 : 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            labelText: l10n.authEmailLabel,
            hintText: l10n.authEmailHint,
            hintStyle: TextStyle(
              color: Colors.black.withValues(alpha: 0.3),
              fontWeight: FontWeight.w400,
            ),
            labelStyle: TextStyle(
              color: isFocused
                  ? Colors.black.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.4),
              fontWeight: FontWeight.w500,
            ),
            floatingLabelStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(
              Icons.alternate_email,
              color: isFocused
                  ? Colors.black.withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.3),
              size: 22,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.authEmailRequired;
            }
            if (!value.contains('@')) {
              return l10n.authEmailInvalid;
            }
            return null;
          },
        ),
      ),
    );
  }
}

class ForgotPasswordSubmitButton extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isLoading;
  final VoidCallback onPressed;

  const ForgotPasswordSubmitButton({
    super.key,
    required this.l10n,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: const Color(0xFFCCFF00),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCCFF00)),
                ),
              )
            : Text(
                l10n.authSendResetLink,
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

class ForgotPasswordBackToLoginLink extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onPressed;

  const ForgotPasswordBackToLoginLink({
    super.key,
    required this.l10n,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.arrow_back,
          size: 16,
          color: Colors.black.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onPressed,
          child: Text(
            l10n.authBackToLogin,
            style: const TextStyle(
              color: Color(0xFF8B5CF6),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}

class ForgotPasswordSuccessView extends StatelessWidget {
  final AppLocalizations l10n;
  final String email;
  final VoidCallback onBackToLogin;
  final VoidCallback onResend;

  const ForgotPasswordSuccessView({
    super.key,
    required this.l10n,
    required this.email,
    required this.onBackToLogin,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 100),
        Center(
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFFCCFF00).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              size: 50,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 50),
        Text(
          l10n.authCheckYourEmailTitle,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            height: 1.1,
            letterSpacing: -1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            l10n.authResetLinkSentTo(email),
            style: TextStyle(
              fontSize: 16,
              color: Colors.black.withValues(alpha: 0.5),
              fontWeight: FontWeight.w400,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 50),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: onBackToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: const Color(0xFFCCFF00),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.authBackToLogin,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: onResend,
          child: Text(
            l10n.authDidntReceiveResend,
            style: const TextStyle(
              color: Color(0xFF8B5CF6),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}

class NeuralCorePainter extends CustomPainter {
  final double progress;
  final Color color;

  NeuralCorePainter({
    required this.progress,
    this.color = const Color(0xFFCCFF00),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final centerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 6, centerPaint);

    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final nodePaint = Paint()
      ..color = color
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
        linePaint..color = color.withValues(alpha: lineOpacity),
      );

      final nodeSize = 2.5 + math.sin(progress * math.pi * 2 + i * 0.5) * 0.8;
      canvas.drawCircle(Offset(x, y), nodeSize.abs(), nodePaint);
    }

    final outerPaint = Paint()
      ..color = color.withValues(alpha: 0.2 + progress * 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, 24 + progress * 3, outerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
