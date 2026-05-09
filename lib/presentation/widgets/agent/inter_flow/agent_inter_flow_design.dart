import 'package:e_team/domain/models/agent_interaction_model.dart';
import 'package:flutter/material.dart';

class AgentInterFlowDesignSystem {
  const AgentInterFlowDesignSystem._();

  static const Color bg = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFF1F5F9);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Color heraGreen = Color(0xFFE8F5E8);
  static const Color echoViolet = Color(0xFFF3E8FF);
  static const Color timoOrange = Color(0xFFFFF4E6);
  static const Color dexoBlue = Color(0xFFE6F3FF);
  static const Color kashTeal = Color(0xFFE6FFFA);

  static const Color heraGreenIcon = Color(0xFF10B981);
  static const Color echoVioletIcon = Color(0xFF8B5CF6);
  static const Color timoOrangeIcon = Color(0xFFFF9800);
  static const Color dexoBlueIcon = Color(0xFF3B82F6);
  static const Color kashTealIcon = Color(0xFF06B6D4);

  static const Color success = Color(0xFF10B981);
  static const Color encrypted = Color(0xFF8B5CF6);
  static const Color shadowLight = Color(0x08000000);
}

class AgentInteractionUi {
  const AgentInteractionUi._();

  static Map<AgentType, Map<String, dynamic>> get agentConfig => {
    AgentType.hera: {
      'name': 'HERA',
      'icon': Icons.people_outline,
      'bgColor': AgentInterFlowDesignSystem.heraGreen,
      'iconColor': AgentInterFlowDesignSystem.heraGreenIcon,
    },
    AgentType.echo: {
      'name': 'ECHO',
      'icon': Icons.campaign_outlined,
      'bgColor': AgentInterFlowDesignSystem.echoViolet,
      'iconColor': AgentInterFlowDesignSystem.echoVioletIcon,
    },
    AgentType.timo: {
      'name': 'TIMO',
      'icon': Icons.schedule_outlined,
      'bgColor': AgentInterFlowDesignSystem.timoOrange,
      'iconColor': AgentInterFlowDesignSystem.timoOrangeIcon,
    },
    AgentType.dexo: {
      'name': 'DEXO',
      'icon': Icons.admin_panel_settings_outlined,
      'bgColor': AgentInterFlowDesignSystem.dexoBlue,
      'iconColor': AgentInterFlowDesignSystem.dexoBlueIcon,
    },
    AgentType.kash: {
      'name': 'KASH',
      'icon': Icons.account_balance_outlined,
      'bgColor': AgentInterFlowDesignSystem.kashTeal,
      'iconColor': AgentInterFlowDesignSystem.kashTealIcon,
    },
  };
}

extension AgentInteractionUiX on AgentInteraction {
  Color get statusColor {
    switch (status) {
      case InteractionStatus.success:
        return AgentInterFlowDesignSystem.success;
      case InteractionStatus.encrypted:
        return AgentInterFlowDesignSystem.encrypted;
      case InteractionStatus.pending:
        return AgentInterFlowDesignSystem.textMuted;
      case InteractionStatus.failed:
        return Colors.red;
    }
  }
}
