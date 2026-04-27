class DailyChallengeModel {
  final String id;
  final String question;
  final List<String> options;
  final String domain;
  final String domainIcon;
  final String challengeType;
  final String status;

  const DailyChallengeModel({
    required this.id,
    required this.question,
    required this.options,
    required this.domain,
    required this.domainIcon,
    required this.challengeType,
    required this.status,
  });

  factory DailyChallengeModel.fromJson(Map<String, dynamic> json) =>
      DailyChallengeModel(
        id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
        question: json['question']?.toString() ?? '',
        options: (json['options'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        domain: json['domain']?.toString() ?? '',
        domainIcon: json['domainIcon']?.toString() ?? '',
        challengeType: json['challengeType']?.toString() ?? 'text',
        status: json['status']?.toString() ?? 'pending',
      );
}
