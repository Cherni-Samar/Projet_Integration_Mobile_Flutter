import 'package:flutter/material.dart';
import 'dart:async';

import 'package:e_team/presentation/widgets/splash/splash_widgets.dart';

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
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOutSine),
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
          SplashBackground(
            breathController: _breathController,
            waveController: _waveController,
          ),
          SplashWaveRings(waveController: _waveController),
          SplashNeuralCore(breath: _breath),
          SplashBrandFooter(
            textReveal: _textReveal,
            textController: _textController,
            waveController: _waveController,
          ),
        ],
      ),
    );
  }
}
