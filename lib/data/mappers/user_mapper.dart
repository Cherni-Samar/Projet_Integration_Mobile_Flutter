import '../dtos/user_dto.dart';
import '../models/user.dart';

class UserMapper {
  const UserMapper._();

  static User fromDto(UserDto dto) => User(
        id: dto.id,
        name: dto.name,
        email: dto.email,
        isEmailVerified: dto.isEmailVerified,
        subscriptionPlan: dto.subscriptionPlan,
        subscriptionStatus: dto.subscriptionStatus,
        maxAgentsAllowed: dto.maxAgentsAllowed,
        activeAgents: dto.activeAgents,
        energyBalance: dto.energyBalance,
        createdAt: dto.createdAt != null
            ? DateTime.tryParse(dto.createdAt!)
            : null,
        updatedAt: dto.updatedAt != null
            ? DateTime.tryParse(dto.updatedAt!)
            : null,
      );

  static UserDto toDto(User model) => UserDto(
        id: model.id,
        name: model.name,
        email: model.email,
        isEmailVerified: model.isEmailVerified,
        subscriptionPlan: model.subscriptionPlan,
        subscriptionStatus: model.subscriptionStatus,
        maxAgentsAllowed: model.maxAgentsAllowed,
        activeAgents: model.activeAgents,
        energyBalance: model.energyBalance,
        createdAt: model.createdAt?.toIso8601String(),
        updatedAt: model.updatedAt?.toIso8601String(),
      );

  /// Convenience: parse a raw API JSON map directly to a domain [User].
  static User fromJson(Map<String, dynamic> json) =>
      fromDto(UserDto.fromJson(json));
}
