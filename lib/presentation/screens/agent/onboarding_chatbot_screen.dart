import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:e_team/data/services/dexo_service.dart';
import 'package:e_team/data/services/payment_plan_metadata_service.dart';
import 'package:e_team/domain/models/dexo/dexo_onboarding_models.dart';
import 'package:e_team/presentation/providers/cart_provider.dart';
import 'package:e_team/presentation/utils/domain_model_color_extensions.dart';
import 'package:e_team/presentation/widgets/dexo/organization_blueprint_card.dart';

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

  static const Color _primary = Color(0xFFCDFF00);
  static const Color _dark = Color(0xFF0A0A0A);
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _botBubble = Color(0xFFF8FAFC);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _textMain = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _green = Color(0xFF22C55E);

  final Map<String, Map<String, dynamic>> _agentCatalog = {
    'hera': {
      'title': 'Hera',
      'illustration': 'assets/images/hera.png',
      'color': const Color(0xFF8B5CF6),
    },
    'echo': {
      'title': 'Echo',
      'illustration': 'assets/images/voxi.png',
      'color': const Color(0xFFA855F7),
    },
    'timo': {
      'title': 'Timo',
      'illustration': 'assets/images/krono.png',
      'color': const Color(0xFFEC4899),
    },
    'dexo': {
      'title': 'Dexo',
      'illustration': 'assets/images/dexo.png',
      'color': const Color(0xFF10B981),
    },
    'kash': {
      'title': 'Kash',
      'illustration': 'assets/images/kash.png',
      'color': const Color(0xFFF59E0B),
    },
  };

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

    // Get plan data from service
    final planData = PaymentPlanMetadataService.getOnboardingPlanData(
      agents.length,
    );

    final packId = planData['packId'] as String;
    final packTitle = planData['packTitle'] as String;
    final energyCredits = planData['energyCredits'] as int;
    final price = planData['price'] as double;
    final agentsAllowed = planData['agentsAllowed'] as int;

    cart.setPaymentPack(packId);

    // Add the plan item first
    final planItem = CartItem(
      id: 'plan-$packId',
      agentName: packTitle,
      agentIllustration: 'assets/images/plan_icon.png',
      agentColorValue: 0xFF6366F1,
      packTitle: 'Pack $agentsAllowed agents',
      energy: energyCredits,
      price: price,
      isPlan: true,
    );
    cart.addToCart(planItem);

    for (final agent in agents) {
      final key = agent.id.toLowerCase().trim();
      final data = _agentCatalog[key];

      if (data == null) continue;

      final agentName = data['title'] as String;

      final item = CartItem(
        id: 'agent-$agentName',
        agentName: agentName,
        agentIllustration: data['illustration'] as String,
        agentColorValue: colorToValue(data['color'] as Color),
        packTitle: 'Included',
        energy: 0,
        price: 0.0,
        isPlan: false,
      );

      cart.addToCart(item);
    }
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
      backgroundColor: _bg,
      appBar: _buildHeader(),
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
                    return _buildTypingIndicator();
                  }

                  return _buildMessage(_messages[index]);
                },
              ),
            ),
            AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: bottomInset > 0 ? 8 : 0),
              child: _buildInputBar(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildHeader() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        color: _dark,
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/agent-marketplace',
            (route) => false,
          );
        },
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) {
              return Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _green.withValues(
                    alpha: 0.4 + 0.6 * _pulseController.value,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _green.withValues(alpha: 0.25),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          Text(
            "DEXO CONSULTATION",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: _dark,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 0.5, color: _border),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    if (message.type == ChatMessageType.blueprint) {
      final plan = message.blueprintPlan;
      if (plan == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Align(
          alignment: Alignment.centerLeft,
          child: OrganizationBlueprintCard(
            initialPlan: plan,
            onConfirm: _activateOrganizationVision,
          ),
        ),
      );
    }

    final isBot = message.type == ChatMessageType.bot;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Align(
        alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isBot ? _botBubble : _dark,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isBot ? 4 : 20),
              bottomRight: Radius.circular(isBot ? 20 : 4),
            ),
            border: isBot ? Border.all(color: _border, width: 0.5) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            message.text,
            style: GoogleFonts.plusJakartaSans(
              color: isBot ? _textMain : _primary,
              fontSize: 14,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _botBubble,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border, width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _DotDelay(delay: 0),
              const SizedBox(width: 4),
              const _DotDelay(delay: 150),
              const SizedBox(width: 4),
              const _DotDelay(delay: 300),
              const SizedBox(width: 10),
              Text(
                "Dexo is analyzing your company...",
                style: GoogleFonts.plusJakartaSans(
                  color: _textMuted,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _border, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              enabled: !_hasBlueprint,
              minLines: 1,
              maxLines: 4,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: _textMain,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: _hasBlueprint
                    ? "Blueprint generated"
                    : "Describe your company...",
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: _textMuted,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: _botBubble,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 13,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _handleSend,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _hasBlueprint ? _textMuted : _dark,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _dark.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: _primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Typing indicator dot ─────────────────────────────────────────────────────

class _DotDelay extends StatefulWidget {
  final int delay;

  const _DotDelay({required this.delay});

  @override
  State<_DotDelay> createState() => _DotDelayState();
}

class _DotDelayState extends State<_DotDelay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _opacity = Tween<double>(begin: 0.25, end: 1).animate(_controller);

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Color(0xFF64748B),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
