class SubscriptionDto {
  final String plan;
  final String? status;
  final int maxAgentsAllowed;

  const SubscriptionDto({
    required this.plan,
    this.status,
    required this.maxAgentsAllowed,
  });

  factory SubscriptionDto.fromJson(Map<String, dynamic> json) => SubscriptionDto(
        plan: (json['plan'] ?? 'free').toString(),
        status: json['status']?.toString(),
        maxAgentsAllowed: (json['maxAgentsAllowed'] as num?)?.toInt() ?? 1,
      );

  Map<String, dynamic> toJson() => {
        'plan': plan,
        'status': status,
        'maxAgentsAllowed': maxAgentsAllowed,
      };
}
