import 'badge_model.dart';

class PredictionHistoryItemModel {
  final String id;
  final String question;
  final String challengeType;
  final String chosenAgent;
  final bool isCorrect;
  final int energyReward;
  final String domain;
  final int streakDay;
  final DateTime? answeredAt;
  final BadgeModel? badge;

  const PredictionHistoryItemModel({
    required this.id,
    required this.question,
    required this.challengeType,
    required this.chosenAgent,
    required this.isCorrect,
    required this.energyReward,
    required this.domain,
    required this.streakDay,
    required this.answeredAt,
    required this.badge,
  });

  factory PredictionHistoryItemModel.fromJson(Map<String, dynamic> json) =>
      PredictionHistoryItemModel(
        id: json['_id']?.toString() ?? '',
        question: json['question']?.toString() ?? '',
        challengeType: json['challengeType']?.toString() ?? 'text',
        chosenAgent: json['chosenAgent']?.toString() ?? '',
        isCorrect: json['isCorrect'] == true,
        energyReward: (json['energyReward'] as num?)?.toInt() ?? 0,
        domain: json['domain']?.toString() ?? '',
        streakDay: (json['streakDay'] as num?)?.toInt() ?? 0,
        answeredAt: json['answeredAt'] == null
            ? null
            : DateTime.tryParse(json['answeredAt'].toString()),
        badge: json['badge'] == null
            ? null
            : BadgeModel.fromJson(
                (json['badge'] as Map).cast<String, dynamic>(),
              ),
      );
}
