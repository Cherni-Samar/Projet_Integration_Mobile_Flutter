import 'package:flutter/material.dart';

import 'package:e_team/domain/models/agent_metadata_model.dart';
import 'package:e_team/domain/models/cart_item.dart';
import 'package:e_team/domain/models/owned_agent.dart';

Color colorFromValue(Object? value, {Color fallback = Colors.black}) {
  if (value is Color) return value;
  if (value is int) return Color(value);
  return fallback;
}

int colorToValue(Color color) => color.toARGB32();

extension CartItemColorExtension on CartItem {
  Color get agentColor => Color(agentColorValue);
}

extension OwnedAgentColorExtension on OwnedAgent {
  Color get agentColor => Color(agentColorValue);
}

extension AgentMetadataColorExtension on AgentMetadata {
  Color get color => Color(colorValue);
}
