import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:e_team/data/services/api_config.dart';
import '../../providers/cart_provider.dart';

class OnboardingChatbotScreen extends StatefulWidget {
  final String email;

  const OnboardingChatbotScreen({
    super.key,
    required this.email,
  });

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
        _aiMessages.add({
          'role': 'assistant',
          'content': text,
        });
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
      _aiMessages.add({
        'role': 'user',
        'content': text,
      });
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
          _aiMessages.add({
            'role': 'assistant',
            'content': question,
          });
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

        _messages.add(
          ChatMessage.blueprint(
            OrganizationBlueprintCard(
              initialPlan: plan,
              onConfirm: _activateOrganizationVision,
            ),
          ),
        );

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
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/dexo/strategic-advice');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'messages': _aiMessages,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(response.body);

    if (decoded['success'] != true) {
      throw Exception(decoded['error'] ?? decoded['message'] ?? 'AI failed');
    }

    return StrategicAdviceResult.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<void> _activateOrganizationVision(WorkforcePlan plan) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/dexo/save-vision');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'vision': _vision,
          'workforceSettings': plan.toApiList(),
          'recommendedAgents':
          plan.recommendedAgents.map((agent) => agent.toJson()).toList(),
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded['success'] != true) {
        throw Exception(decoded['error'] ?? decoded['message'] ?? 'Save failed');
      }

      _addRecommendedAgentsToCart(plan.recommendedAgents);

      if (!mounted) return;

      _addBotMessage(
        "Your organization vision has been activated. I added the recommended AI agents to your cart so you can launch the execution network.",
      );

      Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/cart');
      });
    } catch (e) {
      _addBotMessage(
        "I could not save your organization vision. Please verify /api/dexo/save-vision.",
      );
    }
  }

  void _addRecommendedAgentsToCart(List<RecommendedAgent> agents) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    if (agents.length >= 4) {
      cart.setPaymentPack('premium_plan');
    } else if (agents.length >= 2) {
      cart.setPaymentPack('basic_plan');
    } else {
      cart.setPaymentPack('energy_boost');
    }

    for (final agent in agents) {
      final key = agent.id.toLowerCase().trim();
      final data = _agentCatalog[key];

      if (data == null) continue;

      final agentName = data['title'] as String;

      final item = CartItem(
        id: 'agent-$agentName',
        agentName: agentName,
        agentIllustration: data['illustration'] as String,
        agentColor: data['color'] as Color,
        packTitle: agents.length >= 4
            ? 'Premium Plan'
            : agents.length >= 2
            ? 'Basic Plan'
            : 'Pack Boost',
        energy: 0,
        price: 0.0,
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
        onPressed: () => Navigator.pop(context),
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
                  color: _green.withOpacity(0.4 + 0.6 * _pulseController.value),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _green.withOpacity(0.25),
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
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Align(
          alignment: Alignment.centerLeft,
          child: message.widget!,
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
                color: Colors.black.withOpacity(0.025),
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
                    color: _dark.withOpacity(0.18),
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

enum ChatMessageType {
  bot,
  user,
  blueprint,
}

class ChatMessage {
  final ChatMessageType type;
  final String text;
  final Widget? widget;

  const ChatMessage._({
    required this.type,
    this.text = '',
    this.widget,
  });

  factory ChatMessage.bot(String text) {
    return ChatMessage._(type: ChatMessageType.bot, text: text);
  }

  factory ChatMessage.user(String text) {
    return ChatMessage._(type: ChatMessageType.user, text: text);
  }

  factory ChatMessage.blueprint(Widget widget) {
    return ChatMessage._(type: ChatMessageType.blueprint, widget: widget);
  }
}

class StrategicAdviceResult {
  final bool isFinished;
  final String? nextQuestion;
  final WorkforcePlan plan;

  StrategicAdviceResult({
    required this.isFinished,
    required this.nextQuestion,
    required this.plan,
  });

  factory StrategicAdviceResult.fromJson(Map<String, dynamic> json) {
    return StrategicAdviceResult(
      isFinished: json['isFinished'] == true,
      nextQuestion: json['nextQuestion']?.toString(),
      plan: WorkforcePlan.fromJson(json),
    );
  }
}

class WorkforceDepartment {
  String name;
  int targetCount;
  final String reason;

  WorkforceDepartment({
    required this.name,
    required this.targetCount,
    required this.reason,
  });

  factory WorkforceDepartment.fromJson(Map<String, dynamic> json) {
    return WorkforceDepartment(
      name: json['name']?.toString() ??
          json['department']?.toString() ??
          'Department',
      targetCount: WorkforcePlan._toInt(
        json['targetCount'] ?? json['count'] ?? json['employees'],
        1,
      ),
      reason: json['reason']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'department': name,
      'targetCount': targetCount,
      'currentCount': 0,
      'reason': reason,
    };
  }
}

class WorkforcePlan {
  List<WorkforceDepartment> departments;
  String explanation;
  List<RecommendedAgent> recommendedAgents;

  WorkforcePlan({
    required this.departments,
    required this.explanation,
    required this.recommendedAgents,
  });

  factory WorkforcePlan.fromJson(Map<String, dynamic> json) {
    final proposal = json['proposal'] is Map
        ? Map<String, dynamic>.from(json['proposal'])
        : json;

    final departmentsRaw =
        proposal['departments'] ?? json['departments'] ?? [];

    List<WorkforceDepartment> parsedDepartments = [];

    if (departmentsRaw is List) {
      parsedDepartments = departmentsRaw
          .whereType<Map>()
          .map((e) => WorkforceDepartment.fromJson(
        Map<String, dynamic>.from(e),
      ))
          .where((d) => d.name.trim().isNotEmpty)
          .toList();
    }

    if (parsedDepartments.isEmpty) {
      parsedDepartments = [
        WorkforceDepartment(
          name: 'Operations',
          targetCount: 2,
          reason: 'Manage daily company operations.',
        ),
        WorkforceDepartment(
          name: 'Marketing',
          targetCount: 2,
          reason: 'Acquire customers and grow the brand.',
        ),
        WorkforceDepartment(
          name: 'Administration',
          targetCount: 1,
          reason: 'Coordinate internal organization.',
        ),
      ];
    }

    final agentsRaw =
        json['recommendedAgents'] ?? proposal['recommendedAgents'] ?? [];

    return WorkforcePlan(
      departments: parsedDepartments,
      explanation: proposal['explanation']?.toString() ??
          'Dexo generated this organization structure from your company vision.',
      recommendedAgents: (agentsRaw as List? ?? [])
          .whereType<Map>()
          .map((e) => RecommendedAgent.fromJson(
        Map<String, dynamic>.from(e),
      ))
          .toList(),
    );
  }

  List<Map<String, dynamic>> toApiList() {
    return departments.map((d) => d.toJson()).toList();
  }

  static int _toInt(dynamic value, int fallback) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }
}

class RecommendedAgent {
  final String id;
  final String name;
  final String reason;

  RecommendedAgent({
    required this.id,
    required this.name,
    required this.reason,
  });

  factory RecommendedAgent.fromJson(Map<String, dynamic> json) {
    return RecommendedAgent(
      id: json['id']?.toString().toLowerCase() ?? '',
      name: json['name']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'reason': reason,
    };
  }
}

class OrganizationBlueprintCard extends StatefulWidget {
  final WorkforcePlan initialPlan;
  final Future<void> Function(WorkforcePlan plan) onConfirm;

  const OrganizationBlueprintCard({
    super.key,
    required this.initialPlan,
    required this.onConfirm,
  });

  @override
  State<OrganizationBlueprintCard> createState() =>
      _OrganizationBlueprintCardState();
}

class _OrganizationBlueprintCardState extends State<OrganizationBlueprintCard> {
  late WorkforcePlan _plan;
  bool _isSaving = false;

  static const Color _primary = Color(0xFFCDFF00);
  static const Color _dark = Color(0xFF0A0A0A);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _textMain = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();

    _plan = WorkforcePlan(
      departments: widget.initialPlan.departments
          .map(
            (d) => WorkforceDepartment(
          name: d.name,
          targetCount: d.targetCount,
          reason: d.reason,
        ),
      )
          .toList(),
      explanation: widget.initialPlan.explanation,
      recommendedAgents: widget.initialPlan.recommendedAgents,
    );
  }

  int get _total =>
      _plan.departments.fold(0, (sum, d) => sum + d.targetCount);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.92,
      ),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _border, width: 0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(),
          const SizedBox(height: 14),
          Text(
            _plan.explanation,
            style: GoogleFonts.plusJakartaSans(
              color: _textMuted,
              fontSize: 12,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          ..._plan.departments.map(
                (dept) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildRow(
                icon: _iconForDepartment(dept.name),
                label: dept.name,
                subtitle: dept.reason.isNotEmpty
                    ? dept.reason
                    : 'Required function for this company',
                value: dept.targetCount,
                onMinus: () => _changeDepartment(dept, -1),
                onPlus: () => _changeDepartment(dept, 1),
              ),
            ),
          ),
          const SizedBox(height: 6),
          _buildTotalBox(),
          if (_plan.recommendedAgents.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildAgentsSection(),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                setState(() => _isSaving = true);
                await widget.onConfirm(_plan);
                if (mounted) setState(() => _isSaving = false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _dark,
                disabledBackgroundColor: _dark.withOpacity(0.45),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: _primary,
                ),
              )
                  : Text(
                'ACTIVATE ORGANIZATION VISION',
                style: GoogleFonts.plusJakartaSans(
                  color: _primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.account_tree_rounded,
            color: _dark,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ORGANIZATION BLUEPRINT',
                style: GoogleFonts.plusJakartaSans(
                  color: _dark,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Adjust Dexo’s dynamic company structure.',
                style: GoogleFonts.plusJakartaSans(
                  color: _textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    required String subtitle,
    required int value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border, width: 0.6),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _dark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    color: _textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: _textMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _counterButton(Icons.remove_rounded, onMinus),
          SizedBox(
            width: 38,
            child: Center(
              child: Text(
                '$value',
                style: GoogleFonts.plusJakartaSans(
                  color: _textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          _counterButton(Icons.add_rounded, onPlus),
        ],
      ),
    );
  }

  Widget _buildTotalBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _dark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.groups_rounded, color: _primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Total recommended workforce',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white.withOpacity(0.72),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '$_total',
            style: GoogleFonts.plusJakartaSans(
              color: _primary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECOMMENDED AI AGENTS',
          style: GoogleFonts.plusJakartaSans(
            color: _dark,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        ..._plan.recommendedAgents.map(
              (agent) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border, width: 0.6),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome, color: _dark, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agent.name.isNotEmpty ? agent.name : agent.id,
                        style: GoogleFonts.plusJakartaSans(
                          color: _textMain,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        agent.reason,
                        style: GoogleFonts.plusJakartaSans(
                          color: _textMuted,
                          fontSize: 11,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _counterButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: _border, width: 0.6),
        ),
        child: Icon(icon, size: 18, color: _dark),
      ),
    );
  }

  IconData _iconForDepartment(String name) {
    final n = name.toLowerCase();

    if (n.contains('tech') || n.contains('software') || n.contains('it')) {
      return Icons.code_rounded;
    }
    if (n.contains('design') || n.contains('brand') || n.contains('ux')) {
      return Icons.palette_rounded;
    }
    if (n.contains('marketing') ||
        n.contains('growth') ||
        n.contains('sales')) {
      return Icons.campaign_rounded;
    }
    if (n.contains('finance') ||
        n.contains('accounting') ||
        n.contains('budget')) {
      return Icons.account_balance_wallet_rounded;
    }
    if (n.contains('operation') || n.contains('logistic')) {
      return Icons.settings_suggest_rounded;
    }
    if (n.contains('support') ||
        n.contains('client') ||
        n.contains('customer')) {
      return Icons.support_agent_rounded;
    }
    if (n.contains('rh') || n.contains('hr') || n.contains('human')) {
      return Icons.groups_rounded;
    }
    if (n.contains('admin')) {
      return Icons.admin_panel_settings_rounded;
    }
    if (n.contains('legal') || n.contains('juridique')) {
      return Icons.gavel_rounded;
    }

    return Icons.business_center_rounded;
  }

  void _changeDepartment(WorkforceDepartment department, int delta) {
    setState(() {
      department.targetCount =
          (department.targetCount + delta).clamp(0, 99);
    });
  }
}

class _DotDelay extends StatefulWidget {
  final int delay;

  const _DotDelay({
    required this.delay,
  });

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