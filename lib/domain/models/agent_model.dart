// lib/domain/models/agent_model.dart
class Agent {
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

  // Champs calculés (Logique métier)
  final String name;
  final String category;
  final bool isActive;

  Agent({
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
    required this.name,
    required this.category,
    required this.isActive,
  });
}
