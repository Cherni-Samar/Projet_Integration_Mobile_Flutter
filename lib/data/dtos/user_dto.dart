// lib/data/dtos/user_dto.dart
class UserDTO {
  final String id;
  final String? name;
  final String email;
  final bool isEmailVerified;
  final String subscriptionPlan;
  final String? subscriptionStatus;
  final int maxAgentsAllowed;
  final List<String> activeAgents;
  final int energyBalance;
  final String? createdAt;
  final String? updatedAt;

  UserDTO({
    required this.id,
    this.name,
    required this.email,
    required this.isEmailVerified,
    required this.subscriptionPlan,
    this.subscriptionStatus,
    required this.maxAgentsAllowed,
    required this.activeAgents,
    required this.energyBalance,
    this.createdAt,
    this.updatedAt,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    final rawActiveAgents = json['activeAgents'];
    return UserDTO(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'],
      email: json['email'] ?? '',
      isEmailVerified: json['isEmailVerified'] ?? false,
      subscriptionPlan: (json['subscriptionPlan'] ?? 'free').toString(),
      subscriptionStatus: json['subscriptionStatus']?.toString(),
      maxAgentsAllowed: (json['maxAgentsAllowed'] as num?)?.toInt() ?? 1,
      activeAgents: rawActiveAgents is List ? rawActiveAgents.map((e) => e.toString()).toList() : const [],
      energyBalance: (json['energyBalance'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'isEmailVerified': isEmailVerified,
      'subscriptionPlan': subscriptionPlan,
      'subscriptionStatus': subscriptionStatus,
      'maxAgentsAllowed': maxAgentsAllowed,
      'activeAgents': activeAgents,
      'energyBalance': energyBalance,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}