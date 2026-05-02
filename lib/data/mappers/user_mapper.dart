// lib/data/mappers/user_mapper.dart
import '../../domain/models/user_model.dart';
import '../dtos/user_dto.dart';

class UserMapper {
  static User fromDTO(UserDTO dto) {
    return User(
      id: dto.id,
      name: dto.name,
      email: dto.email,
      isEmailVerified: dto.isEmailVerified,
      subscriptionPlan: dto.subscriptionPlan,
      subscriptionStatus: dto.subscriptionStatus,
      maxAgentsAllowed: dto.maxAgentsAllowed,
      activeAgents: dto.activeAgents,
      energyBalance: dto.energyBalance,

      // ✅ MAPPING DE LA LISTE DES SETTINGS
      workforceSettings: dto.workforceSettings.map((s) => WorkforceSetting(
        department: s.department,
        targetCount: s.targetCount,
        currentCount: s.currentCount,
      )).toList(),

      companyVision: dto.companyVision,

      createdAt: dto.createdAt != null ? DateTime.tryParse(dto.createdAt!) : null,
      updatedAt: dto.updatedAt != null ? DateTime.tryParse(dto.updatedAt!) : null,
    );
  }

  static UserDTO toDTO(User user) {
    return UserDTO(
      id: user.id,
      email: user.email,
      name: user.name,
      isEmailVerified: user.isEmailVerified,
      subscriptionPlan: user.subscriptionPlan,
      subscriptionStatus: user.subscriptionStatus,
      maxAgentsAllowed: user.maxAgentsAllowed,
      activeAgents: user.activeAgents,
      energyBalance: user.energyBalance,

      // ✅ CONVERSION INVERSE
      workforceSettings: user.workforceSettings.map((s) => WorkforceSettingDTO(
        department: s.department,
        targetCount: s.targetCount,
        currentCount: s.currentCount,
      )).toList(),

      companyVision: user.companyVision,

      createdAt: user.createdAt?.toIso8601String(),
      updatedAt: user.updatedAt?.toIso8601String(),
    );
  }
}