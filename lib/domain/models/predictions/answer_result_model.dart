import 'badge_model.dart';

class AnswerResultModel {
  final bool isCorrect;
  final int correctAnswer;
  final int userAnswer;
  final String chosenAgent;
  final int energyReward;
  final int streakMultiplier;
  final int currentStreak;
  final BadgeModel? badge;
  final String message;

  const AnswerResultModel({
    required this.isCorrect,
    required this.correctAnswer,
    required this.userAnswer,
    required this.chosenAgent,
    required this.energyReward,
    required this.streakMultiplier,
    required this.currentStreak,
    required this.message,
    this.badge,
  });

  factory AnswerResultModel.fromJson(Map<String, dynamic> json) =>
      AnswerResultModel(
        isCorrect: json['isCorrect'] == true,
        correctAnswer: (json['correctAnswer'] as num?)?.toInt() ?? -1,
        userAnswer: (json['userAnswer'] as num?)?.toInt() ?? -1,
        chosenAgent: json['chosenAgent']?.toString() ?? '',
        energyReward: (json['energyReward'] as num?)?.toInt() ?? 0,
        streakMultiplier: (json['streakMultiplier'] as num?)?.toInt() ?? 1,
        currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
        badge: json['badge'] == null
            ? null
            : BadgeModel.fromJson(
                (json['badge'] as Map).cast<String, dynamic>(),
              ),
        message: json['message']?.toString() ?? '',
      );
}
