enum AgentType {
  hera,
  echo,
  timo,
  dexo,
  kash,
}

enum InteractionStatus {
  encrypted,
  success,
  pending,
  failed,
}

class AgentInteraction {
  final String id;
  final AgentType sender;
  final AgentType receiver;
  final String actionType;
  final String summary;
  final DateTime timestamp;
  final InteractionStatus status;

  AgentInteraction({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.actionType,
    required this.summary,
    required this.timestamp,
    required this.status,
  });

  factory AgentInteraction.fromJson(Map<String, dynamic> json) {
    return AgentInteraction(
      id: json['id']?.toString() ?? '',
      sender: _parseAgentType(json['sender']),
      receiver: _parseAgentType(json['receiver']),
      actionType: json['actionType']?.toString() ?? 'Unknown Action',
      summary: json['summary']?.toString() ?? 'No description available',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'].toString())
          : DateTime.now(),
      status: _parseInteractionStatus(json['status']),
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays > 0) return 'Il y a ${diff.inDays}j';
    if (diff.inHours > 0) return 'Il y a ${diff.inHours}h';
    if (diff.inMinutes > 0) return 'Il y a ${diff.inMinutes} min';
    return 'À l\'instant';
  }

  String get statusLabel {
    switch (status) {
      case InteractionStatus.success:
        return 'SUCCESS';
      case InteractionStatus.encrypted:
        return 'ENCRYPTED';
      case InteractionStatus.pending:
        return 'PENDING';
      case InteractionStatus.failed:
        return 'FAILED';
    }
  }

  static AgentType _parseAgentType(dynamic agentString) {
    if (agentString == null) return AgentType.hera;

    switch (agentString.toString().toLowerCase()) {
      case 'hera':
        return AgentType.hera;
      case 'echo':
        return AgentType.echo;
      case 'timo':
        return AgentType.timo;
      case 'dexo':
        return AgentType.dexo;
      case 'kash':
        return AgentType.kash;
      default:
        return AgentType.hera;
    }
  }

  static InteractionStatus _parseInteractionStatus(dynamic statusString) {
    if (statusString == null) return InteractionStatus.success;

    switch (statusString.toString().toLowerCase()) {
      case 'success':
        return InteractionStatus.success;
      case 'encrypted':
        return InteractionStatus.encrypted;
      case 'pending':
        return InteractionStatus.pending;
      case 'failed':
        return InteractionStatus.failed;
      default:
        return InteractionStatus.success;
    }
  }
}
