import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;
  bool _isEmailFocused = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // Glow subtil en arrière-plan
          Positioned(
            top: -50,
            left: -50,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF8B5CF6).withOpacity(0.08 + _animationController.value * 0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: _emailSent ? _buildSuccessView() : _buildFormView(),
            ),
          ),

          // Back button flottant
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black.withOpacity(0.7),
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 100),

          // Icône réseau neural style login
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: CustomPaint(
                size: const Size(50, 50),
                painter: NeuralCorePainter(
                  progress: _animationController.value,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ),
          ),

          const SizedBox(height: 50),

          // Titre moderne
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

          // Sous-titre élégant
          Text(
            l10n.authForgotPasswordSubtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black.withOpacity(0.5),
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 50),

          // Champ email style login
          Focus(
            onFocusChange: (focused) => setState(() => _isEmailFocused = focused),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isEmailFocused
                      ? Colors.black.withOpacity(0.3)
                      : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isEmailFocused
                        ? Colors.black.withOpacity(0.06)
                        : Colors.black.withOpacity(0.03),
                    blurRadius: _isEmailFocused ? 15 : 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _emailController,
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
                    color: Colors.black.withOpacity(0.3),
                    fontWeight: FontWeight.w400,
                  ),
                  labelStyle: TextStyle(
                    color: _isEmailFocused
                        ? Colors.black.withOpacity(0.7)
                        : Colors.black.withOpacity(0.4),
                    fontWeight: FontWeight.w500,
                  ),
                  floatingLabelStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  prefixIcon: Icon(
                    Icons.alternate_email,
                    color: _isEmailFocused
                        ? Colors.black.withOpacity(0.6)
                        : Colors.black.withOpacity(0.3),
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
          ),

          const SizedBox(height: 32),

          // Bouton Send Reset Link
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: const Color(0xFFCCFF00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFFCCFF00),
                  ),
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
          ),

          const SizedBox(height: 32),

          // Back to login
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_back,
                size: 16,
                color: Colors.black.withOpacity(0.4),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  l10n.authBackToLogin,
                  style: TextStyle(
                    color: const Color(0xFF8B5CF6),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        const SizedBox(height: 100),

        // Icône succès animée
        Center(
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFFCCFF00).withOpacity(0.15),
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

        // Titre succès
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

        // Message avec email
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            l10n.authResetLinkSentTo(_emailController.text),
            style: TextStyle(
              fontSize: 16,
              color: Colors.black.withOpacity(0.5),
              fontWeight: FontWeight.w400,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 50),

        // Bouton Back to Login
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
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

        // Resend link
        GestureDetector(
          onTap: _handleResetPassword,
          child: Text(
            l10n.authDidntReceiveResend,
            style: TextStyle(
              color: const Color(0xFF8B5CF6),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}

// Painter réseau neural réutilisable avec couleur personnalisée
class NeuralCorePainter extends CustomPainter {
  final double progress;
  final Color color;

  NeuralCorePainter({required this.progress, this.color = const Color(0xFFCCFF00)});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final centerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 6, centerPaint);

    final linePaint = Paint()
      ..color = color.withOpacity(0.6)
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

      final lineOpacity = 0.3 + (math.sin(progress * math.pi * 2 + i) + 1) / 2 * 0.4;
      canvas.drawLine(
        Offset(x, y),
        center,
        linePaint..color = color.withOpacity(lineOpacity),
      );

      final nodeSize = 2.5 + math.sin(progress * math.pi * 2 + i * 0.5) * 0.8;
      canvas.drawCircle(Offset(x, y), nodeSize.abs(), nodePaint);
    }

    final outerPaint = Paint()
      ..color = color.withOpacity(0.2 + progress * 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, 24 + progress * 3, outerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ForgotPasswordScreenPreview extends StatelessWidget {
  const ForgotPasswordScreenPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      ),
      home: const ForgotPasswordScreen(),
    );
  }
}