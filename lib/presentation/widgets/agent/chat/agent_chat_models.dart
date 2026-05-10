import 'package:flutter/material.dart';

class AgentChatMessage {
  final bool fromUser;
  final String text;

  const AgentChatMessage({required this.fromUser, required this.text});
}

class AgentChatSuggestion {
  final String label;

  const AgentChatSuggestion(this.label);
}

class AgentChatQuickAction {
  final IconData icon;
  final String label;

  const AgentChatQuickAction({required this.icon, required this.label});
}
