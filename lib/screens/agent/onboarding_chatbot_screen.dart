import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';

class OnboardingChatbotScreen extends StatefulWidget {
  final String email;

  const OnboardingChatbotScreen({Key? key, required this.email})
      : super(key: key);

  @override
  State<OnboardingChatbotScreen> createState() => _OnboardingChatbotScreenState();
}

class _OnboardingChatbotScreenState extends State<OnboardingChatbotScreen>
    with TickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  int _currentQuestion = 0;
  bool _isTyping = false;
  late AnimationController _glowController;

  final Map<String, List<String>> _userData = {
    'role': [],
    'teamSize': [],
    'challenges': [],
    'priority': [],
  };

  // ✅ Catalog agents (match Marketplace + Cart)
  // key = agentId interne
  final Map<String, Map<String, dynamic>> _agentCatalog = {
    'elya': {
      'display': 'Elya',
      'title': 'Elya',
      'illustration': 'assets/images/nexa.png',
      'color': Color(0xFF8B5CF6),
      'monthlyPrice': 29.0,
    },
    'kash': {
      'display': 'Kash',
      'title': 'Kash',
      'illustration': 'assets/images/kash.png',
      'color': Color(0xFFF59E0B),
      'monthlyPrice': 39.0,
    },
    'dox': {
      'display': 'Dox',
      'title': 'Dox',
      'illustration': 'assets/images/dexo.png',
      'color': Color(0xFF10B981),
      'monthlyPrice': 25.0,
    },
    'timo': {
      'display': 'Timo',
      'title': 'Timo',
      'illustration': 'assets/images/krono.png',
      'color': Color(0xFFEC4899),
      'monthlyPrice': 19.0,
    },
    'echo': {
      'display': 'Echo',
      'title': 'Echo',
      'illustration': 'assets/images/voxi.png',
      'color': Color(0xFFA855F7),
      'monthlyPrice': 19.0,
    },
  };

  final List<BotQuestion> _questions = [
    BotQuestion(
      id: 'role',
      question: "👋 Nice to meet you!\n\nWhat's your role?",
      options: [
        '👔 CEO / Founder',
        '📊 Manager',
        '💼 Department Head',
        '👨‍💻 Employee',
        '🎓 Student',
      ],
      multiSelect: false,
    ),
    BotQuestion(
      id: 'teamSize',
      question: "How large is your team?",
      options: [
        'Solo',
        '2-5 people',
        '6-20 people',
        '21-50 people',
        '50+ people',
      ],
      multiSelect: false,
    ),
    BotQuestion(
      id: 'challenges',
      question: "What are your biggest challenges?",
      subtitle: "Select all that apply",
      options: [
        '⏰ Time management',
        '📈 Growth management',
        '💰 Cost optimization',
        '🤝 Team coordination',
        '📊 Data analysis',
        '🔄 Task automation',
      ],
      multiSelect: true,
    ),
    BotQuestion(
      id: 'priority',
      question: "What's your #1 priority?",
      options: [
        '🚀 Productivity',
        '💡 Innovation',
        '📈 Revenue growth',
        '👥 Team development',
        '⚡ Time saving',
      ],
      multiSelect: false,
    ),
  ];

  Set<String> _selectedOptions = {};

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _startConversation();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _startConversation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _askQuestion();
  }

  Future<void> _askQuestion() async {
    if (_currentQuestion >= _questions.length) {
      _showRecommendations();
      return;
    }

    setState(() => _isTyping = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final question = _questions[_currentQuestion];
    setState(() {
      _messages.add(ChatMessage(
        text: question.question,
        subtitle: question.subtitle,
        isBot: true,
        options: question.options,
        multiSelect: question.multiSelect,
      ));
      _isTyping = false;
      _selectedOptions.clear();
    });

    _scrollToBottom();
  }

  void _toggleOption(String option) {
    final question = _questions[_currentQuestion];

    setState(() {
      if (question.multiSelect) {
        if (_selectedOptions.contains(option)) {
          _selectedOptions.remove(option);
        } else {
          _selectedOptions.add(option);
        }
      } else {
        _selectedOptions = {option};
        Future.delayed(const Duration(milliseconds: 200), () {
          _handleAnswer([option]);
        });
      }
    });
  }

  void _handleAnswer(List<String> answers) {
    final question = _questions[_currentQuestion];

    setState(() {
      _messages.add(ChatMessage(
        text: answers.join(', '),
        isBot: false,
      ));
      _userData[question.id] = answers;
      _currentQuestion++;
      _selectedOptions.clear();
    });

    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 500), () {
      _askQuestion();
    });
  }

  void _confirmSelection() {
    if (_selectedOptions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one option'),
          backgroundColor: const Color(0xFFB55AF6), // ✅ violet
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(20),
        ),
      );
      return;
    }
    _handleAnswer(_selectedOptions.toList());
  }

  Future<void> _showRecommendations() async {
    setState(() => _isTyping = true);
    await Future.delayed(const Duration(milliseconds: 1000));

    // ✅ now returns structured list + text
    final rec = _generateRecommendations();
    final recommendationsText = rec.text;
    final recommendedKeys = rec.agentKeys;

    // ✅ add recommended agents to cart
    _addRecommendedAgentsToCart(recommendedKeys);

    setState(() {
      _messages.add(ChatMessage(
        text:
        "✨ Based on your needs, I recommend these agents:\n\n$recommendationsText\n\n✅ Added to your cart automatically.",
        isBot: true,
        showActions: true,
      ));
      _isTyping = false;
    });

    _scrollToBottom();
  }

  // ✅ Add agents to cart (avoid duplicates via stable id)
  void _addRecommendedAgentsToCart(List<String> keys) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    int added = 0;

    for (final key in keys) {
      final data = _agentCatalog[key];
      if (data == null) continue;

      final id = 'rec-${data['title']}'; // ✅ stable to avoid duplicates
      final alreadyInCart = cart.items.any((it) => it.id == id);

      if (alreadyInCart) continue;

      final item = CartItem(
        id: id,
        title: data['title'] as String,
        plan: 'monthly',
        price: (data['monthlyPrice'] as double),
        color: data['color'] as Color,
        illustration: data['illustration'] as String,
      );

      cart.addToCart(item);
      added++;
    }


  }

  // ✅ Return: text + agent keys
  _RecommendationResult _generateRecommendations() {
    final challenges = _userData['challenges'] ?? [];
    final priority =
    _userData['priority']?.isNotEmpty == true ? _userData['priority']![0] : '';

    // ✅ definitions used to print
    final List<Map<String, String>> agents = [
      {
        'key': 'elya',
        'name': '🤝 **Elya** (HR Agent)',
        'description': 'Manages leave requests, employee onboarding, and team coordination',
      },
      {
        'key': 'kash',
        'name': '💰 **Kash** (Financial Agent)',
        'description': 'Validates expenses, tracks budgets, and generates financial reports',
      },
      {
        'key': 'dox',
        'name': '📋 **Dox** (Administrative Agent)',
        'description': 'Classifies documents, manages files, and handles access rights',
      },
      {
        'key': 'timo',
        'name': '⏰ **Timo** (Planning Agent)',
        'description': 'Avoids scheduling conflicts, prioritizes tasks, and sends deadline reminders',
      },
      {
        'key': 'echo',
        'name': '💬 **Echo** (Communication Agent)',
        'description': 'Summarizes conversations, filters messages, and sends smart notifications',
      },
    ];

    final List<String> recommendedBlocks = [];
    final List<String> recommendedKeys = [];

    void addAgentByKey(String key) {
      final a = agents.firstWhere((x) => x['key'] == key, orElse: () => {});
      if (a.isEmpty) return;

      final block = "${a['name']}\n   • ${a['description']}";
      if (!recommendedBlocks.contains(block)) {
        recommendedBlocks.add(block);
        recommendedKeys.add(key);
      }
    }

    // Challenges logic
    if (challenges.contains('⏰ Time management') ||
        challenges.contains('🔄 Task automation')) {
      addAgentByKey('timo');
    }

    if (challenges.contains('🤝 Team coordination')) {
      addAgentByKey('elya');
      addAgentByKey('echo');
    }

    if (challenges.contains('💰 Cost optimization')) {
      addAgentByKey('kash');
    }

    if (challenges.contains('📊 Data analysis')) {
      addAgentByKey('kash');
      addAgentByKey('dox');
    }

    // Priority logic
    if (priority.contains('🚀 Productivity') || priority.contains('⚡ Time saving')) {
      addAgentByKey('timo');
    }

    if (priority.contains('👥 Team development')) {
      addAgentByKey('elya');
    }

    // fallback
    if (recommendedBlocks.isEmpty) {
      addAgentByKey('elya');
      addAgentByKey('kash');
      addAgentByKey('timo');
    }

    // limit to 3
    final blocks = recommendedBlocks.take(3).toList();
    final keys = recommendedKeys.take(3).toList();

    return _RecommendationResult(
      text: blocks.join('\n\n'),
      agentKeys: keys,
    );
  }

  void _skipToMarketplace() {
    Navigator.pushReplacementNamed(context, '/agent-marketplace');
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion =
    _currentQuestion < _questions.length ? _questions[_currentQuestion] : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCDFF00),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFCDFF00)
                              .withOpacity(0.5 * _glowController.value),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: Colors.black, size: 18),
                  );
                },
              ),
              const SizedBox(width: 10),
              const Text(
                'E-Team AI',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(color: Colors.white),
          Column(
            children: [
              const SizedBox(height: 100),

              if (_currentQuestion < _questions.length)
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                const Color(0xFFCDFF00).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_currentQuestion + 1}/${_questions.length}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Question ${_currentQuestion + 1}',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCDFF00),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${(((_currentQuestion + 1) / _questions.length) * 100).round()}%',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (_currentQuestion + 1) / _questions.length,
                            backgroundColor: Colors.black.withOpacity(0.05),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFCDFF00)),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return _buildTypingIndicator();
                    }
                    return _buildMessage(_messages[index], index);
                  },
                ),
              ),

              if (currentQuestion != null &&
                  currentQuestion.multiSelect &&
                  _selectedOptions.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.black, Color(0xFF2A2A2A)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _confirmSelection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCDFF00),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_selectedOptions.length}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded,
                                color: Color(0xFFCDFF00), size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message, int index) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('message_$index'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 50)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        final clampedValue = value.clamp(0.0, 1.0);

        return Transform.scale(
          scale: clampedValue,
          alignment:
          message.isBot ? Alignment.centerLeft : Alignment.centerRight,
          child: Opacity(
            opacity: clampedValue,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment:
                message.isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment:
                    message.isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (message.isBot) ...[
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFCDFF00), Color(0xFFB8E600)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFCDFF00).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.auto_awesome,
                              color: Colors.black, size: 24),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Flexible(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: message.isBot ? Colors.white : Colors.black,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(24),
                              topRight: const Radius.circular(24),
                              bottomLeft: Radius.circular(message.isBot ? 4 : 24),
                              bottomRight: Radius.circular(message.isBot ? 24 : 4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: message.isBot
                                    ? Colors.black.withOpacity(0.08)
                                    : Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.text,
                                style: TextStyle(
                                  color:
                                  message.isBot ? Colors.black87 : Colors.white,
                                  fontSize: 15,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (message.subtitle != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCDFF00).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    message.subtitle!,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (!message.isBot) ...[
                        const SizedBox(width: 12),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCDFF00),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFCDFF00).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.email.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (message.options != null && message.options!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(left: message.isBot ? 56 : 0),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: message.options!.map((option) {
                          final isSelected = _selectedOptions.contains(option);
                          return _buildOptionButton(option, isSelected, message.multiSelect);
                        }).toList(),
                      ),
                    ),

                  if (message.showActions == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.black, Color(0xFF2A2A2A)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 25,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _skipToMarketplace,
                            icon: const Icon(Icons.explore,
                                size: 24, color: Color(0xFFCDFF00)),
                            label: const Text(
                              'Discover Marketplace',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton(String option, bool isSelected, bool multiSelect) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        final clampedValue = value.clamp(0.0, 1.0);

        return Transform.scale(
          scale: clampedValue,
          child: InkWell(
            onTap: () => _toggleOption(option),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                  colors: [Colors.black, Color(0xFF2A2A2A)],
                )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.black12,
                  width: 2,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (multiSelect) ...[
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFCDFF00)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFCDFF00)
                              : Colors.black26,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 14, color: Colors.black)
                          : null,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFCDFF00), Color(0xFFB8E600)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFCDFF00).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.black, size: 24),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                _AnimatedDot(delay: 0),
                SizedBox(width: 6),
                _AnimatedDot(delay: 200),
                SizedBox(width: 6),
                _AnimatedDot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ small DTO
class _RecommendationResult {
  final String text;
  final List<String> agentKeys;

  _RecommendationResult({required this.text, required this.agentKeys});
}

class _AnimatedDot extends StatefulWidget {
  final int delay;

  const _AnimatedDot({required this.delay});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = (_controller.value + (widget.delay / 1200)) % 1.0;
        final scale =
        (0.6 + (math.sin(value * math.pi * 2) * 0.4)).clamp(0.0, 1.0);
        final opacity =
        (0.3 + (math.sin(value * math.pi * 2) * 0.7)).clamp(0.0, 1.0);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(opacity),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

class ChatMessage {
  final String text;
  final String? subtitle;
  final bool isBot;
  final List<String>? options;
  final bool multiSelect;
  final bool showActions;

  ChatMessage({
    required this.text,
    this.subtitle,
    required this.isBot,
    this.options,
    this.multiSelect = false,
    this.showActions = false,
  });
}

class BotQuestion {
  final String id;
  final String question;
  final String? subtitle;
  final List<String> options;
  final bool multiSelect;

  BotQuestion({
    required this.id,
    required this.question,
    this.subtitle,
    required this.options,
    this.multiSelect = false,
  });
}
