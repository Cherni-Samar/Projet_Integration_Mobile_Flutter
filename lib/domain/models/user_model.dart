// lib/domain/models/user_model.dart

// ✅ Classe pour les réglages d'effectifs
class WorkforceSetting {
  final String department;
  final int targetCount;
  final int currentCount;

  WorkforceSetting({
    required this.department,
    required this.targetCount,
    required this.currentCount,
  });
}

class User {
  final String id;
  final String? name;
  final String email;
  final bool isEmailVerified;
  final bool onboardingCompleted; // ✅ NOUVEAU CHAMP
  final String subscriptionPlan;
  final String? subscriptionStatus;
  final int maxAgentsAllowed;
  final List<String> activeAgents;
  final int energyBalance;

  // ✅ NOUVEAUX CHAMPS POUR L'IA
  final List<WorkforceSetting> workforceSettings;
  final String companyVision;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    this.name,
    required this.email,
    required this.isEmailVerified,
    required this.onboardingCompleted, // ✅ ADDED
    required this.subscriptionPlan,
    this.subscriptionStatus,
    required this.maxAgentsAllowed,
    required this.activeAgents,
    required this.energyBalance,
    // ✅ INITIALISATION
    required this.workforceSettings,
    required this.companyVision,
    this.createdAt,
    this.updatedAt,
  });

  // ✅ Mise à jour du copyWith pour inclure les nouveaux champs
  User copyWith({
    bool? onboardingCompleted,
    String? subscriptionPlan,
    String? subscriptionStatus,
    int? maxAgentsAllowed,
    List<String>? activeAgents,
    int? energyBalance,
    List<WorkforceSetting>? workforceSettings,
    String? companyVision,
  }) {
    return User(
      id: id,
      name: name,
      email: email,
      isEmailVerified: isEmailVerified,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      maxAgentsAllowed: maxAgentsAllowed ?? this.maxAgentsAllowed,
      activeAgents: activeAgents ?? this.activeAgents,
      energyBalance: energyBalance ?? this.energyBalance,
      workforceSettings: workforceSettings ?? this.workforceSettings,
      companyVision: companyVision ?? this.companyVision,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
