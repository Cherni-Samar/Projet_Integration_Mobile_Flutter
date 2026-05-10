// lib/data/dtos/user_dto.dart

// ✅ 1. DÉFINIR LA PETITE CLASSE EN PREMIER
class WorkforceSettingDTO {
  final String department;
  final int targetCount;
  final int currentCount;

  WorkforceSettingDTO({
    required this.department,
    required this.targetCount,
    required this.currentCount,
  });

  factory WorkforceSettingDTO.fromJson(Map<String, dynamic> json) {
    return WorkforceSettingDTO(
      department: json['department']?.toString() ?? '',
      targetCount: (json['targetCount'] as num?)?.toInt() ?? 0,
      currentCount: (json['currentCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'department': department,
      'targetCount': targetCount,
      'currentCount': currentCount,
    };
  }
}

// ✅ 2. DÉFINIR LA CLASSE PRINCIPALE ENSUITE
class UserDTO {
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

  // Nouveaux champs pour la stratégie IA
  final List<WorkforceSettingDTO> workforceSettings;
  final String companyVision;

  final String? createdAt;
  final String? updatedAt;

  UserDTO({
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
    required this.workforceSettings,
    required this.companyVision,
    this.createdAt,
    this.updatedAt,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    // Parsing sécurisé de la liste des settings
    var list = json['workforceSettings'] as List?;
    List<WorkforceSettingDTO> settingsList = list != null
        ? list.map((i) => WorkforceSettingDTO.fromJson(i)).toList()
        : [];

    return UserDTO(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'],
      email: json['email'] ?? '',
      onboardingCompleted: json['onboardingCompleted'] ?? false, // ✅ PARSED
      isEmailVerified: json['isEmailVerified'] ?? false,
      subscriptionPlan: (json['subscriptionPlan'] ?? 'free').toString(),
      subscriptionStatus: json['subscriptionStatus']?.toString(),
      maxAgentsAllowed: (json['maxAgentsAllowed'] as num?)?.toInt() ?? 1,
      activeAgents:
          (json['activeAgents'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      energyBalance: (json['energyBalance'] as num?)?.toInt() ?? 0,

      // Nouveaux champs
      workforceSettings: settingsList,
      companyVision: json['companyVision'] ?? '',

      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'isEmailVerified': isEmailVerified,
      'onboardingCompleted': onboardingCompleted, // ✅ Added
      'subscriptionPlan': subscriptionPlan,
      'subscriptionStatus': subscriptionStatus,
      'maxAgentsAllowed': maxAgentsAllowed,
      'activeAgents': activeAgents,
      'energyBalance': energyBalance,
      'workforceSettings': workforceSettings.map((s) => s.toJson()).toList(),
      'companyVision': companyVision,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
