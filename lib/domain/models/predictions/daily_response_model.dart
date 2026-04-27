import 'daily_challenge_model.dart';

class DailyResponseModel {
  final bool success;
  final bool alreadyExists;
  final bool alreadyAnswered;
  final int streak;
  final DailyChallengeModel? challenge;
  final String? error;

  const DailyResponseModel({
    required this.success,
    required this.alreadyExists,
    required this.alreadyAnswered,
    required this.streak,
    required this.challenge,
    this.error,
  });

  factory DailyResponseModel.fromJson(Map<String, dynamic> json) {
    final challengeJson = json['challenge'];

    return DailyResponseModel(
      success: json['success'] == true,
      alreadyExists: json['alreadyExists'] == true,
      alreadyAnswered: json['alreadyAnswered'] == true,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      challenge: challengeJson is Map
          ? DailyChallengeModel.fromJson(challengeJson.cast<String, dynamic>())
          : null,
      error: json['error']?.toString(),
    );
  }

  bool get canPlay => success && challenge != null && !alreadyAnswered;
}
