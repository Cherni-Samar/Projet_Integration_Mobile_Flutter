import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_team/data/services/dexo_service.dart';
import 'package:e_team/domain/models/dexo/dexo_onboarding_models.dart';
import 'package:e_team/presentation/providers/cart_provider.dart';
import 'package:e_team/presentation/utils/onboarding_cart_builder.dart';
import 'package:e_team/presentation/widgets/agent/onboarding/onboarding_chatbot_widgets.dart';

class OnboardingChatbotScreen extends StatefulWidget {
  final String email;

  const OnboardingChatbotScreen({super.key, required this.email});

  @override
  State<OnboardingChatbotScreen> createState() =>
      _OnboardingChatbotScreenState();
}

class _OnboardingChatbotScreenState extends State<OnboardingChatbotScreen>
    with TickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final List<Map<String, String>> _aiMessages = [];

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();

  late AnimationController _pulseController;

  bool _isTyping = false;
  bool _hasBlueprint = false;
  String _vision = '';

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _startConversation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _startConversation() {
    _addBotMessage(
      "I am Dexo, your Strategic Supervisor. To activate your company network, I need to understand your organization. What type of company are you building and what is its main activity?",
      delay: const Duration(milliseconds: 700),
    );
  }

  void _addBotMessage(
    String text, {
    Duration delay = const Duration(milliseconds: 800),
  }) {
    setState(() => _isTyping = true);

    Timer(delay, () {
      if (!mounted) return;

      setState(() {
        _messages.add(ChatMessage.bot(text));
        _aiMessages.add({'role': 'assistant', 'content': text});
        _isTyping = false;
      });

      _scrollToBottom();
    });
  }

  Future<void> _handleSend() async {
    final text = _inputController.text.trim();

    if (text.isEmpty || _hasBlueprint) return;

    if (_vision.isEmpty) _vision = text;

    setState(() {
      _messages.add(ChatMessage.user(text));
      _aiMessages.add({'role': 'user', 'content': text});
      _inputController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final result = await _requestStrategicAdvice();

      if (!mounted) return;

      if (result.isFinished == false) {
        final question = result.nextQuestion?.trim().isNotEmpty == true
            ? result.nextQuestion!
            : 'Pouvez-vous préciser le type de votre entreprise et son fonctionnement ?';

        setState(() {
          _messages.add(ChatMessage.bot(question));
          _aiMessages.add({'role': 'assistant', 'content': question});
          _isTyping = false;
        });

        _scrollToBottom();
        return;
      }

      final plan = result.plan;

      setState(() {
        _messages.add(
          ChatMessage.bot(
            "Analysis complete. I prepared your dynamic Organization Blueprint and selected the AI agents needed to activate your company network.",
          ),
        );

        _messages.add(ChatMessage.blueprint(plan));

        _hasBlueprint = true;
        _isTyping = false;
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() => _isTyping = false);

      _addBotMessage(
        "I could not analyze your company strategy right now. Please try again.",
      );
    }
  }

  Future<StrategicAdviceResult> _requestStrategicAdvice() async {
    final decoded = await DexoService.getStrategicAdvice({
      'messages': _aiMessages,
    });

    if (decoded['success'] != true) {
      throw Exception(decoded['error'] ?? decoded['message'] ?? 'AI failed');
    }

    return StrategicAdviceResult.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<void> _activateOrganizationVision(WorkforcePlan plan) async {
    try {
      final decoded = await DexoService.saveVision({
        'email': widget.email,
        'vision': _vision,
        'workforceSettings': plan.toApiList(),
        'recommendedAgents': plan.recommendedAgents
            .map((agent) => agent.toJson())
            .toList(),
      });

      if (decoded['success'] != true) {
        throw Exception(
          decoded['error'] ?? decoded['message'] ?? 'Save failed',
        );
      }

      _addRecommendedAgentsToCart(plan.recommendedAgents);

      if (!mounted) return;

      _addBotMessage(
        "Your organization vision has been activated. I added the recommended AI agents to your cart so you can launch the execution network.",
      );

      Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.pushNamed(
          context,
          '/cart',
          arguments: {'isOnboardingPayment': true},
        );
      });
    } catch (e) {
      _addBotMessage(
        "I could not save your organization vision. Please verify /api/dexo/save-vision.",
      );
    }
  }

  void _addRecommendedAgentsToCart(List<RecommendedAgent> agents) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    OnboardingCartBuilder.addRecommendedAgentsToCart(
      cart: cart,
      agents: agents,
    );
  }

  void _scrollToBottom() {
    Timer(const Duration(milliseconds: 120), () {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: OnboardingChatbotTheme.bg,
      appBar: OnboardingChatbotHeader(
        pulseController: _pulseController,
        onBack: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/agent-marketplace',
            (route) => false,
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return const OnboardingTypingIndicator();
                  }

                  return OnboardingChatMessageView(
                    message: _messages[index],
                    onConfirmBlueprint: _activateOrganizationVision,
                  );
                },
              ),
            ),
            AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: bottomInset > 0 ? 8 : 0),
              child: OnboardingInputBar(
                controller: _inputController,
                hasBlueprint: _hasBlueprint,
                onSend: _handleSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
