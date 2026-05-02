class BadgeModel {
  final String name;
  final String emoji;

  const BadgeModel({required this.name, required this.emoji});

  factory BadgeModel.fromJson(Map<String, dynamic> json) => BadgeModel(
    name: json['name']?.toString() ?? '',
    emoji: json['emoji']?.toString() ?? '',
  );
}
