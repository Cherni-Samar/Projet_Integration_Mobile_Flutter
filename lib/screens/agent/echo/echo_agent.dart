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
  final String? token;

  // Propriétés supplémentaires
  late String name;
  late String icon;
  late String category;
  late bool isActive;
  late String type;
  late List<String> capabilities;

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
    this.token,
  }) {
    name = title;
    icon = illustration;
    category = 'General';
    isActive = true;
    type = 'base';
    capabilities = [];
  }
}