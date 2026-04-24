// lib/domain/models/user_model.dart
class User {
  final String id;
  final String? name;
  final String email;
  final bool isEmailVerified;
  final String subscriptionPlan;
  final String? subscriptionStatus;
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
    required this.subscriptionPlan,
    this.subscriptionStatus,
    required this.maxAgentsAllowed,
    required this.activeAgents,
    required this.energyBalance,
    this.createdAt,
    this.updatedAt,
  });

  User copyWith({
    String? subscriptionPlan,
    String? subscriptionStatus,
    int? maxAgentsAllowed,
    List<String>? activeAgents,
    int? energyBalance,
  }) {
    return User(
      id: id, name: name, email: email, isEmailVerified: isEmailVerified,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      maxAgentsAllowed: maxAgentsAllowed ?? this.maxAgentsAllowed,
      activeAgents: activeAgents ?? this.activeAgents,
      energyBalance: energyBalance ?? this.energyBalance,
      createdAt: createdAt, updatedAt: updatedAt,
    );
  }
}