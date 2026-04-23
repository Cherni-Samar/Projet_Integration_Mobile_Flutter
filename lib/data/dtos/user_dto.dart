class UserDto {
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

  const UserDto({
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

  factory UserDto.fromJson(Map<String, dynamic> json) {
    final rawActiveAgents = json['activeAgents'];
    return UserDto(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name']?.toString(),
      email: (json['email'] ?? '').toString(),
      isEmailVerified: json['isEmailVerified'] == true,
      subscriptionPlan: (json['subscriptionPlan'] ?? 'free').toString(),
      subscriptionStatus: json['subscriptionStatus']?.toString(),
      maxAgentsAllowed: (json['maxAgentsAllowed'] is num)
          ? (json['maxAgentsAllowed'] as num).toInt()
          : 1,
      activeAgents: rawActiveAgents is List
          ? rawActiveAgents.map((e) => e.toString()).toList()
          : const [],
      energyBalance: (json['energyBalance'] is num)
          ? (json['energyBalance'] as num).toInt()
          : 0,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
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
