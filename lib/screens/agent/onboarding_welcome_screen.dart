import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../l10n/app_localizations.dart';

class OnboardingWelcomeScreen extends StatefulWidget {
  final String email;

  const OnboardingWelcomeScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<OnboardingWelcomeScreen> createState() => _OnboardingWelcomeScreenState();
}

class _OnboardingWelcomeScreenState extends State<OnboardingWelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  double _slidePosition = 0.0;
  bool _isSliding = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startChatbot() {
    Navigator.pushReplacementNamed(
      context,
      '/onboarding-chatbot',
      arguments: {'email': widget.email},
    );
  }

  void _skipToMarketplace() {
    Navigator.pushReplacementNamed(context, '/agent-marketplace');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxSlide = screenWidth - 140;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black.withOpacity(0.1),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton.icon(
                      onPressed: _skipToMarketplace,
                      icon: const Icon(
                        Icons.fast_forward_rounded,
                        color: Colors.black,
                        size: 18,
                      ),
                      label: Text(
                        l10n.onboardingSkip,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Just the E-Team title (without "Bienvenue sur")
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'E-Team',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.onboardingWelcomeSubtitle,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      height: 1.5,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Logo AI
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFCDFF00).withOpacity(0.3 * _pulseController.value),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer rotating ring
                      Transform.rotate(
                        angle: _pulseController.value * 2 * math.pi,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFCDFF00).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      // Middle ring
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFCDFF00).withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                      ),

                      // Center icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: Color(0xFFCDFF00),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          size: 50,
                          color: Colors.black,
                        ),
                      ),

                      // Orbiting dots
                      ...List.generate(4, (index) {
                        final angle = (index * math.pi / 2) + (_pulseController.value * 2 * math.pi);
                        final x = math.cos(angle) * 90;
                        final y = math.sin(angle) * 90;
                        return Transform.translate(
                          offset: Offset(x, y),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFCDFF00),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),

            const Spacer(),

            // Bouton glissable
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Stack(
                  children: [
                    // Text "Slide to Start"
                    Center(
                      child: AnimatedOpacity(
                        opacity: _slidePosition < maxSlide * 0.3 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.onboardingSlideToStart,
                              style: const TextStyle(
                                color: Color(0xFFCDFF00),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),

                    // Progress bar
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          width: _slidePosition + 70,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Draggable button - JAUNE FLUO
                    AnimatedPositioned(
                      duration: _isSliding
                          ? Duration.zero
                          : const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      left: _slidePosition,
                      top: 8,
                      child: GestureDetector(
                        onHorizontalDragStart: (_) {
                          setState(() => _isSliding = true);
                        },
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            _slidePosition = (_slidePosition + details.delta.dx).clamp(0.0, maxSlide);
                          });

                          if (_slidePosition >= maxSlide * 0.95) {
                            _startChatbot();
                          }
                        },
                        onHorizontalDragEnd: (_) {
                          setState(() {
                            _isSliding = false;
                            if (_slidePosition < maxSlide * 0.95) {
                              _slidePosition = 0;
                            }
                          });
                        },
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCDFF00),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFCDFF00).withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            _slidePosition > maxSlide * 0.5
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            color: Colors.black,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Espace ajouté pour compenser la suppression du bouton
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}