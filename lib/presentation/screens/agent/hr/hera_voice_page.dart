import 'dart:math' as math;
import 'package:flutter/material.dart';
import '/data/services/vapi_service.dart';
import 'package:permission_handler/permission_handler.dart';

class HeraVoicePage extends StatefulWidget {
  const HeraVoicePage({super.key});

  @override
  State<HeraVoicePage> createState() => _HeraVoicePageState();
}

class _HeraVoicePageState extends State<HeraVoicePage>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _floatController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _floatAnimation;
  String _lastRenderedUserMessage = '';
  String _lastRenderedAssistantMessage = '';
  late final VapiService _vapiService;
  final TextEditingController _textController = TextEditingController();
  Future<bool> _ensureMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  bool _showTextInput = false;

  final List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();

    _vapiService = VapiService();
    _vapiService.init();
    _vapiService.addListener(_refreshUi);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  void _refreshUi() {
    _syncMessagesFromService();
    if (mounted) setState(() {});
  }

  void _syncMessagesFromService() {
    final userText = _vapiService.lastUserTranscript.trim();
    final assistantText = _vapiService.lastAssistantTranscript.trim();

    _upsertMessage(
      text: userText,
      isUser: true,
      lastRendered: _lastRenderedUserMessage,
      onUpdateLast: (value) => _lastRenderedUserMessage = value,
    );

    _upsertMessage(
      text: assistantText,
      isUser: false,
      lastRendered: _lastRenderedAssistantMessage,
      onUpdateLast: (value) => _lastRenderedAssistantMessage = value,
    );
  }

  void _upsertMessage({
    required String text,
    required bool isUser,
    required String lastRendered,
    required void Function(String) onUpdateLast,
  }) {
    if (text.isEmpty) return;

    if (_messages.isNotEmpty && _messages.last.isUser == isUser) {
      final lastText = _messages.last.text;

      // transcript progressif: on met à jour la dernière bulle
      if (text.startsWith(lastText) || lastText.startsWith(text)) {
        _messages[_messages.length - 1] = _ChatMessage(
          text: text,
          isUser: isUser,
        );
        onUpdateLast(text);
        return;
      }

      // exactement le même texte => on ne fait rien
      if (lastText == text) {
        onUpdateLast(text);
        return;
      }
    }

    if (text != lastRendered) {
      _messages.add(_ChatMessage(text: text, isUser: isUser));
      onUpdateLast(text);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _vapiService.removeListener(_refreshUi);
    _vapiService.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    final granted = await _ensureMicPermission();

    if (!granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Permission microphone refusée'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF191919),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
      return;
    }

    await _vapiService.toggle();
  }

  Future<void> _sendText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    await _vapiService.sendTextMessage(text);
    _textController.clear();
  }

  String _headline() {
    switch (_vapiService.status) {
      case HeraVoiceStatus.connecting:
        return 'Connexion à Hera...';
      case HeraVoiceStatus.listening:
        return 'Je vous écoute...';
      case HeraVoiceStatus.speaking:
        return 'Hera vous répond...';
      case HeraVoiceStatus.ended:
        return 'Conversation terminée';
      case HeraVoiceStatus.error:
        return _vapiService.errorMessage.isNotEmpty
            ? _vapiService.errorMessage
            : 'Une erreur est survenue';
      case HeraVoiceStatus.idle:
        return 'Comment puis-je vous aider aujourd’hui ?';
    }
  }

  String _statusChipText() {
    switch (_vapiService.status) {
      case HeraVoiceStatus.connecting:
        return 'Connexion';
      case HeraVoiceStatus.listening:
        return 'Écoute active';
      case HeraVoiceStatus.speaking:
        return 'Hera parle';
      case HeraVoiceStatus.ended:
        return 'Terminée';
      case HeraVoiceStatus.error:
        return 'Erreur';
      case HeraVoiceStatus.idle:
        return 'Prête';
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF050505);
    const accent = Color(0xFFB57BFF); // Mauve Hera
    const textPrimary = Colors.white;
    final textSecondary = Colors.white.withOpacity(0.65);
    final isActive = _vapiService.isActive;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          const _HeraBackgroundLines(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                  child: Row(
                    children: [
                      _circleTopButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.95),
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
                            _statusChipText(),
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
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
                    child: Column(
                      children: [
                        const Spacer(),
                        AnimatedBuilder(
                          animation: Listenable.merge([
                            _pulseController,
                            _floatController,
                          ]),
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _floatAnimation.value),
                              child: Transform.scale(
                                scale: _pulseAnimation.value,
                                child: child,
                              ),
                            );
                          },
                          child: const _HeraOrb(),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          _headline(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            letterSpacing: -0.7,
                          ),
                        ),
                        const SizedBox(height: 18),

                        /// discussion visible
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          height: _messages.isEmpty ? 0 : 170,
                          width: double.infinity,
                          child: _messages.isEmpty
                              ? const SizedBox.shrink()
                              : Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                            child: ListView.builder(
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final msg = _messages[index];
                                return Align(
                                  alignment: msg.isUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                      bottom: 10,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    constraints: const BoxConstraints(
                                      maxWidth: 260,
                                    ),
                                    decoration: BoxDecoration(
                                      color: msg.isUser
                                          ? accent
                                          : Colors.white.withOpacity(
                                        0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        18,
                                      ),
                                    ),
                                    child: Text(
                                      msg.text,
                                      style: TextStyle(
                                        color: msg.isUser
                                            ? Colors.white
                                            : Colors.white,
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
                        ),

                        const Spacer(),

                        /// panneau de saisie qui monte
                        AnimatedSlide(
                          duration: const Duration(milliseconds: 220),
                          offset: _showTextInput
                              ? Offset.zero
                              : const Offset(0, 1),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 220),
                            opacity: _showTextInput ? 1 : 0,
                            child: _showTextInput
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
                                  color: const Color(0xFFB57BFF).withOpacity(0.4),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        inputDecorationTheme:
                                        const InputDecorationTheme(
                                          filled: false,
                                          fillColor:
                                          Colors.transparent,
                                          border: InputBorder.none,
                                          enabledBorder:
                                          InputBorder.none,
                                          focusedBorder:
                                          InputBorder.none,
                                          disabledBorder:
                                          InputBorder.none,
                                          errorBorder:
                                          InputBorder.none,
                                          focusedErrorBorder:
                                          InputBorder.none,
                                          contentPadding:
                                          EdgeInsets.zero,
                                          isDense: true,
                                        ),
                                      ),
                                      child: TextField(
                                        controller: _textController,
                                        autofocus: true,
                                        cursorColor: Colors.white,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                        decoration: InputDecoration(
                                          hintText:
                                          'Écrire un message à Hera...',
                                          hintStyle: TextStyle(
                                            color: Colors.white
                                                .withOpacity(0.38),
                                          ),
                                        ),
                                        onSubmitted: (_) => _sendText(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: _sendText,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFB57BFF),
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
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _bottomCircleButton(
                              icon: Icons.chat_bubble_outline_rounded,
                              onTap: () {
                                setState(() {
                                  _showTextInput = !_showTextInput;
                                });
                              },
                            ),
                            const SizedBox(width: 26),
                            GestureDetector(
                              onTap: _toggleListening,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                width: 92,
                                height: 92,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: accent,
                                  boxShadow: [
                                    BoxShadow(
                                      color: accent.withOpacity(
                                        isActive ? 0.55 : 0.30,
                                      ),
                                      blurRadius: isActive ? 34 : 22,
                                      spreadRadius: isActive ? 4 : 0,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isActive
                                      ? Icons.graphic_eq_rounded
                                      : Icons.mic_rounded,
                                  color: Colors.white,
                                  size: 34,
                                ),
                              ),
                            ),
                            const SizedBox(width: 26),
                            _bottomCircleButton(
                              icon: Icons.close_rounded,
                              onTap: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleTopButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Icon(icon, color: Colors.white70, size: 22),
      ),
    );
  }

  Widget _bottomCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Icon(icon, color: Colors.white70, size: 22),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}

class _HeraOrb extends StatelessWidget {
  const _HeraOrb();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Halo extérieur mauve
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB57BFF).withOpacity(0.18),
                  blurRadius: 60,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
          // Anneau SweepGradient mauve/violet
          Container(
            width: 214,
            height: 214,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF7B4FD4),
                  Color(0xFFB57BFF),
                  Color(0xFFD4A8FF),
                  Color(0xFF7B4FD4),
                  Color(0xFF3A1F6E),
                  Color(0xFF1A1A2E),
                ],
              ),
            ),
          ),
          // Couche intermédiaire RadialGradient mauve
          Container(
            width: 194,
            height: 194,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.35),
                  const Color(0xFFB57BFF).withOpacity(0.50),
                  const Color(0xFF080808),
                ],
                stops: const [0.0, 0.38, 1.0],
              ),
            ),
          ),
          // Noyau central mauve profond
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFB57BFF).withOpacity(0.80),
                  const Color(0xFF6B3FA0).withOpacity(0.60),
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

class _HeraBackgroundLines extends StatelessWidget {
  const _HeraBackgroundLines();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _LinesPainter(), size: Size.infinite);
  }
}

class _LinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB57BFF).withOpacity(0.06)
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
