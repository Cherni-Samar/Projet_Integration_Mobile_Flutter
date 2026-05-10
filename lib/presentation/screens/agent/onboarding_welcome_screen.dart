import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/widgets/agent/onboarding/onboarding_welcome_widgets.dart';
import 'package:flutter/material.dart';

class OnboardingWelcomeScreen extends StatefulWidget {
  final String email;

  const OnboardingWelcomeScreen({super.key, required this.email});

  @override
  State<OnboardingWelcomeScreen> createState() =>
      _OnboardingWelcomeScreenState();
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

  void _onSlideStart() {
    setState(() => _isSliding = true);
  }

  void _onSlideUpdate(double delta, double maxSlide) {
    setState(() {
      _slidePosition = (_slidePosition + delta).clamp(0.0, maxSlide);
    });

    if (_slidePosition >= maxSlide * 0.95) {
      _startChatbot();
    }
  }

  void _onSlideEnd(double maxSlide) {
    setState(() {
      _isSliding = false;
      if (_slidePosition < maxSlide * 0.95) {
        _slidePosition = 0;
      }
    });
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
            OnboardingSkipButton(
              label: l10n.onboardingSkip,
              onPressed: _skipToMarketplace,
            ),
            const SizedBox(height: 40),
            OnboardingWelcomeHeader(subtitle: l10n.onboardingWelcomeSubtitle),
            const Spacer(),
            OnboardingAiLogo(animation: _pulseController),
            const Spacer(),
            OnboardingSlideToStart(
              label: l10n.onboardingSlideToStart,
              slidePosition: _slidePosition,
              maxSlide: maxSlide,
              isSliding: _isSliding,
              onDragStart: _onSlideStart,
              onDragUpdate: (delta) => _onSlideUpdate(delta, maxSlide),
              onDragEnd: () => _onSlideEnd(maxSlide),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
