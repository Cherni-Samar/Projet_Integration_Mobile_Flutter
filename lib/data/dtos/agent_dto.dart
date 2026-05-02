// lib/data/dtos/agent_dto.dart
class AgentDTO {
  final String title;
  final String shortTitle;
  final int color;
  final String illustration;
  final List<String> description;
  final List<String> benefits;
  final List<String> detailedFeatures;
  final String timesSaved;
  final Map<String, dynamic> stats;
  final String price;

  AgentDTO({
    required this.title,
    required this.shortTitle,
    required this.color,
    required this.illustration,
    required this.description,
    required this.benefits,
    required this.detailedFeatures,
    required this.timesSaved,
    required this.stats,
    required this.price,
  });

  factory AgentDTO.fromJson(Map<String, dynamic> json) {
    return AgentDTO(
      title: json['title'] ?? '',
      shortTitle: json['shortTitle'] ?? '',
      color: json['color'] ?? 0xFFFFFFFF,
      illustration: json['illustration'] ?? '',
      description: List<String>.from(json['description'] ?? []),
      benefits: List<String>.from(json['benefits'] ?? []),
      detailedFeatures: List<String>.from(json['detailedFeatures'] ?? []),
      timesSaved: json['timesSaved'] ?? '0',
      stats: Map<String, dynamic>.from(json['stats'] ?? {}),
      price: json['price'] ?? 'Free',
    );
  }
}