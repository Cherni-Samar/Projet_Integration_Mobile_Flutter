import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/owned_agents_provider.dart';

class AgentChatPage extends StatefulWidget {
  final OwnedAgent agent;
  const AgentChatPage({Key? key, required this.agent}) : super(key: key);

  @override
  State<AgentChatPage> createState() => _AgentChatPageState();
}

class _AgentChatPageState extends State<AgentChatPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  final List<_ChatMsg> _messages = [];

  List<_QuickAction> _quickActionsFor(String agentName) {
    // style “Cici” : actions fixes
    if (agentName.toLowerCase() == "hera") {
      return const [
        _QuickAction(icon: Icons.event_available_outlined, label: "Leave"),
        _QuickAction(icon: Icons.people_alt_outlined, label: "Onboarding"),
        _QuickAction(icon: Icons.task_alt_outlined, label: "Approvals"),
      ];
    }
    return const [
      _QuickAction(icon: Icons.bolt_outlined, label: "Tasks"),
      _QuickAction(icon: Icons.lightbulb_outline, label: "Ideas"),
      _QuickAction(icon: Icons.auto_awesome_outlined, label: "Magic"),
    ];
  }

  List<_SuggestionChip> _suggestionsFor(String agentName) {
    if (agentName.toLowerCase() == "hera") {
      return const [
        _SuggestionChip("What can you do?"),
        _SuggestionChip("Create leave request"),
        _SuggestionChip("List pending requests"),
        _SuggestionChip("Approve request"),
        _SuggestionChip("More"),
      ];
    }
    return const [
      _SuggestionChip("What can you do?"),
      _SuggestionChip("Quick summary"),
      _SuggestionChip("Help"),
      _SuggestionChip("More"),
    ];
  }

  void _send(String text) {
    final v = text.trim();
    if (v.isEmpty) return;

    setState(() {
      _messages.add(_ChatMsg(fromUser: true, text: v));
      // réponse fake (UI only)
      _messages.add(_ChatMsg(
        fromUser: false,
        text:
        "✅ Noted.\n(For now: UI only. Next step: connect to your backend.)",
      ));
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

    // Palette proche de l’exemple (pastel/gradient)
    final bgTop = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFEFFAF7);
    final bgBottom = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF2E9FF);

    final glass = isDark ? const Color(0xFF141414) : Colors.white.withOpacity(0.72);
    final textMain = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSub = isDark ? Colors.white70 : const Color(0xFF64748B);
    final accent = agent.agentColor;

    final suggestions = _suggestionsFor(agent.agentName);
    final actions = _quickActionsFor(agent.agentName);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgTop, bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── HEADER (comme Cici) ───────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                child: Row(
                  children: [
                    _circleButton(
                      isDark: isDark,
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    _avatarSmall(agent, accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            agent.displayName,
                            style: TextStyle(
                              color: textMain,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "${agent.agentName.toLowerCase()}@e-team.com",
                            style: TextStyle(
                              color: textSub,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _circleButton(
                      isDark: isDark,
                      icon: Icons.volume_up_outlined,
                      onTap: () {},
                    ),
                    const SizedBox(width: 10),
                    _circleButton(
                      isDark: isDark,
                      icon: Icons.more_horiz,
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              // ── HERO CARD (avatar grand + “Hi I’m …”) ──────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                child: _glassCard(
                  color: glass,
                  borderColor: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.06),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _avatarBig(agent, accent),
                      const SizedBox(height: 14),
                      Text(
                        "Hi I’m ${agent.displayName}",
                        style: TextStyle(
                          color: textMain,
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Life’s short — do more, worry way less.",
                        style: TextStyle(
                          color: textSub,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Suggestions chips
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: suggestions.map((s) {
                          return _chip(
                            isDark: isDark,
                            text: s.label,
                            onTap: () => _send(s.label),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),

              // ── CHAT LIST (optionnel, tu peux le garder vide) ───────
              Expanded(
                child: _messages.isEmpty
                    ? Center(
                  child: Text(
                    "Start a conversation…",
                    style: TextStyle(
                      color: textSub,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                    : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                  itemCount: _messages.length,
                  itemBuilder: (_, i) {
                    final m = _messages[i];
                    return _bubble(
                      isDark: isDark,
                      accent: accent,
                      textMain: textMain,
                      msg: m.text,
                      fromUser: m.fromUser,
                    );
                  },
                ),
              ),

              // ── BOTTOM BAR (actions + input) ───────────────────────
              Container(
                padding: EdgeInsets.only(
                  left: 14,
                  right: 14,
                  top: 10,
                  bottom: 10 + MediaQuery.of(context).padding.bottom,
                ),
                decoration: BoxDecoration(
                  color: glass,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.06),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // actions row (Homework / AI image / Edit…)
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: actions.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final a = actions[i];
                          return _actionPill(
                            isDark: isDark,
                            accent: accent,
                            icon: a.icon,
                            label: a.label,
                            onTap: () => _send(a.label),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // input row
                    Row(
                      children: [
                        _squareIcon(
                          isDark: isDark,
                          icon: Icons.add,
                          onTap: () {},
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: TextStyle(
                              color: textMain,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              hintText: "Message…",
                              hintStyle: TextStyle(
                                color: isDark ? Colors.white38 : Colors.black38,
                                fontWeight: FontWeight.w600,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white.withOpacity(0.65),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: _send,
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: () => _send(_controller.text),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [const Color(0xFFCDFF00), const Color(0xFFAADD00)]
                                    : [accent.withOpacity(0.25), accent.withOpacity(0.12)],
                              ),
                              color: isDark ? null : Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isDark
                                    ? Colors.transparent
                                    : Colors.black.withOpacity(0.06),
                              ),
                            ),
                            child: Icon(
                              Icons.mic_none_rounded,
                              color: isDark ? Colors.black : accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────── UI pieces ─────────────────

  Widget _glassCard({
    required Color color,
    required Color borderColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }

  Widget _avatarSmall(OwnedAgent agent, Color accent) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          agent.agentIllustration,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(Icons.smart_toy, color: accent),
        ),
      ),
    );
  }

  Widget _avatarBig(OwnedAgent agent, Color accent) {
    return Stack(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                accent.withOpacity(0.25),
                accent.withOpacity(0.10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: accent.withOpacity(0.35), width: 3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Image.asset(
              agent.agentIllustration,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(Icons.smart_toy, size: 60, color: accent),
              ),
            ),
          ),
        ),
        Positioned(
          right: 6,
          top: 6,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withOpacity(0.06)),
            ),
            child: const Icon(Icons.help_outline, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _circleButton({
    required bool isDark,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.65),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.06),
          ),
        ),
        child: Icon(icon, size: 20, color: isDark ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _chip({
    required bool isDark,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.06),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _actionPill({
    required bool isDark,
    required Color accent,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.65),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.06),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: accent),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _squareIcon({
    required bool isDark,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.65),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.06),
          ),
        ),
        child: Icon(icon, color: isDark ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _bubble({
    required bool isDark,
    required Color accent,
    required Color textMain,
    required String msg,
    required bool fromUser,
  }) {
    final bg = fromUser
        ? (isDark ? const Color(0xFFCDFF00) : Colors.black)
        : (isDark ? const Color(0xFF1E1E1E) : Colors.white.withOpacity(0.75));
    final fg = fromUser ? (isDark ? Colors.black : const Color(0xFFCDFF00)) : textMain;

    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: fromUser
                ? Colors.transparent
                : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
          ),
        ),
        child: Text(
          msg,
          style: TextStyle(
            color: fg,
            fontSize: 14,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ChatMsg {
  final bool fromUser;
  final String text;
  _ChatMsg({required this.fromUser, required this.text});
}

class _SuggestionChip {
  final String label;
  const _SuggestionChip(this.label);
}

class _QuickAction {
  final IconData icon;
  final String label;
  const _QuickAction({required this.icon, required this.label});
}