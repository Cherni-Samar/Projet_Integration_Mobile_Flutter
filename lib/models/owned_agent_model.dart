import 'package:flutter/material.dart';

class OwnedAgent {
  final String agentName;
  String customName;             // user-given nickname
  final String agentIllustration;
  final Color agentColor;
  String packTitle;               // latest pack purchased
  int energy;                     // cumulative energy
  final DateTime purchasedAt;

  OwnedAgent({
    required this.agentName,
    String? customName,
    required this.agentIllustration,
    required this.agentColor,
    required this.packTitle,
    required this.energy,
    required this.purchasedAt,
  }) : customName = customName ?? agentName;

  /// Display name: custom name if set, otherwise agent name
  String get displayName => customName;
}
