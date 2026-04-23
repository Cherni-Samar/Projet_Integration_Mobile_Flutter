import '../dtos/subscription_dto.dart';
import '../models/subscription.dart';

class SubscriptionMapper {
  const SubscriptionMapper._();

  static Subscription fromDto(SubscriptionDto dto) => Subscription(
        plan: dto.plan,
        status: dto.status,
        maxAgentsAllowed: dto.maxAgentsAllowed,
      );

  static SubscriptionDto toDto(Subscription model) => SubscriptionDto(
        plan: model.plan,
        status: model.status,
        maxAgentsAllowed: model.maxAgentsAllowed,
      );
}
