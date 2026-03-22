class User {
  final String id;
  final String? name;
  final String email;
  final bool isEmailVerified;
  final String subscriptionPlan;
  final int maxAgentsAllowed;
  final List<String> activeAgents;
  final int energyBalance;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    this.name,
    required this.email,
    required this.isEmailVerified,
    this.subscriptionPlan = 'free',
    this.maxAgentsAllowed = 1,
    this.activeAgents = const [],
    this.energyBalance = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final rawActiveAgents = json['activeAgents'];

    return User(
      id: json['id'] ?? json['_id'],
      name: json['name'],
      email: json['email'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      subscriptionPlan: (json['subscriptionPlan'] ?? 'free').toString(),
      maxAgentsAllowed: (json['maxAgentsAllowed'] is num)
          ? (json['maxAgentsAllowed'] as num).toInt()
          : 1,
      activeAgents: rawActiveAgents is List
          ? rawActiveAgents.map((e) => e.toString()).toList()
          : const [],
      energyBalance: (json['energyBalance'] is num)
          ? (json['energyBalance'] as num).toInt()
          : 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  User copyWith({
    String? subscriptionPlan,
    int? maxAgentsAllowed,
    List<String>? activeAgents,
    int? energyBalance,
  }) {
    return User(
      id: id,
      name: name,
      email: email,
      isEmailVerified: isEmailVerified,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      maxAgentsAllowed: maxAgentsAllowed ?? this.maxAgentsAllowed,
      activeAgents: activeAgents ?? this.activeAgents,
      energyBalance: energyBalance ?? this.energyBalance,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'isEmailVerified': isEmailVerified,
      'subscriptionPlan': subscriptionPlan,
      'maxAgentsAllowed': maxAgentsAllowed,
      'activeAgents': activeAgents,
      'energyBalance': energyBalance,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}