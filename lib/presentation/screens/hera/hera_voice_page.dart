import 'package:e_team/data/services/vapi_service.dart';
import 'package:e_team/presentation/widgets/hera/voice/hera_voice_background.dart';
import 'package:e_team/presentation/widgets/hera/voice/hera_voice_controls.dart';
import 'package:e_team/presentation/widgets/hera/voice/hera_voice_models.dart';
import 'package:e_team/presentation/widgets/hera/voice/hera_voice_orb.dart';
import 'package:e_team/presentation/widgets/hera/voice/hera_voice_theme.dart';
import 'package:e_team/presentation/widgets/hera/voice/hera_voice_transcript.dart';
import 'package:flutter/material.dart';
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
  late final VapiService _vapiService;

  final TextEditingController _textController = TextEditingController();
  final List<HeraVoiceMessage> _messages = [];

  String _lastRenderedUserMessage = '';
  String _lastRenderedAssistantMessage = '';
  bool _showTextInput = false;

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

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _vapiService.removeListener(_refreshUi);
    _vapiService.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<bool> _ensureMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
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

      if (text.startsWith(lastText) || lastText.startsWith(text)) {
        _messages[_messages.length - 1] = HeraVoiceMessage(
          text: text,
          isUser: isUser,
        );
        onUpdateLast(text);
        return;
      }

      if (lastText == text) {
        onUpdateLast(text);
        return;
      }
    }

    if (text != lastRendered) {
      _messages.add(HeraVoiceMessage(text: text, isUser: isUser));
      onUpdateLast(text);
    }
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
    final isActive = _vapiService.isActive;

    return Scaffold(
      backgroundColor: HeraVoiceTheme.bg,
      body: Stack(
        children: [
          const HeraVoiceBackground(),
          SafeArea(
            child: Column(
              children: [
                HeraVoiceTopBar(
                  statusText: _statusChipText(),
                  onBack: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
                    child: Column(
                      children: [
                        const Spacer(),
                        HeraVoiceOrbStage(
                          pulseController: _pulseController,
                          floatController: _floatController,
                          pulseAnimation: _pulseAnimation,
                          floatAnimation: _floatAnimation,
                        ),
                        const SizedBox(height: 28),
                        Text(
                          _headline(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: HeraVoiceTheme.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            letterSpacing: -0.7,
                          ),
                        ),
                        const SizedBox(height: 18),
                        HeraVoiceTranscript(
                          messages: _messages,
                          accent: HeraVoiceTheme.accent,
                        ),
                        const Spacer(),
                        HeraVoiceTextInputPanel(
                          show: _showTextInput,
                          controller: _textController,
                          onSend: _sendText,
                        ),
                        HeraVoiceControls(
                          isActive: isActive,
                          onToggleText: () {
                            setState(() => _showTextInput = !_showTextInput);
                          },
                          onToggleListening: _toggleListening,
                          onClose: () => Navigator.pop(context),
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
}
