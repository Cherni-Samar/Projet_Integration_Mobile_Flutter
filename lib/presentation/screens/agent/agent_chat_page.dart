import 'package:e_team/presentation/providers/owned_agents_provider.dart';
import 'package:e_team/presentation/providers/theme_provider.dart';
import 'package:e_team/presentation/utils/domain_model_color_extensions.dart';
import 'package:e_team/presentation/widgets/agent/chat/agent_chat_models.dart';
import 'package:e_team/presentation/widgets/agent/chat/agent_chat_input.dart';
import 'package:e_team/presentation/widgets/agent/chat/agent_chat_layout.dart';
import 'package:e_team/presentation/widgets/agent/chat/agent_chat_messages.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AgentChatPage extends StatefulWidget {
  final OwnedAgent agent;

  const AgentChatPage({super.key, required this.agent});

  @override
  State<AgentChatPage> createState() => _AgentChatPageState();
}

class _AgentChatPageState extends State<AgentChatPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<AgentChatMessage> _messages = [];

  List<AgentChatQuickAction> _quickActionsFor(String agentName) {
    if (agentName.toLowerCase() == 'hera') {
      return const [
        AgentChatQuickAction(
          icon: Icons.event_available_outlined,
          label: 'Leave',
        ),
        AgentChatQuickAction(
          icon: Icons.people_alt_outlined,
          label: 'Onboarding',
        ),
        AgentChatQuickAction(icon: Icons.task_alt_outlined, label: 'Approvals'),
      ];
    }

    return const [
      AgentChatQuickAction(icon: Icons.bolt_outlined, label: 'Tasks'),
      AgentChatQuickAction(icon: Icons.lightbulb_outline, label: 'Ideas'),
      AgentChatQuickAction(icon: Icons.auto_awesome_outlined, label: 'Magic'),
    ];
  }

  List<AgentChatSuggestion> _suggestionsFor(String agentName) {
    if (agentName.toLowerCase() == 'hera') {
      return const [
        AgentChatSuggestion('What can you do?'),
        AgentChatSuggestion('Create leave request'),
        AgentChatSuggestion('List pending requests'),
        AgentChatSuggestion('Approve request'),
        AgentChatSuggestion('More'),
      ];
    }

    return const [
      AgentChatSuggestion('What can you do?'),
      AgentChatSuggestion('Quick summary'),
      AgentChatSuggestion('Help'),
      AgentChatSuggestion('More'),
    ];
  }

  void _send(String text) {
    final value = text.trim();
    if (value.isEmpty) return;

    setState(() {
      _messages.add(AgentChatMessage(fromUser: true, text: value));
      _messages.add(
        const AgentChatMessage(
          fromUser: false,
          text:
              '✅ Noted.\n(For now: UI only. Next step: connect to your backend.)',
        ),
      );
    });

    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 250,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final agent = widget.agent;
    final glass = isDark
        ? const Color(0xFF141414)
        : Colors.white.withValues(alpha: 0.72);
    final textMain = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSub = isDark ? Colors.white70 : const Color(0xFF64748B);
    final accent = agent.agentColor;
    final suggestions = _suggestionsFor(agent.agentName);
    final actions = _quickActionsFor(agent.agentName);

    return Scaffold(
      body: AgentChatScaffoldBackground(
        isDark: isDark,
        child: SafeArea(
          child: Column(
            children: [
              AgentChatHeader(
                agent: agent,
                isDark: isDark,
                textMain: textMain,
                textSub: textSub,
                onBack: () => Navigator.pop(context),
              ),
              AgentChatHeroCard(
                agent: agent,
                isDark: isDark,
                glassColor: glass,
                textMain: textMain,
                textSub: textSub,
                suggestions: suggestions,
                onSuggestionTap: _send,
              ),
              Expanded(
                child: AgentChatMessages(
                  messages: _messages,
                  scrollController: _scroll,
                  isDark: isDark,
                  accent: accent,
                  textMain: textMain,
                  textSub: textSub,
                ),
              ),
              AgentChatBottomBar(
                actions: actions,
                controller: _controller,
                isDark: isDark,
                accent: accent,
                glassColor: glass,
                textMain: textMain,
                onActionTap: _send,
                onSend: _send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
