import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _waveController;
  late AnimationController _textController;
  late Animation<double> _breath;
  late Animation<double> _textReveal;

  @override
  void initState() {
    super.initState();

    // Respiration organique de l'AI
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    // Ondes qui se propagent
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Texte qui s'assemble
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _breath = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOutSine,
      ),
    );

    _textReveal = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    Timer(const Duration(seconds: 4), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _breathController.dispose();
    _waveController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Shader personnalisé pour effet "fluide neuronal"
          AnimatedBuilder(
            animation: _breathController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: NeuralFluidPainter(
                  progress: _breathController.value,
                  time: _waveController.value,
                ),
              );
            },
          ),

          // Cercles d'ondes concentriques qui pulsent
          ...List.generate(4, (index) {
            return AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                final delay = index * 0.25;
                var waveProgress = (_waveController.value + delay) % 1.0;

                return Center(
                  child: Container(
                    width: 200 + (waveProgress * 300),
                    height: 200 + (waveProgress * 300),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFCCFF00).withOpacity(
                          (1 - waveProgress) * 0.3,
                        ),
                        width: 1.5,
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Core AI - Réseau neural animé
          Center(
            child: AnimatedBuilder(
              animation: _breath,
              builder: (context, child) {
                final scale = 0.8 + (_breath.value * 0.2);
                final glowIntensity = 0.3 + (_breath.value * 0.4);

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFCCFF00).withOpacity(glowIntensity),
                          const Color(0xFFCCFF00).withOpacity(glowIntensity * 0.3),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFCCFF00).withOpacity(glowIntensity * 0.6),
                          blurRadius: 60,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: Center(
                      child: CustomPaint(
                        size: const Size(70, 70),
                        painter: NeuralCorePainter(
                          progress: _breath.value,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Texte E-Team et tagline
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: FadeTransition(
                  opacity: _textReveal,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // E-Team avec animation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: 'E-Team'.split('').asMap().entries.map((entry) {
                          final index = entry.key;
                          final letter = entry.value;
                          return AnimatedBuilder(
                            animation: _textController,
                            builder: (context, child) {
                              final letterProgress = (_textController.value * 6 - index).clamp(0.0, 1.0);
                              return Opacity(
                                opacity: letterProgress,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - letterProgress) * 20),
                                  child: Text(
                                    letter,
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      height: 1,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 12),

                      // Tagline
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFCCFF00).withOpacity(0.3),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'AI that works for you',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                            letterSpacing: 2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Indicateur de chargement
                      SizedBox(
                        width: 100,
                        child: AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, child) {
                            return LinearProgressIndicator(
                              value: (_waveController.value * 2) % 1.0,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFCCFF00),
                              ),
                              minHeight: 2,
                              borderRadius: BorderRadius.circular(1),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Painter pour le core réseau neural
class NeuralCorePainter extends CustomPainter {
  final double progress;

  NeuralCorePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Cercle central
    final centerPaint = Paint()
      ..color = const Color(0xFFCCFF00)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 8, centerPaint);

    // Points orbitaux et connexions
    final linePaint = Paint()
      ..color = const Color(0xFFCCFF00).withOpacity(0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final nodePaint = Paint()
      ..color = const Color(0xFFCCFF00)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 6; i++) {
      final angle = (i / 6) * math.pi * 2 + progress * math.pi * 0.5;
      final radius = 22 + math.sin(progress * math.pi * 2) * 3;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;

      // Ligne vers le centre avec opacité variable
      final lineOpacity = 0.3 + (math.sin(progress * math.pi * 2 + i) + 1) / 2 * 0.4;
      canvas.drawLine(
        Offset(x, y),
        center,
        linePaint..color = const Color(0xFFCCFF00).withOpacity(lineOpacity),
      );

      // Point orbital avec pulse
      final nodeSize = 3 + math.sin(progress * math.pi * 2 + i * 0.5) * 1;
      canvas.drawCircle(Offset(x, y), nodeSize.abs(), nodePaint);
    }

    // Cercle externe subtil qui pulse
    final outerPaint = Paint()
      ..color = const Color(0xFFCCFF00).withOpacity(0.2 + progress * 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, 28 + progress * 4, outerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Painter pour l'effet fluide neuronal en arrière-plan
class NeuralFluidPainter extends CustomPainter {
  final double progress;
  final double time;

  NeuralFluidPainter({required this.progress, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Cellules organiques flottantes
    final random = math.Random(42);
    for (var i = 0; i < 20; i++) {
      final angle = (i / 20) * math.pi * 2 + time * math.pi;
      final distance = 100 + math.sin(time * math.pi * 2 + i) * 50;
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance * 0.6;
      final radius = 30 + math.sin(progress * math.pi + i) * 20;

      final gradient = RadialGradient(
        colors: [
          const Color(0xFFCCFF00).withOpacity(0.1),
          Colors.transparent,
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: Offset(x, y), radius: radius),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Lignes de connexion style réseau neural
    final linePaint = Paint()
      ..color = const Color(0xFFCCFF00).withOpacity(0.05)
      ..strokeWidth = 0.5;

    for (var i = 0; i < 8; i++) {
      final angle1 = (i / 8) * math.pi * 2 + time * 0.5;
      final angle2 = ((i + 1) / 8) * math.pi * 2 + time * 0.5;
      final r = 150 + math.sin(progress * math.pi * 2) * 30;

      final p1 = Offset(
        center.dx + math.cos(angle1) * r,
        center.dy + math.sin(angle1) * r * 0.6,
      );
      final p2 = Offset(
        center.dx + math.cos(angle2) * r,
        center.dy + math.sin(angle2) * r * 0.6,
      );

      canvas.drawLine(p1, p2, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}