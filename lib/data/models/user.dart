import 'package:equatable/equatable.dart';

import '../dtos/user_dto.dart';
import '../mappers/user_mapper.dart';

class User extends Equatable {
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

  const User({
    required this.id,
    this.name,
    required this.email,
    required this.isEmailVerified,
    this.subscriptionPlan = 'free',
    this.subscriptionStatus,
    this.maxAgentsAllowed = 1,
    this.activeAgents = const [],
    this.energyBalance = 0,
    this.createdAt,
    this.updatedAt,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    bool? isEmailVerified,
    String? subscriptionPlan,
    String? subscriptionStatus,
    int? maxAgentsAllowed,
    List<String>? activeAgents,
    int? energyBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      maxAgentsAllowed: maxAgentsAllowed ?? this.maxAgentsAllowed,
      activeAgents: activeAgents ?? this.activeAgents,
      energyBalance: energyBalance ?? this.energyBalance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        isEmailVerified,
        subscriptionPlan,
        subscriptionStatus,
        maxAgentsAllowed,
        activeAgents,
        energyBalance,
        createdAt,
        updatedAt,
      ];

  /// Convenience factory — delegates to [UserMapper.fromJson].
  factory User.fromJson(Map<String, dynamic> json) =>
      UserMapper.fromDto(UserDto.fromJson(json));

  /// Convenience serialiser — delegates to [UserMapper.toDto].
  Map<String, dynamic> toJson() => UserMapper.toDto(this).toJson();
}
