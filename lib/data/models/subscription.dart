import 'package:equatable/equatable.dart';

class Subscription extends Equatable {
  final String plan;
  final String? status;
  final int maxAgentsAllowed;

  const Subscription({
    required this.plan,
    this.status,
    required this.maxAgentsAllowed,
  });

  bool get isActive => status == 'active';
  bool get isFree => plan.toLowerCase() == 'free';

  @override
  List<Object?> get props => [plan, status, maxAgentsAllowed];
}
